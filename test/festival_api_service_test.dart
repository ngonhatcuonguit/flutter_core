import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_core_project/data/data_sources/remote/festival_api_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FestivalApiService contract', () {
    test('login, gates and check-in use the documented JSON contract',
        () async {
      final harness = _FestivalApiHarness((request) {
        switch (request.uri.path) {
          case '/api/mobile/login':
            return _jsonResponse({
              'Success': true,
              'Token': 'test-access-token',
              'User': {
                'Username': 'receptionist',
                'FullName': 'Lễ tân Test',
              },
            });
          case '/api/mobile/gates':
            return _jsonResponse({
              'Success': true,
              'Count': 1,
              'Data': [
                {
                  'Id': 2,
                  'GateName': 'Cổng VIP 1',
                  'GateCode': 'GATE_VIP_01',
                  'Status': 1,
                },
              ],
            });
          case '/api/mobile/checkin':
            return _jsonResponse({
              'Success': true,
              'AlreadyCheckedIn': false,
              'Message': 'Check-in thành công!',
              'CheckInTime': '09:05:00 19/09/2026',
              'GateName': 'Cổng VIP 1',
              'Guest': {
                'FullName': 'Ông Nguyễn Văn A',
                'Company': 'THP',
                'Position': 'Khách mời',
                'VIP': 2,
                'VIPName': 'VIP',
                'GuestCode': 'VIP001',
              },
            });
          case '/api/mobile/gift-checkin':
            return _jsonResponse({
              'Success': true,
              'AlreadyReceived': false,
              'Message': 'Quét nhận quà thành công!',
              'Guest': {
                'FullName': 'Ông Nguyễn Văn A',
                'Company': 'THP',
                'Position': 'Khách mời',
                'VIP': 2,
                'VIPName': 'VIP',
                'GuestCode': 'VIP001',
                'GiftStatus': 1,
                'GiftReceivedDate': '09:10:00 19/09/2026',
                'GiftGateName': 'Cổng VIP 1',
              },
            });
          default:
            throw StateError('Unexpected request: ${request.uri}');
        }
      });
      addTearDown(harness.close);

      final session = await harness.service.login(
        username: ' receptionist ',
        password: 'secret',
      );
      final gates = await harness.service.getGates(
        accessToken: session.accessToken,
      );
      final result = await harness.service.checkIn(
        code: ' 0901234567 ',
        accessToken: session.accessToken,
        gateName: gates.single.name,
        notes: 'Manual test',
      );
      final giftResult = await harness.service.giftCheckIn(
        code: ' VIP001 ',
        accessToken: session.accessToken,
        gateName: gates.single.name,
        notes: 'Gift test',
      );

      expect(session.accessToken, 'test-access-token');
      expect(session.username, 'receptionist');
      expect(session.displayName, 'Lễ tân Test');
      expect(gates.single.code, 'GATE_VIP_01');
      expect(result.success, isTrue);
      expect(result.fullName, 'Ông Nguyễn Văn A');
      expect(result.position, 'Khách mời');
      expect(result.guestCode, 'VIP001');
      expect(result.gateName, 'Cổng VIP 1');
      expect(giftResult.success, isTrue);
      expect(giftResult.alreadyReceived, isFalse);
      expect(giftResult.fullName, 'Ông Nguyễn Văn A');
      expect(giftResult.giftReceivedDate, '09:10:00 19/09/2026');
      expect(giftResult.giftGateName, 'Cổng VIP 1');

      final login = harness.adapter.requests[0];
      expect(login.method, 'POST');
      expect(login.uri.path, '/api/mobile/login');
      expect(login.contentType, Headers.jsonContentType);
      expect(login.data, {
        'Username': 'receptionist',
        'Password': 'secret',
      });

      final gatesRequest = harness.adapter.requests[1];
      expect(gatesRequest.method, 'GET');
      expect(gatesRequest.uri.path, '/api/mobile/gates');
      expect(gatesRequest.queryParameters, {'status': 1});
      expect(
        gatesRequest.headers['Authorization'],
        'Bearer test-access-token',
      );

      final checkIn = harness.adapter.requests[2];
      expect(checkIn.method, 'POST');
      expect(checkIn.uri.path, '/api/mobile/checkin');
      expect(checkIn.contentType, Headers.jsonContentType);
      expect(checkIn.data, {
        'QrCode': '0901234567',
        'GateName': 'Cổng VIP 1',
        'DeviceId': 'My THP Festival',
        'Notes': 'Manual test',
      });
      expect(checkIn.headers['Authorization'], 'Bearer test-access-token');

      final giftCheckIn = harness.adapter.requests[3];
      expect(giftCheckIn.method, 'POST');
      expect(giftCheckIn.uri.path, '/api/mobile/gift-checkin');
      expect(giftCheckIn.contentType, Headers.jsonContentType);
      expect(giftCheckIn.data, {
        'QrCode': 'VIP001',
        'GateName': 'Cổng VIP 1',
        'DeviceId': 'My THP Festival',
        'Notes': 'Gift test',
      });
      expect(
        giftCheckIn.headers['Authorization'],
        'Bearer test-access-token',
      );
    });

    test('keeps an already checked-in response as a displayable result',
        () async {
      final harness = _FestivalApiHarness(
        (_) => _jsonResponse({
          'Success': false,
          'AlreadyCheckedIn': true,
          'Message': 'Khách đã check-in.',
          'PreviousCheckInTime': '08:30',
          'PreviousGate': 'Cổng Chính',
          'Guest': {
            'FullName': 'Bà Trần B',
            'GuestCode': 'G002',
          },
        }),
      );
      addTearDown(harness.close);

      final result = await harness.service.checkIn(
        code: 'G002',
        accessToken: 'token',
        gateName: 'Cổng Chính',
      );

      expect(result.success, isFalse);
      expect(result.alreadyCheckedIn, isTrue);
      expect(result.fullName, 'Bà Trần B');
      expect(result.previousGate, 'Cổng Chính');
    });

    test('keeps an already received gift response as a displayable result',
        () async {
      final harness = _FestivalApiHarness(
        (_) => _jsonResponse({
          'Success': false,
          'AlreadyReceived': true,
          'Message': 'Khách đã nhận quà.',
          'Guest': {
            'FullName': 'Bà Trần B',
            'GuestCode': 'G002',
            'GiftReceivedDate': '08:40',
            'GiftGateName': 'Quầy quà chính',
          },
        }),
      );
      addTearDown(harness.close);

      final result = await harness.service.giftCheckIn(
        code: 'G002',
        accessToken: 'token',
        gateName: 'Quầy quà phụ',
      );

      expect(result.success, isFalse);
      expect(result.alreadyReceived, isTrue);
      expect(result.fullName, 'Bà Trần B');
      expect(result.giftReceivedDate, '08:40');
      expect(result.giftGateName, 'Quầy quà chính');
    });

    test('rejects a successful login response without a token', () async {
      final harness = _FestivalApiHarness(
        (_) => _jsonResponse({'Success': true}),
      );
      addTearDown(harness.close);

      await expectLater(
        harness.service.login(username: 'receptionist', password: 'password'),
        throwsA(isA<FestivalApiException>()),
      );
    });
  });
}

typedef _RequestHandler = ResponseBody Function(RequestOptions request);

class _FestivalApiHarness {
  _FestivalApiHarness(_RequestHandler handler)
      : adapter = _FakeHttpClientAdapter(handler),
        dio = Dio(
          BaseOptions(baseUrl: 'https://mobile-test.thp.com.vn'),
        ) {
    dio.httpClientAdapter = adapter;
    service = FestivalApiService(dio);
  }

  final Dio dio;
  final _FakeHttpClientAdapter adapter;
  late final FestivalApiService service;

  void close() => dio.close(force: true);
}

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._handler);

  final _RequestHandler _handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(Object body, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: const {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}
