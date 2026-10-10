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
                'Id': 12,
                'FullName': 'Ông Nguyễn Văn A',
                'Company': 'THP',
                'Position': 'Khách mời',
                'VIP': 2,
                'VIPName': 'VIP',
                'GuestCode': 'VIP001',
                'NumberInvited': 2,
                'TableId': 5,
                'TableName': 'Bàn 01',
                'TableSeat': 'Ghế 02',
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
                'TableName': 'Bàn 01',
                'TableSeat': 'Ghế 02',
                'GiftNote': 'Bộ quà tặng VIP đối tác',
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
      expect(result.tableName, 'Bàn 01');
      expect(result.tableSeat, 'Ghế 02');
      expect(result.guestId, 12);
      expect(result.tableId, 5);
      expect(result.numberInvited, 2);
      expect(giftResult.success, isTrue);
      expect(giftResult.alreadyReceived, isFalse);
      expect(giftResult.fullName, 'Ông Nguyễn Văn A');
      expect(giftResult.giftReceivedDate, '09:10:00 19/09/2026');
      expect(giftResult.giftGateName, 'Cổng VIP 1');
      expect(giftResult.tableName, 'Bàn 01');
      expect(giftResult.tableSeat, 'Ghế 02');
      expect(giftResult.giftStatus, 1);
      expect(giftResult.giftNote, 'Bộ quà tặng VIP đối tác');

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
      });
      expect(giftCheckIn.data, isNot(contains('Notes')));
      expect(giftCheckIn.data, isNot(contains('GiftNotes')));
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
            'GiftNote': '   ',
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
      expect(result.giftNote, isNull);
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

    test('uses the live HotlineSeating mobile response and mutation contract',
        () async {
      final harness = _FestivalApiHarness((request) {
        switch (request.uri.path) {
          case '/api/mobile/HotlineSearchGuest':
            return _jsonResponse({
              'Success': true,
              'Data': {
                'Guest': {
                  'Id': 5610,
                  'GuestCode': 'THP0039',
                  'FullName': 'Khách THP',
                  'NumberInvited': 3,
                },
                'PrefixColor': {
                  'PrefixCode': 'THP',
                  'BgColor': '#FEE2E2',
                  'TextColor': '#991B1B',
                  'Note': 'Đỏ Tân Hiệp Phát',
                },
                'AssignedTables': [
                  {
                    'TableId': 1342,
                    'TableName': 'A10-01',
                    'Zone': 'A10',
                    'SeatCount': 2,
                  }
                ],
                'TotalAssignedSeats': 2,
                'RemainingNeededSeats': 1,
              },
            });
          case '/api/mobile/GetPrefixColors':
            return _jsonResponse({
              'Success': true,
              'Colors': [
                {
                  'PrefixCode': 'THP',
                  'BgColor': '#FEE2E2',
                  'TextColor': '#991B1B',
                }
              ],
            });
          case '/api/mobile/HotlineZonesAndTables':
            return _jsonResponse({
              'Success': true,
              'Zones': [
                {
                  'ZoneName': 'A10',
                  'Color': '#ec4899',
                  'Tables': [
                    {
                      'TableId': 1342,
                      'TableName': 'A10-01',
                      'Zone': 'A10',
                      'Capacity': 10,
                      'OccupiedSeats': 2,
                      'AvailableSeats': 8,
                      'IsFull': false,
                    }
                  ],
                }
              ],
            });
          case '/api/mobile/HotlineAssignTable':
          case '/api/mobile/HotlineChangeTable':
          case '/api/mobile/HotlineUnassignTable':
            return _jsonResponse({'Success': true, 'Message': 'Đã cập nhật'});
          default:
            throw StateError('Unexpected request: ${request.uri}');
        }
      });
      addTearDown(harness.close);

      final guest = await harness.service.searchGuestForSeating(
        accessToken: 'test-token',
        eventId: 2,
        keyword: ' THP0039 ',
      );
      final colors = await harness.service.getPrefixColors(
        accessToken: 'test-token',
        eventId: 2,
      );
      final zones = await harness.service.getSeatingZones(
        accessToken: 'test-token',
        eventId: 2,
      );
      final filteredZones = await harness.service.getSeatingZones(
        accessToken: 'test-token',
        eventId: 2,
        zone: ' A10 ',
      );
      await harness.service.assignSeatingTable(
        accessToken: 'test-token',
        eventId: 2,
        guestId: 5610,
        tableId: 1343,
        seatCount: 1,
      );
      await harness.service.changeSeatingTable(
        accessToken: 'test-token',
        eventId: 2,
        guestId: 5610,
        oldTableId: 1342,
        newTableId: 1343,
        seatCount: 2,
      );
      await harness.service.unassignSeatingTable(
        accessToken: 'test-token',
        eventId: 2,
        guestId: 5610,
        tableId: 1343,
      );

      expect(guest.id, 5610);
      expect(guest.numberInvited, 3);
      expect(guest.totalAssignedSeats, 2);
      expect(guest.remainingNeededSeats, 1);
      expect(guest.assignedTables.single.seatCount, 2);
      expect(guest.prefixColor?.bgColor, '#FEE2E2');
      expect(colors.single.prefixCode, 'THP');
      expect(zones.single.name, 'A10');
      expect(zones.single.tables.single.availableSeats, 8);
      expect(filteredZones.single.name, 'A10');
      expect(harness.adapter.requests[0].queryParameters,
          {'eventId': 2, 'keyword': 'THP0039'});
      expect(harness.adapter.requests[1].queryParameters, {'eventId': 2});
      expect(harness.adapter.requests[2].queryParameters, {'eventId': 2});
      expect(harness.adapter.requests[3].queryParameters,
          {'eventId': 2, 'zone': 'A10'});
      expect(harness.adapter.requests[2].uri.host, 'event_checkin.thp.com.vn');
      expect(harness.adapter.requests[3].uri.host, 'event_checkin.thp.com.vn');
      expect(
        harness.adapter.requests[0].uri.host,
        'mobile-test.thp.com.vn',
      );
      for (final request in harness.adapter.requests) {
        expect(request.headers['Authorization'], 'Bearer test-token');
      }
      expect(harness.adapter.requests[4].data, {
        'EventId': 2,
        'GuestId': 5610,
        'TableId': 1343,
        'SeatCount': 1,
        'SeatsDescription': '1 chỗ',
        'StaffName': 'My THP Festival',
        'Note': 'Gán bàn từ My THP Festival',
      });
      expect(harness.adapter.requests[5].data, {
        'EventId': 2,
        'GuestId': 5610,
        'OldTableId': 1342,
        'NewTableId': 1343,
        'SeatCount': 2,
        'SeatsDescription': '2 chỗ',
        'StaffName': 'My THP Festival',
        'Note': 'Chuyển bàn từ My THP Festival',
      });
      expect(harness.adapter.requests[6].data,
          {'EventId': 2, 'GuestId': 5610, 'TableId': 1343});
    });

    test('does not treat a 200 business error as a successful assignment',
        () async {
      final harness = _FestivalApiHarness(
        (_) => _jsonResponse({
          'Success': false,
          'Message': 'Bàn đã hết chỗ',
        }),
      );
      addTearDown(harness.close);

      await expectLater(
        harness.service.assignSeatingTable(
          accessToken: 'test-token',
          eventId: 2,
          guestId: 5610,
          tableId: 1342,
          seatCount: 3,
        ),
        throwsA(isA<FestivalApiException>().having(
          (error) => error.message,
          'message',
          'Bàn đã hết chỗ',
        )),
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
