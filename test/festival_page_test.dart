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
    await tester.enterText(
      find.byKey(const ValueKey('festival_manual_input')),
      '0901234567',
    );
    await tester.tap(find.byKey(const ValueKey('festival_manual_submit')));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Check-in thành công'), findsOneWidget);
    expect(find.text('Ông Nguyễn Văn A'), findsOneWidget);
    expect(find.text('Vị trí chỗ ngồi'), findsOneWidget);
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
    expect(api.lastNotes, contains('QR gift'));
    expect(find.text('Trao quà thành công'), findsOneWidget);
    expect(find.text('Thông tin quà tặng'), findsOneWidget);
    expect(find.text('Bộ quà tặng VIP đối tác'), findsOneWidget);

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
    expect(api.lastNotes, contains('Manual gift'));
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
    String notes = 'Gift redemption from My THP Festival',
  }) async {
    lastCode = code;
    lastGateName = gateName;
    lastNotes = notes;
    return const FestivalGiftCheckInResult(
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
      giftNote: 'Bộ quà tặng VIP đối tác',
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
