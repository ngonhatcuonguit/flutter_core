import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_core_project/data/models/festival/festival_models.dart';

const String _festivalLogTag = '[THP_FESTIVAL_API]';

class FestivalApiService {
  final Dio _dio;
  final String _seatingBaseUrl;

  FestivalApiService(
    this._dio, {
    String seatingBaseUrl = 'https://event_checkin.thp.com.vn',
  }) : _seatingBaseUrl = seatingBaseUrl.replaceFirst(RegExp(r'/+$'), '');

  Future<FestivalSession> login({
    required String username,
    required String password,
  }) async {
    final normalizedUsername = username.trim();
    if (normalizedUsername.isEmpty || password.isEmpty) {
      throw const FestivalApiException('Missing Festival credentials.');
    }

    final root = await _requestJson(
      '/api/mobile/login',
      method: 'POST',
      data: {
        'Username': normalizedUsername,
        'Password': password,
      },
    );

    if (!_isSuccessful(root)) {
      throw FestivalApiException(
        _message(root) ?? 'Festival login failed.',
      );
    }

    try {
      return FestivalSession.fromJson(
        root,
        fallbackUsername: normalizedUsername,
      );
    } on FormatException catch (error) {
      throw FestivalApiException(
        'Festival login response is missing an access token.',
        cause: error,
      );
    }
  }

  Future<List<FestivalGate>> getGates({
    required String accessToken,
    int? eventId,
  }) async {
    if (accessToken.trim().isEmpty) {
      throw const FestivalUnauthorizedException();
    }
    final root = await _requestJson(
      '/api/mobile/gates',
      accessToken: accessToken,
      queryParameters: {
        if (eventId != null) 'eventId': eventId,
        'status': 1,
      },
    );
    if (_isUnauthorizedPayload(root)) {
      throw FestivalUnauthorizedException(message: _message(root));
    }
    if (!_isSuccessful(root)) {
      throw FestivalApiException(
        _message(root) ?? 'Unable to load Festival gates.',
      );
    }
    final rawData = readFestivalJsonValue(root, 'Data');
    if (rawData is! List) {
      throw const FestivalApiException(
        'Festival gate response has an invalid format.',
      );
    }
    return rawData
        .whereType<Map>()
        .map((item) => FestivalGate.fromJson(Map<String, dynamic>.from(item)))
        .where((gate) => gate.id > 0 && gate.name.isNotEmpty && gate.isActive)
        .toList(growable: false);
  }

  Future<FestivalCheckInResult> checkIn({
    required String code,
    required String accessToken,
    required String gateName,
    String notes = 'Check-in từ My THP Festival',
  }) async {
    final normalizedCode = code.trim();
    if (normalizedCode.isEmpty) {
      throw const FestivalApiException('The QR code is empty.');
    }
    if (accessToken.trim().isEmpty) {
      throw const FestivalUnauthorizedException();
    }
    final root = await _requestJson(
      '/api/mobile/checkin',
      method: 'POST',
      data: {
        'QrCode': normalizedCode,
        'GateName': gateName.trim(),
        'DeviceId': 'My THP Festival',
        'Notes': notes,
      },
      accessToken: accessToken,
    );
    if (_isUnauthorizedPayload(root)) {
      throw FestivalUnauthorizedException(message: _message(root));
    }
    return FestivalCheckInResult.fromJson(root);
  }

  Future<FestivalGiftCheckInResult> giftCheckIn({
    required String code,
    required String accessToken,
    required String gateName,
    int isSave = 0,
  }) async {
    final normalizedCode = code.trim();
    if (normalizedCode.isEmpty) {
      throw const FestivalApiException('The guest code is empty.');
    }
    if (accessToken.trim().isEmpty) {
      throw const FestivalUnauthorizedException();
    }
    if (isSave != 0 && isSave != 1) {
      throw const FestivalApiException('isSave must be 0 or 1.');
    }

    final root = await _requestJson(
      '/api/mobile/gift-checkin',
      method: 'POST',
      data: {
        'QrCode': normalizedCode,
        'GateName': gateName.trim(),
        'DeviceId': 'My THP Festival',
        'isSave': isSave,
      },
      accessToken: accessToken,
    );
    if (_isUnauthorizedPayload(root)) {
      throw FestivalUnauthorizedException(message: _message(root));
    }
    return FestivalGiftCheckInResult.fromJson(root);
  }

