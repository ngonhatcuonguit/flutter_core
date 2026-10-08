import 'package:dio/dio.dart';
import 'package:flutter_core_project/data/data_sources/remote/festival_api_service.dart';
import 'package:flutter_test/flutter_test.dart';

// Run explicitly with: flutter test --dart-define=THP_LIVE_SMOKE=true
// test/festival_live_smoke_test.dart. This test only reads server data.
void main() {
  const runLive = bool.fromEnvironment('THP_LIVE_SMOKE');

  test('live Hotline mobile APIs return usable guest, colors, zones and tables',
      () async {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://mobile-test.thp.com.vn',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
    addTearDown(() => dio.close());
    final api = FestivalApiService(dio);

    final guest = await api.searchGuestForSeating(
      accessToken: 'read-only-smoke',
      eventId: 2,
      keyword: 'THP0039',
    );
    final colors = await api.getPrefixColors(
      accessToken: 'read-only-smoke',
      eventId: 2,
    );
    final zones = await api.getSeatingZones(
      accessToken: 'read-only-smoke',
      eventId: 2,
    );

    expect(guest.guestCode, 'THP0039');
    expect(guest.id, greaterThan(0));
    expect(guest.numberInvited, greaterThan(0));
    expect(guest.prefixColor?.bgColor, isNotEmpty);
    expect(colors.any((color) => color.prefixCode == 'THP'), isTrue);
    expect(zones, isNotEmpty);

    final zone = zones.firstWhere((item) => item.tables.isNotEmpty);
    final filtered = await api.getSeatingZones(
      accessToken: 'read-only-smoke',
      eventId: 2,
      zone: zone.name,
    );
    expect(filtered, hasLength(1));
    expect(filtered.single.name, zone.name);
    expect(filtered.single.tables, isNotEmpty);
    expect(filtered.single.tables.first.id, greaterThan(0));
    expect(filtered.single.tables.first.capacity, greaterThan(0));
    expect(
        filtered.single.tables.first.availableSeats, greaterThanOrEqualTo(0));
  }, skip: !runLive);
}
