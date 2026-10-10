import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core_project/core/configs/theme/app_theme.dart';
import 'package:flutter_core_project/data/data_sources/remote/festival_api_service.dart';
import 'package:flutter_core_project/data/models/festival/festival_models.dart';
import 'package:flutter_core_project/presentation/pages/festival/festival_scanner_page.dart';
import 'package:flutter_core_project/services/festival_auth_service.dart';
import 'package:flutter_core_project/services/festival_gate_store.dart';
import 'package:flutter_core_project/services/localization_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('completes QR and manual entrance and gift operations',
      (tester) async {
    final api = _FakeFestivalApi();
    final tokenStore = _MemoryTokenStore('token');
    final auth = FestivalAuthService(api, tokenStore);
    final gateStore = _MemoryGateStore();
    var scannerInitializations = 0;
    var scannerDisposals = 0;

    await tester.pumpWidget(
      _localizedApp(
        FestivalScannerPage(
          apiService: api,
          authService: auth,
          gateStore: gateStore,
          scannerBuilder: (_, onCode) => _ScannerProbe(
            onCode: onCode,
            onInitialize: () => scannerInitializations += 1,
            onDispose: () => scannerDisposals += 1,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Chọn cổng check-in'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('festival_choose_gate')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cổng VIP 1'));
    await tester.pumpAndSettle();

    expect(gateStore.selected?.code, 'GATE_VIP_01');
    expect(find.text('Cổng VIP 1'), findsOneWidget);
    expect(find.text('Check in'), findsOneWidget);
    expect(find.byKey(const ValueKey('fake_qr_scan')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('festival_manual_mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('festival_manual_submit')));
    await tester.pump();
    expect(find.byKey(const ValueKey('festival_top_message')), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    await tester.enterText(
      find.byKey(const ValueKey('festival_manual_input')),
      '0901234567',
    );
    await tester.tap(find.byKey(const ValueKey('festival_manual_submit')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Check-in thành công'), findsOneWidget);
    expect(find.text('Ông Nguyễn Văn A'), findsOneWidget);
    expect(find.text('Xếp bàn cho khách'), findsOneWidget);
    expect(find.text('Bàn 01'), findsOneWidget);
    expect(find.text('Ghế 02'), findsOneWidget);
    expect(api.lastCode, '0901234567');
    expect(api.lastGateName, 'Cổng VIP 1');
    expect(api.lastNotes, contains('Manual'));

    await tester.ensureVisible(
      find.byKey(const ValueKey('festival_continue_checkin')),
    );
    await tester.tap(find.byKey(const ValueKey('festival_continue_checkin')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('festival_manual_input')), findsOneWidget);
    expect(find.text('Ông Nguyễn Văn A'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('festival_qr_mode')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('fake_qr_scan')));
    await tester.pumpAndSettle();

    expect(api.lastCode, 'QR001');
    expect(api.lastGateName, 'Cổng VIP 1');
    expect(api.lastNotes, contains('QR'));
    expect(find.text('Check-in thành công'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('festival_continue_checkin')),
    );
    await tester.tap(find.byKey(const ValueKey('festival_continue_checkin')));
    await tester.pumpAndSettle();
    final initializationsBeforeOperationChange = scannerInitializations;
    final disposalsBeforeOperationChange = scannerDisposals;
    await tester.tap(find.byKey(const ValueKey('festival_gift_operation')));
    await tester.pumpAndSettle();

    expect(scannerInitializations, initializationsBeforeOperationChange);
    expect(scannerDisposals, disposalsBeforeOperationChange);
    expect(find.text('Nhận quà'), findsOneWidget);
    expect(find.byKey(const ValueKey('fake_qr_scan')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('fake_qr_scan')));
    await tester.pumpAndSettle();

    expect(api.lastCode, 'QR001');
    expect(api.lastGateName, 'Cổng VIP 1');
    expect(api.giftSaves, [0]);
    expect(find.text('Kiểm tra thông tin nhận quà'), findsOneWidget);
    expect(find.text('Trao quà thành công'), findsNothing);
    expect(find.text('Ghi chú quà tặng'), findsOneWidget);
    expect(find.text('Bộ quà tặng VIP đối tác'), findsOneWidget);
    expect(
      find.text('QR gift redemption from My THP Festival'),
      findsNothing,
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('festival_confirm_operation')),
    );
    await tester.tap(find.byKey(const ValueKey('festival_confirm_operation')));
    await tester.pumpAndSettle();
    expect(api.giftSaves, [0, 1]);
    expect(find.text('Trao quà thành công'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('festival_continue_checkin')),
    );
    await tester.tap(find.byKey(const ValueKey('festival_continue_checkin')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('festival_manual_mode')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('festival_manual_input')),
      '0912000001',
    );
    await tester.tap(find.byKey(const ValueKey('festival_manual_submit')));
    await tester.pumpAndSettle();

    expect(api.lastCode, '0912000001');
    expect(find.text('Kiểm tra thông tin nhận quà'), findsOneWidget);
    expect(find.text('Ghi chú quà tặng'), findsNothing);
    expect(
      find.byKey(const ValueKey('festival_gift_information')),
      findsNothing,
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('festival_confirm_operation')),
    );
    await tester.tap(find.byKey(const ValueKey('festival_confirm_operation')));
    await tester.pumpAndSettle();
    expect(api.giftSaves.sublist(api.giftSaves.length - 2), [0, 1]);
    expect(find.text('Trao quà thành công'), findsOneWidget);

    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _localizedApp(
        FestivalScannerPage(
          key: const ValueKey('festival_dark_small_screen'),
          apiService: api,
          authService: auth,
          gateStore: gateStore,
          scannerBuilder: (_, __) => const ColoredBox(color: Colors.black),
        ),
        themeMode: ThemeMode.dark,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('festival_gift_operation')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('festival_manual_mode')));
    await tester.pumpAndSettle();

    expect(find.text('Nhận quà thủ công'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.binding.setSurfaceSize(null);
    await tester.tap(find.byKey(const ValueKey('festival_checkin_operation')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('festival_manual_input')),
      'QR001',
    );
    await tester.tap(find.byKey(const ValueKey('festival_manual_submit')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('festival_guest_color')), findsOneWidget);
    expect(find.text('Nhóm đỏ'), findsOneWidget);
    final colorCard = tester.widget<Container>(
      find.byKey(const ValueKey('festival_guest_color')),
    );
    expect((colorCard.decoration! as BoxDecoration).color,
        const Color(0xFFFEE2E2));
    expect(find.text('Tổng khách hiện tại'), findsOneWidget);
    expect(find.text('SL trên QR (tham khảo)'), findsOneWidget);
    expect(find.text('Số bàn đã xếp'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('festival_table_guest_count_1')),
      findsOneWidget,
    );
    expect(find.text('2 khách'), findsOneWidget);

    await tester
        .ensureVisible(find.byKey(const ValueKey('festival_assign_table')));
    await tester.tap(find.byKey(const ValueKey('festival_assign_table')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('festival_zone_Khu A')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('festival_table_2')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('festival_seat_count')), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('festival_seat_count')),
      '11',
    );
    await tester.pumpAndSettle();
    expect(
        find.textContaining('Số khách tối đa của bàn là 10'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('festival_confirm_assign')),
          )
          .onPressed,
      isNull,
    );
    await tester.enterText(
      find.byKey(const ValueKey('festival_seat_count')),
      '5',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('festival_confirm_assign')));
    await tester.pumpAndSettle();

    expect(find.text('Bàn A-02'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('5 khách'), findsOneWidget);
    expect(find.byKey(const ValueKey('festival_assign_table')), findsOneWidget);
    await tester
        .ensureVisible(find.byKey(const ValueKey('festival_change_table_2')));
    await tester.tap(find.byKey(const ValueKey('festival_change_table_2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('festival_zone_Khu B')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('festival_table_3')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xác nhận').last);
    await tester.pumpAndSettle();

    expect(find.text('Bàn B-01'), findsOneWidget);
    await tester
        .ensureVisible(find.byKey(const ValueKey('festival_remove_table_3')));
    await tester.tap(find.byKey(const ValueKey('festival_remove_table_3')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gỡ bàn').last);
    await tester.pumpAndSettle();

    expect(find.text('Bàn B-01'), findsNothing);
    expect(find.text('2 khách'), findsOneWidget);

    await tester
        .ensureVisible(find.byKey(const ValueKey('festival_remove_table_1')));
    await tester.tap(find.byKey(const ValueKey('festival_remove_table_1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gỡ bàn').last);
    await tester.pumpAndSettle();
    expect(find.text('0'), findsWidgets);

    await tester
        .ensureVisible(find.byKey(const ValueKey('festival_assign_table')));
    await tester.tap(find.byKey(const ValueKey('festival_assign_table')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('festival_zone_Khu B')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('festival_table_3')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('festival_seat_count')),
      '8',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('festival_confirm_assign')));
    await tester.pumpAndSettle();
    expect(find.text('8 khách'), findsOneWidget);
    expect(find.byKey(const ValueKey('festival_assign_table')), findsOneWidget);

    ScaffoldMessenger.of(
      tester.element(find.byKey(const ValueKey('festival_continue_checkin'))),
    ).clearSnackBars();
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('festival_continue_checkin')),
    );
    await tester.tap(find.byKey(const ValueKey('festival_continue_checkin')));
    await tester.pumpAndSettle();
    api.searchGuestOverrideCode = 'OTHER001';
    await tester.enterText(
      find.byKey(const ValueKey('festival_manual_input')),
      'QR001',
    );
    await tester.tap(find.byKey(const ValueKey('festival_manual_submit')));
    await tester.pumpAndSettle();
    expect(find.textContaining('không khớp mã khách'), findsOneWidget);
    expect(find.byKey(const ValueKey('festival_assign_table')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Widget _localizedApp(
  Widget home, {
  ThemeMode themeMode = ThemeMode.light,
}) =>
    MaterialApp(
      locale: const Locale('vi'),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      supportedLocales: const [Locale('vi'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    );

class _FakeFestivalApi extends FestivalApiService {
  _FakeFestivalApi() : super(Dio());

  String? lastCode;
  String? lastGateName;
  String? lastNotes;
  final List<int> giftSaves = [];
  String? searchGuestOverrideCode;
  final List<FestivalAssignedTable> seating = [
    const FestivalAssignedTable(
      tableId: 1,
      tableName: 'Bàn 01',
      zone: 'Khu A',
      seatCount: 2,
    ),
  ];

  @override
  Future<List<FestivalPrefixColor>> getPrefixColors({
    required String accessToken,
    required int eventId,
  }) async =>
      const [
        FestivalPrefixColor(
          prefixCode: 'QR',
          bgColor: '#FEE2E2',
          textColor: '#991B1B',
          note: 'Nhóm đỏ',
        ),
      ];

  @override
  Future<FestivalHotlineGuest> searchGuestForSeating({
    required String accessToken,
    required int eventId,
    required String keyword,
  }) async {
    final assigned =
        seating.fold<int>(0, (sum, table) => sum + table.seatCount);
    return FestivalHotlineGuest(
      id: 5610,
      guestCode: searchGuestOverrideCode ?? 'QR001',
      fullName: 'Ông Nguyễn Văn A',
      numberInvited: 3,
      totalAssignedSeats: assigned,
      remainingNeededSeats: 3 - assigned,
      prefixColor: const FestivalPrefixColor(
        prefixCode: 'QR',
        bgColor: '#FEE2E2',
        textColor: '#991B1B',
        note: 'Nhóm đỏ',
      ),
      assignedTables: List.of(seating),
    );
  }

  @override
  Future<List<FestivalSeatingZone>> getSeatingZones({
    required String accessToken,
    required int eventId,
    String? zone,
  }) async {
    const zones = [
      FestivalSeatingZone(
        name: 'Khu A',
        color: '#F59E0B',
        tables: [
          FestivalSeatingTable(
            id: 1,
            name: 'Bàn 01',
            zone: 'Khu A',
            capacity: 10,
            occupiedSeats: 2,
            availableSeats: 8,
            isFull: false,
          ),
          FestivalSeatingTable(
            id: 2,
            name: 'Bàn A-02',
            zone: 'Khu A',
            capacity: 10,
            occupiedSeats: 0,
            availableSeats: 10,
            isFull: false,
          ),
        ],
      ),
      FestivalSeatingZone(
        name: 'Khu B',
        color: '#1E40AF',
        tables: [
          FestivalSeatingTable(
            id: 3,
            name: 'Bàn B-01',
            zone: 'Khu B',
            capacity: 10,
            occupiedSeats: 0,
            availableSeats: 10,
            isFull: false,
          ),
        ],
      ),
    ];
    return zone == null
        ? zones
        : zones.where((item) => item.name == zone).toList();
  }

  @override
  Future<String> assignSeatingTable({
    required String accessToken,
    required int eventId,
    required int guestId,
    required int tableId,
    required int seatCount,
    String staffName = 'My THP Festival',
  }) async {
    seating.add(FestivalAssignedTable(
      tableId: tableId,
      tableName: tableId == 2 ? 'Bàn A-02' : 'Bàn B-01',
      zone: tableId == 2 ? 'Khu A' : 'Khu B',
      seatCount: seatCount,
    ));
    return 'Đã gán bàn';
  }

  @override
  Future<String> changeSeatingTable({
    required String accessToken,
    required int eventId,
    required int guestId,
    required int oldTableId,
    required int newTableId,
    required int seatCount,
    String staffName = 'My THP Festival',
  }) async {
    seating.removeWhere((table) => table.tableId == oldTableId);
    seating.add(FestivalAssignedTable(
      tableId: newTableId,
      tableName: 'Bàn B-01',
      zone: 'Khu B',
      seatCount: seatCount,
    ));
    return 'Đã chuyển bàn';
  }

  @override
  Future<String> unassignSeatingTable({
    required String accessToken,
    required int eventId,
    required int guestId,
    required int tableId,
  }) async {
    seating.removeWhere((table) => table.tableId == tableId);
    return 'Đã gỡ bàn';
  }

  @override
  Future<List<FestivalGate>> getGates({
    required String accessToken,
    int? eventId,
  }) async =>
      const [
        FestivalGate(
          id: 1,
          name: 'Cổng Chính',
          code: 'GATE_MAIN',
        ),
        FestivalGate(
          id: 2,
          name: 'Cổng VIP 1',
          code: 'GATE_VIP_01',
        ),
      ];

  @override
  Future<FestivalCheckInResult> checkIn({
    required String code,
    required String accessToken,
    required String gateName,
    String notes = 'Check-in từ My THP Festival',
  }) async {
    lastCode = code;
    lastGateName = gateName;
    lastNotes = notes;
    return const FestivalCheckInResult(
      success: true,
      alreadyCheckedIn: false,
      message: 'Check-in thành công!',
      fullName: 'Ông Nguyễn Văn A',
      company: 'THP',
      guestCode: 'QR001',
      tableName: 'Bàn 01',
      tableSeat: 'Ghế 02',
    );
  }

  @override
  Future<FestivalGiftCheckInResult> giftCheckIn({
    required String code,
    required String accessToken,
    required String gateName,
    int isSave = 0,
  }) async {
    lastCode = code;
    lastGateName = gateName;
    giftSaves.add(isSave);
    return FestivalGiftCheckInResult(
      success: true,
      alreadyReceived: false,
      message: 'Trao quà thành công!',
      fullName: 'Ông Nguyễn Văn A',
      company: 'THP',
      guestCode: 'QR001',
      giftReceivedDate: '09:10',
      giftGateName: 'Cổng VIP 1',
      tableName: 'Bàn 01',
      tableSeat: 'Ghế 02',
      giftStatus: 1,
      giftNote: code == '0912000001' ? null : 'Bộ quà tặng VIP đối tác',
    );
  }
}

class _MemoryTokenStore implements FestivalTokenStore {
  String? token;

  _MemoryTokenStore(this.token);

  @override
  Future<void> deleteToken() async => token = null;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String value) async => token = value;
}

class _MemoryGateStore implements FestivalGateStore {
  FestivalGate? selected;

  @override
  Future<void> clearSelectedGate() async => selected = null;

  @override
  Future<FestivalGate?> readSelectedGate() async => selected;

  @override
  Future<void> saveSelectedGate(FestivalGate gate) async => selected = gate;
}

class _ScannerProbe extends StatefulWidget {
  final ValueChanged<String> onCode;
  final VoidCallback onInitialize;
  final VoidCallback onDispose;

  const _ScannerProbe({
    required this.onCode,
    required this.onInitialize,
    required this.onDispose,
  });

  @override
  State<_ScannerProbe> createState() => _ScannerProbeState();
}

class _ScannerProbeState extends State<_ScannerProbe> {
  @override
  void initState() {
    super.initState();
    widget.onInitialize();
  }

  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: FilledButton(
          key: const ValueKey('fake_qr_scan'),
          onPressed: () => widget.onCode('QR001'),
          child: const Text('Fake scan'),
        ),
      ),
    );
  }
}