  Future<FestivalHotlineGuest> searchGuestForSeating({
    required String accessToken,
    required int eventId,
    required String keyword,
  }) async {
    final normalized = keyword.trim();
    if (normalized.isEmpty || eventId <= 0) {
      throw const FestivalApiException('Missing guest code or event ID.');
    }
    final root = await _requestJson(
      '/api/mobile/HotlineSearchGuest',
      accessToken: _requiredToken(accessToken),
      queryParameters: {'eventId': eventId, 'keyword': normalized},
    );
    _requireSuccess(root, 'Unable to load guest seating.');
    final data = _mapValue(readFestivalJsonValue(root, 'Data')) ?? root;
    final guest = FestivalHotlineGuest.fromJson(data);
    if (guest.id <= 0) {
      throw const FestivalApiException(
          'Guest seating response has no guest ID.');
    }
    return guest;
  }

  Future<List<FestivalPrefixColor>> getPrefixColors({
    required String accessToken,
    required int eventId,
  }) async {
    final root = await _requestJson(
      '/api/mobile/GetPrefixColors',
      accessToken: _requiredToken(accessToken),
      queryParameters: {'eventId': eventId},
    );
    _requireSuccess(root, 'Unable to load guest colors.');
    final raw = readFestivalJsonValue(root, 'Colors');
    if (raw is! List) {
      throw const FestivalApiException(
          'Guest colors response has an invalid format.');
    }
    return raw
        .whereType<Map>()
        .map((item) =>
            FestivalPrefixColor.fromJson(Map<String, dynamic>.from(item)))
        .where((color) => color.prefixCode.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<FestivalSeatingZone>> getSeatingZones({
    required String accessToken,
    required int eventId,
    String? zone,
  }) async {
    final root = await _requestJson(
      '$_seatingBaseUrl/api/mobile/HotlineZonesAndTables',
      accessToken: _requiredToken(accessToken),
      queryParameters: {
        'eventId': eventId,
        if (zone != null && zone.trim().isNotEmpty) 'zone': zone.trim(),
      },
    );
    _requireSuccess(root, 'Unable to load seating zones.');
    final raw = readFestivalJsonValue(root, 'Zones');
    if (raw is! List) {
      throw const FestivalApiException(
          'Seating zones response has an invalid format.');
    }
    return raw
        .whereType<Map>()
        .map((item) =>
            FestivalSeatingZone.fromJson(Map<String, dynamic>.from(item)))
        .where((zone) => zone.name.isNotEmpty)
        .toList(growable: false);
  }

  Future<String> assignSeatingTable({
    required String accessToken,
    required int eventId,
    required int guestId,
    required int tableId,
    required int seatCount,
    String staffName = 'My THP Festival',
  }) {
    _validateSeatingMutation(eventId, guestId, tableId, seatCount);
    return _seatingMutation(
      '/api/mobile/HotlineAssignTable',
      accessToken: accessToken,
      data: {
        'EventId': eventId,
        'GuestId': guestId,
        'TableId': tableId,
        'SeatCount': seatCount,
        'SeatsDescription': '$seatCount chỗ',
        'StaffName': staffName,
        'Note': 'Gán bàn từ My THP Festival',
      },
    );
  }

  Future<String> changeSeatingTable({
    required String accessToken,
    required int eventId,
    required int guestId,
    required int oldTableId,
    required int newTableId,
    required int seatCount,
    String staffName = 'My THP Festival',
  }) {
    _validateSeatingMutation(eventId, guestId, newTableId, seatCount);
    if (oldTableId <= 0 || oldTableId == newTableId) {
      throw const FestivalApiException(
          'Choose another table to move the guest.');
    }
    return _seatingMutation(
      '/api/mobile/HotlineChangeTable',
      accessToken: accessToken,
      data: {
        'EventId': eventId,
        'GuestId': guestId,
        'OldTableId': oldTableId,
        'NewTableId': newTableId,
        'SeatCount': seatCount,
        'SeatsDescription': '$seatCount chỗ',
        'StaffName': staffName,
        'Note': 'Chuyển bàn từ My THP Festival',
      },
    );
  }

  Future<String> unassignSeatingTable({
    required String accessToken,
    required int eventId,
    required int guestId,
    required int tableId,
  }) {
    _validateSeatingMutation(eventId, guestId, tableId, 1);
    return _seatingMutation(
      '/api/mobile/HotlineUnassignTable',
      accessToken: accessToken,
      data: {'EventId': eventId, 'GuestId': guestId, 'TableId': tableId},
    );
  }

  Future<String> _seatingMutation(
    String path, {
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    final root = await _requestJson(
      path,
      method: 'POST',
      data: data,
      accessToken: _requiredToken(accessToken),
    );
    _requireSuccess(root, 'Unable to update guest seating.');
    return _message(root) ?? 'Đã cập nhật bàn ngồi.';
  }

  String _requiredToken(String token) {
    if (token.trim().isEmpty) throw const FestivalUnauthorizedException();
    return token;
  }

  void _requireSuccess(Map<String, dynamic> root, String fallback) {
    if (_isUnauthorizedPayload(root)) {
      throw FestivalUnauthorizedException(message: _message(root));
    }
    if (!_isSuccessful(root)) {
      throw FestivalApiException(_message(root) ?? fallback);
    }
  }

  void _validateSeatingMutation(
      int eventId, int guestId, int tableId, int seatCount) {
    if (eventId <= 0 || guestId <= 0 || tableId <= 0 || seatCount <= 0) {
      throw const FestivalApiException('Invalid guest, table or seat count.');
    }
  }

  Map<String, dynamic>? _mapValue(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  Future<Map<String, dynamic>> _requestJson(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    String? accessToken,
  }) async {
    if (kDebugMode) debugPrint('$_festivalLogTag ▶ $method $path');

    try {
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method,
          contentType: data == null ? null : Headers.jsonContentType,
          headers: {
            'Accept': Headers.jsonContentType,
            if (accessToken != null)
              'Authorization': 'Bearer ${accessToken.trim()}',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final statusCode = response.statusCode ?? 0;
      if (kDebugMode) {
        debugPrint('$_festivalLogTag ◀ $statusCode $method $path');
      }
      if (statusCode == 401 || statusCode == 403) {
        throw FestivalUnauthorizedException(
          message: _messageFromRaw(response.data),
          statusCode: statusCode,
        );
      }
      if (statusCode < 200 || statusCode >= 300) {
        throw FestivalApiException(
          _messageFromRaw(response.data) ??
              'Festival server returned HTTP $statusCode.',
          statusCode: statusCode,
        );
      }
      return _asJsonObject(response.data);
    } on FestivalApiException {
      rethrow;
    } on DioException catch (error) {
      if (kDebugMode) {
        debugPrint(
          '$_festivalLogTag ✗ $path – ${error.type}: ${error.message}',
        );
      }
      throw FestivalApiException(
        _dioMessage(error),
        cause: error,
        statusCode: error.response?.statusCode,
      );
    } on FormatException catch (error) {
      throw FestivalApiException(
        'Festival server returned invalid data.',
        cause: error,
      );
    }
  }

  Map<String, dynamic> _asJsonObject(Object? raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String) {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    throw FormatException('Unexpected Festival response: ${raw.runtimeType}');
  }

  bool _isSuccessful(Map<String, dynamic> json) {
    final value = readFestivalJsonValue(json, 'Success');
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    return normalized == 'true' || normalized == '1' || normalized == 'success';
  }

  String? _message(Map<String, dynamic> json) {
    final value = readFestivalJsonValue(json, 'Message') ??
        readFestivalJsonValue(json, 'Error');
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  bool _isUnauthorizedPayload(Map<String, dynamic> json) {
    final statusCode = readFestivalJsonValue(json, 'StatusCode') ??
        readFestivalJsonValue(json, 'Code');
    if (statusCode?.toString() == '401' || statusCode?.toString() == '403') {
      return true;
    }
    if (_isSuccessful(json)) return false;
    final normalized = _message(json)?.toLowerCase() ?? '';
    final mentionsToken = normalized.contains('token') ||
        normalized.contains('phiên đăng nhập') ||
        normalized.contains('phiên làm việc') ||
        normalized.contains('đăng nhập lại') ||
        normalized.contains('session');
    final isRejected = normalized.contains('hết hạn') ||
        normalized.contains('không hợp lệ') ||
        normalized.contains('unauthorized') ||
        normalized.contains('expired') ||
        normalized.contains('invalid');
    return mentionsToken && isRejected;
  }

  String? _messageFromRaw(Object? raw) {
    try {
      return _message(_asJsonObject(raw));
    } catch (_) {
      return null;
    }
  }

  String _dioMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Festival server connection timed out.';
      case DioExceptionType.connectionError:
        return 'Unable to connect to the Festival server.';
      default:
        return _messageFromRaw(error.response?.data) ??
            'Unable to complete the Festival request.';
    }
  }
}

class FestivalApiException implements Exception {
  final String message;
  final Object? cause;
  final int? statusCode;

  const FestivalApiException(
    this.message, {
    this.cause,
    this.statusCode,
  });

  @override
  String toString() => message;
}

class FestivalUnauthorizedException extends FestivalApiException {
  const FestivalUnauthorizedException({
    String? message,
    int? statusCode,
  }) : super(
          message ?? 'Festival session has expired.',
          statusCode: statusCode,
        );
}
