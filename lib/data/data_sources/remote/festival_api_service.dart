import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_core_project/data/models/festival/festival_models.dart';

const String _festivalLogTag = '[THP_FESTIVAL_API]';

class FestivalApiService {
  final Dio _dio;

  FestivalApiService(this._dio);

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
    String notes = 'Gift redemption from My THP Festival',
  }) async {
    final normalizedCode = code.trim();
    if (normalizedCode.isEmpty) {
      throw const FestivalApiException('The guest code is empty.');
    }
    if (accessToken.trim().isEmpty) {
      throw const FestivalUnauthorizedException();
    }

    final root = await _requestJson(
      '/api/mobile/gift-checkin',
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
    return FestivalGiftCheckInResult.fromJson(root);
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
