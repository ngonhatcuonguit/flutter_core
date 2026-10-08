import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_core_project/common/helpers/is_dark_mode.dart';
import 'package:flutter_core_project/core/configs/app_config.dart';
import 'package:flutter_core_project/core/configs/theme/app_colors.dart';
import 'package:flutter_core_project/data/data_sources/remote/festival_api_service.dart';
import 'package:flutter_core_project/data/models/festival/festival_models.dart';
import 'package:flutter_core_project/injection_container.dart';
import 'package:flutter_core_project/services/festival_auth_service.dart';
import 'package:flutter_core_project/services/festival_gate_store.dart';
import 'package:flutter_core_project/services/localization_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

typedef FestivalScannerBuilder = Widget Function(
  BuildContext context,
  ValueChanged<String> onCode,
);

enum FestivalCheckInMode { qr, manual }

enum FestivalOperation { guestCheckIn, giftRedemption }

Future<void> _festivalCameraTransition = Future<void>.value();

Future<void> _queueFestivalCameraTransition(
  Future<void> Function() transition,
) {
  final next = _festivalCameraTransition.then((_) => transition());
  _festivalCameraTransition = next.catchError((Object _) {});
  return next;
}

ButtonStyle _festivalPrimaryButtonStyle({double height = 52}) {
  return FilledButton.styleFrom(
    minimumSize: Size.fromHeight(height),
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  );
}

class FestivalScannerPage extends StatefulWidget {
  final FestivalApiService? apiService;
  final FestivalAuthService? authService;
  final FestivalGateStore? gateStore;
  final FestivalScannerBuilder? scannerBuilder;
  final int? eventId;

  const FestivalScannerPage({
    super.key,
    this.apiService,
    this.authService,
    this.gateStore,
    this.scannerBuilder,
    this.eventId,
  });

  @override
  State<FestivalScannerPage> createState() => _FestivalScannerPageState();
}

class _FestivalScannerPageState extends State<FestivalScannerPage> {
  late final FestivalApiService _api =
      widget.apiService ?? sl<FestivalApiService>();
  late final FestivalAuthService _auth =
      widget.authService ?? sl<FestivalAuthService>();
  late final FestivalGateStore _gateStore =
      widget.gateStore ?? sl<FestivalGateStore>();
  int get _eventId => widget.eventId ?? AppConfig.festivalEventId;

  final _manualController = TextEditingController();
  List<FestivalGate> _gates = const [];
  FestivalGate? _selectedGate;
  FestivalOperation _operation = FestivalOperation.guestCheckIn;
  FestivalCheckInMode _mode = FestivalCheckInMode.qr;
  Object? _result;
  bool _loadingGates = true;
  bool _processing = false;
  bool _sessionExpired = false;
  String? _loadError;
  FestivalHotlineGuest? _seatingGuest;
  List<FestivalPrefixColor> _prefixColors = const [];
  String? _seatingError;
  String? _currentGuestCode;
  bool _loadingSeating = false;
  bool _savingSeating = false;
  int _scanSerial = 0;

  @override
  void initState() {
    super.initState();
    _loadGates();
  }

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  Future<void> _loadGates() async {
    setState(() {
      _loadingGates = true;
      _loadError = null;
      _sessionExpired = false;
    });
    try {
      final token = await _auth.getAccessToken();
      if (token == null) throw const FestivalUnauthorizedException();
      final values = await Future.wait<Object?>([
        _api.getGates(accessToken: token),
        _gateStore.readSelectedGate(),
      ]);
      final gates = values[0] as List<FestivalGate>;
      final savedGate = values[1] as FestivalGate?;
      FestivalGate? selected;
      if (savedGate != null) {
        for (final gate in gates) {
          if (gate.id == savedGate.id ||
              (gate.code.isNotEmpty && gate.code == savedGate.code)) {
            selected = gate;
            break;
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _gates = gates;
        _selectedGate = selected;
        _loadingGates = false;
        _loadError = gates.isEmpty ? context.tr('festival_gate_empty') : null;
      });
      unawaited(_loadPrefixColors(token));
    } on FestivalUnauthorizedException {
      await _auth.logout();
      if (!mounted) return;
      setState(() {
        _loadingGates = false;
        _sessionExpired = true;
        _loadError = context.tr('festival_session_expired');
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingGates = false;
        _loadError = context.tr('festival_gate_load_failed');
      });
    }
  }

  Future<void> _loadPrefixColors(String token) async {
    try {
      final colors = await _api.getPrefixColors(
        accessToken: token,
        eventId: _eventId,
      );
      if (mounted) setState(() => _prefixColors = colors);
    } catch (_) {
      // Guest lookup also returns its resolved PrefixColor.
    }
  }

  Future<void> _selectGate([FestivalGate? initialValue]) async {
    if (_gates.isEmpty) return;
    final selected = await showModalBottomSheet<FestivalGate>(
      context: context,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _GatePickerSheet(
        gates: _gates,
        selected: initialValue ?? _selectedGate,
      ),
    );
    if (selected == null) return;
    await _gateStore.saveSelectedGate(selected);
    if (!mounted) return;
    setState(() {
      _selectedGate = selected;
      _result = null;
    });
  }

  Future<void> _processCode(String rawCode, {required bool manual}) async {
    final code = rawCode.trim();
    final gate = _selectedGate;
    if (_processing || code.isEmpty || gate == null) return;
    FocusScope.of(context).unfocus();
    final scanSerial = ++_scanSerial;
    setState(() {
      _processing = true;
      _result = null;
      _seatingGuest = null;
      _seatingError = null;
      _currentGuestCode = null;
      _loadingSeating = false;
    });

    try {
      final token = await _auth.getAccessToken();
      if (token == null) throw const FestivalUnauthorizedException();
      final Object result;
      if (_operation == FestivalOperation.giftRedemption) {
        result = await _api.giftCheckIn(
          code: code,
          accessToken: token,
          gateName: gate.name,
          notes: manual
              ? 'Manual gift redemption from My THP Festival'
              : 'QR gift redemption from My THP Festival',
        );
      } else {
        result = await _api.checkIn(
          code: code,
          accessToken: token,
          gateName: gate.name,
          notes: manual
              ? 'Manual check-in from My THP Festival'
              : 'QR check-in from My THP Festival',
        );
      }
      if (!mounted) return;
      setState(() => _result = result);
      if (result is FestivalCheckInResult &&
          (result.success || result.alreadyCheckedIn)) {
        final guestCode = result.guestCode ?? code;
        _currentGuestCode = guestCode;
        unawaited(_loadSeating(guestCode, scanSerial));
      }
    } on FestivalUnauthorizedException {
      await _auth.logout();
      if (!mounted) return;
      setState(() => _sessionExpired = true);
    } on FestivalApiException {
      if (!mounted) return;
      setState(() => _result = _failureResult('festival_operation_failed'));
    } catch (_) {
      if (!mounted) return;
      setState(() => _result = _failureResult('festival_error_generic'));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _loadSeating(String guestCode, int scanSerial) async {
    if (!mounted || scanSerial != _scanSerial) return;
    setState(() {
      _loadingSeating = true;
      _seatingError = null;
      _seatingGuest = null;
    });
    try {
      final token = await _auth.getAccessToken();
      if (token == null) throw const FestivalUnauthorizedException();
      final guest = await _api.searchGuestForSeating(
        accessToken: token,
        eventId: _eventId,
        keyword: guestCode,
      );
      if (!mounted || scanSerial != _scanSerial) return;
      final checkInResult = _result;
      if (checkInResult is FestivalCheckInResult &&
          ((checkInResult.guestId != null &&
                  checkInResult.guestId != guest.id) ||
              (checkInResult.guestCode != null &&
                  checkInResult.guestCode!.toUpperCase() !=
                      guest.guestCode.toUpperCase()))) {
        throw FestivalApiException(
          context.tr('festival_seating_guest_mismatch'),
        );
      }
      setState(() => _seatingGuest = guest);
    } on FestivalUnauthorizedException {
      if (!mounted || scanSerial != _scanSerial) return;
      setState(() => _seatingError = context.tr('festival_session_expired'));
    } on FestivalApiException catch (error) {
      if (!mounted || scanSerial != _scanSerial) return;
      setState(() => _seatingError = error.message);
    } catch (_) {
      if (!mounted || scanSerial != _scanSerial) return;
      setState(
          () => _seatingError = context.tr('festival_seating_load_failed'));
    } finally {
      if (mounted && scanSerial == _scanSerial) {
        setState(() => _loadingSeating = false);
      }
    }
  }

  void _retrySeating() {
    final code = _currentGuestCode;
    if (code != null) unawaited(_loadSeating(code, _scanSerial));
  }

  Future<FestivalSeatingTable?> _pickSeatingTable({
    required int minSeats,
    int? excludeTableId,
  }) async {
    final token = await _auth.getAccessToken();
    if (token == null) throw const FestivalUnauthorizedException();
    if (!mounted) return null;
    final zone = await showModalBottomSheet<FestivalSeatingZone>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FestivalZonePickerSheet(
        minSeats: minSeats,
        excludeTableId: excludeTableId,
        loadZones: () => _api.getSeatingZones(
          accessToken: token,
          eventId: _eventId,
        ),
      ),
    );
    if (zone == null || !mounted) return null;
    return showModalBottomSheet<FestivalSeatingTable>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FestivalTablePickerSheet(
        zoneName: zone.name,
        minSeats: minSeats,
        excludeTableId: excludeTableId,
        loadZones: () => _api.getSeatingZones(
          accessToken: token,
          eventId: _eventId,
          zone: zone.name,
        ),
      ),
    );
  }

  Future<void> _assignTable() async {
    final guest = _seatingGuest;
    if (guest == null || guest.remainingNeededSeats <= 0 || _savingSeating) {
      return;
    }
    try {
      final table = await _pickSeatingTable(minSeats: 1);
      if (table == null || !mounted) return;
      final maxSeats = guest.remainingNeededSeats < table.availableSeats
          ? guest.remainingNeededSeats
          : table.availableSeats;
      final count = await showDialog<int>(
        context: context,
        builder: (_) => _FestivalSeatConfirmationDialog(
          guestName: guest.fullName,
          tableName: table.name,
          zoneName: table.zone,
          maxSeats: maxSeats,
          availableSeats: table.availableSeats,
        ),
      );
      if (count == null || !mounted) return;
      await _runSeatingMutation((token) => _api.assignSeatingTable(
            accessToken: token,
            eventId: _eventId,
            guestId: guest.id,
            tableId: table.id,
            seatCount: count,
          ));
    } on FestivalApiException catch (error) {
      _showSeatingMessage(error.message);
    } catch (_) {
      if (mounted) {
        _showSeatingMessage(context.tr('festival_seating_load_failed'));
      }
    }
  }

  Future<void> _changeTable(FestivalAssignedTable assigned) async {
    final guest = _seatingGuest;
    if (guest == null || _savingSeating) return;
    try {
      final table = await _pickSeatingTable(
        minSeats: assigned.seatCount,
        excludeTableId: assigned.tableId,
      );
      if (table == null || !mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(context.tr('festival_move_table')),
          content: Text(
            '${assigned.tableName} → ${table.name} (${table.zone})\n'
            '${assigned.seatCount} ${context.tr('festival_seat_unit')}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.tr('festival_cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(context.tr('festival_confirm')),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
      await _runSeatingMutation((token) => _api.changeSeatingTable(
            accessToken: token,
            eventId: _eventId,
            guestId: guest.id,
            oldTableId: assigned.tableId,
            newTableId: table.id,
            seatCount: assigned.seatCount,
          ));
    } on FestivalApiException catch (error) {
      _showSeatingMessage(error.message);
    } catch (_) {
      if (mounted) {
        _showSeatingMessage(context.tr('festival_seating_load_failed'));
      }
    }
  }

  Future<void> _unassignTable(FestivalAssignedTable assigned) async {
    final guest = _seatingGuest;
    if (guest == null || _savingSeating) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('festival_remove_table')),
        content: Text(
          '${guest.fullName} • ${assigned.tableName}\n'
          '${assigned.seatCount} ${context.tr('festival_seat_unit')}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('festival_cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.tr('festival_remove_table')),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _runSeatingMutation((token) => _api.unassignSeatingTable(
          accessToken: token,
          eventId: _eventId,
          guestId: guest.id,
          tableId: assigned.tableId,
        ));
  }

  Future<void> _runSeatingMutation(
    Future<String> Function(String token) action,
  ) async {
    if (_savingSeating) return;
    setState(() => _savingSeating = true);
    try {
      final token = await _auth.getAccessToken();
      if (token == null) throw const FestivalUnauthorizedException();
      final message = await action(token);
      final code = _currentGuestCode;
      if (code != null) await _loadSeating(code, _scanSerial);
      _showSeatingMessage(message);
    } on FestivalApiException catch (error) {
      _showSeatingMessage(error.message);
    } catch (_) {
      if (mounted) {
        _showSeatingMessage(context.tr('festival_seating_save_failed'));
      }
    } finally {
      if (mounted) setState(() => _savingSeating = false);
    }
  }

  void _showSeatingMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Object _failureResult(String messageKey) {
    final message = context.tr(messageKey);
    if (_operation == FestivalOperation.giftRedemption) {
      return FestivalGiftCheckInResult(
        success: false,
        alreadyReceived: false,
        message: message,
      );
    }
    return FestivalCheckInResult(
      success: false,
      alreadyCheckedIn: false,
      message: message,
    );
  }

  void _continueCheckIn() {
    _manualController.clear();
    ++_scanSerial;
    setState(() {
      _result = null;
      _seatingGuest = null;
      _seatingError = null;
      _currentGuestCode = null;
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('festival_logout_title')),
        content: Text(context.tr('festival_logout_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tr('festival_cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.tr('festival_logout')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _auth.logout();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
        title: Text(context.tr('festival_title')),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
        actions: [
          IconButton(
            tooltip: context.tr('festival_logout'),
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loadingGates) {
      return _CenteredStatus(
        icon: Icons.door_front_door_outlined,
        label: context.tr('festival_gate_loading'),
        loading: true,
      );
    }
    if (_loadError != null) {
      return _CenteredStatus(
        icon: _sessionExpired
            ? Icons.lock_clock_outlined
            : Icons.cloud_off_outlined,
        label: _loadError!,
        actionLabel: _sessionExpired
            ? context.tr('festival_close')
            : context.tr('festival_retry'),
        onAction:
            _sessionExpired ? () => Navigator.of(context).pop() : _loadGates,
      );
    }
    if (_selectedGate == null) return _buildInitialGateSelection(context);
    if (_sessionExpired) {
      return _CenteredStatus(
        icon: Icons.lock_clock_outlined,
        label: context.tr('festival_session_expired'),
        actionLabel: context.tr('festival_close'),
        onAction: () => Navigator.of(context).pop(),
      );
    }
    if (_processing) {
      return _CenteredStatus(
        icon: Icons.cloud_upload_outlined,
        label: context.tr(
          _operation == FestivalOperation.giftRedemption
              ? 'festival_gift_processing'
              : 'festival_checkin_processing',
        ),
        loading: true,
      );
    }
    if (_result != null) {
      return _FestivalResultView(
        result: _result!,
        operation: _operation,
        onContinue: _continueCheckIn,
        seatingGuest: _seatingGuest,
        prefixColors: _prefixColors,
        loadingSeating: _loadingSeating,
        seatingError: _seatingError,
        savingSeating: _savingSeating,
        onRetrySeating: _retrySeating,
        onAssignTable: _assignTable,
        onChangeTable: _changeTable,
        onUnassignTable: _unassignTable,
      );
    }
    return _buildCheckIn(context);
  }

  Widget _buildInitialGateSelection(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.door_front_door_outlined,
                size: 42,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              context.tr('festival_choose_gate_title'),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('festival_choose_gate_description'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 26),
            FilledButton.icon(
              key: const ValueKey('festival_choose_gate'),
              onPressed: _selectGate,
              icon: const Icon(Icons.place_outlined),
              label: Text(context.tr('festival_choose_gate_action')),
              style: _festivalPrimaryButtonStyle(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckIn(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        _SelectedGateCard(
          gate: _selectedGate!,
          labelKey: _operation == FestivalOperation.giftRedemption
              ? 'festival_current_gift_station'
              : 'festival_current_gate',
          onChange: _selectGate,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 2, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: _ModeButton(
                  key: const ValueKey('festival_checkin_operation'),
                  selected: _operation == FestivalOperation.guestCheckIn,
                  icon: Icons.login_rounded,
                  label: context.tr('festival_operation_checkin'),
                  onTap: () => _changeOperation(
                    FestivalOperation.guestCheckIn,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ModeButton(
                  key: const ValueKey('festival_gift_operation'),
                  selected: _operation == FestivalOperation.giftRedemption,
                  icon: Icons.card_giftcard_rounded,
                  label: context.tr('festival_operation_gift'),
                  onTap: () => _changeOperation(
                    FestivalOperation.giftRedemption,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: _ModeButton(
                  key: const ValueKey('festival_qr_mode'),
                  selected: _mode == FestivalCheckInMode.qr,
                  icon: Icons.qr_code_scanner_rounded,
                  label: context.tr(
                    _operation == FestivalOperation.giftRedemption
                        ? 'festival_gift_scan_qr'
                        : 'festival_scan_qr',
                  ),
                  onTap: () => _changeCheckInMode(FestivalCheckInMode.qr),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ModeButton(
                  key: const ValueKey('festival_manual_mode'),
                  selected: _mode == FestivalCheckInMode.manual,
                  icon: Icons.keyboard_alt_outlined,
                  label: context.tr('festival_manual'),
                  onTap: () => _changeCheckInMode(
                    FestivalCheckInMode.manual,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: _mode == FestivalCheckInMode.qr
                ? _buildScanner(context, colors)
                : _buildManualForm(context),
          ),
        ),
      ],
    );
  }

  void _changeOperation(FestivalOperation operation) {
    if (_operation == operation) return;
    _manualController.clear();
    ++_scanSerial;
    setState(() {
      _operation = operation;
      _result = null;
      _seatingGuest = null;
      _seatingError = null;
      _currentGuestCode = null;
    });
  }

  void _changeCheckInMode(FestivalCheckInMode mode) {
    if (_mode == mode) return;
    setState(() => _mode = mode);
  }

  Widget _buildScanner(BuildContext context, ColorScheme colors) {
    final scanner = widget.scannerBuilder?.call(
          context,
          (code) => _processCode(code, manual: false),
        ) ??
        _FestivalCameraScanner(
          onCode: (code) => _processCode(code, manual: false),
        );
    return Column(
      key: const ValueKey('festival_qr_content'),
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: scanner,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          child: Text(
            context.tr(
              _operation == FestivalOperation.giftRedemption
                  ? 'festival_gift_scan_hint'
                  : 'festival_scan_hint',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildManualForm(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return SingleChildScrollView(
      key: const ValueKey('festival_manual_content'),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.contact_page_outlined,
            size: 62,
            color: AppColors.primary,
          ),
          const SizedBox(height: 18),
          Text(
            context.tr(
              _operation == FestivalOperation.giftRedemption
                  ? 'festival_gift_manual_title'
                  : 'festival_manual_title',
            ),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr(
              _operation == FestivalOperation.giftRedemption
                  ? 'festival_gift_manual_description'
                  : 'festival_manual_description',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.onSurfaceVariant, height: 1.4),
          ),
          const SizedBox(height: 24),
          TextField(
            key: const ValueKey('festival_manual_input'),
            controller: _manualController,
            autofocus: false,
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.text,
            onSubmitted: (_) => _submitManual(),
            decoration: InputDecoration(
              labelText: context.tr('festival_manual_field'),
              hintText: context.tr('festival_manual_hint'),
              prefixIcon: const Icon(Icons.badge_outlined),
              filled: true,
              fillColor:
                  context.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: context.isDarkMode ? Colors.white24 : Colors.black12,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            key: const ValueKey('festival_manual_submit'),
            onPressed: _submitManual,
            icon: Icon(
              _operation == FestivalOperation.giftRedemption
                  ? Icons.card_giftcard_rounded
                  : Icons.login_rounded,
            ),
            label: Text(
              context.tr(
                _operation == FestivalOperation.giftRedemption
                    ? 'festival_gift_action'
                    : 'festival_checkin_action',
              ),
            ),
            style: _festivalPrimaryButtonStyle(),
          ),
        ],
      ),
    );
  }

  void _submitManual() {
    if (_manualController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('festival_manual_required'))),
      );
      return;
    }
    _processCode(_manualController.text, manual: true);
  }
}

class _SelectedGateCard extends StatelessWidget {
  final FestivalGate gate;
  final String labelKey;
  final VoidCallback onChange;

  const _SelectedGateCard({
    required this.gate,
    required this.labelKey,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final surface = context.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.primary.withOpacity(0.24)),
        boxShadow: context.isDarkMode
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          const Icon(Icons.place_outlined, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(labelKey),
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  gate.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          TextButton(
            key: const ValueKey('festival_change_gate'),
            onPressed: onChange,
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: Text(context.tr('festival_change')),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ModeButton({
    super.key,
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final surface = context.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white;
    return Material(
      color: selected ? AppColors.primary : surface,
      elevation: selected || context.isDarkMode ? 0 : 1,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? Colors.white : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FestivalCameraScanner extends StatefulWidget {
  final ValueChanged<String> onCode;

  const _FestivalCameraScanner({required this.onCode});

  @override
  State<_FestivalCameraScanner> createState() => _FestivalCameraScannerState();
}

class _FestivalCameraScannerState extends State<_FestivalCameraScanner>
    with WidgetsBindingObserver {
  late final MobileScannerController _controller = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    formats: const [BarcodeFormat.qrCode],
  );
  StreamSubscription<BarcodeCapture>? _barcodeSubscription;
  bool _disposed = false;
  bool _controllerReleased = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _barcodeSubscription = _controller.barcodes.listen(_handleCapture);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_startCamera());
    });
  }

  void _handleCapture(BarcodeCapture capture) {
    if (_disposed) return;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue?.trim();
      if (value != null && value.isNotEmpty) {
        widget.onCode(value);
        return;
      }
    }
  }

  Future<void> _startCamera() {
    return _queueFestivalCameraTransition(() async {
      if (_disposed ||
          _controllerReleased ||
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
        return;
      }
      await _controller.start();
    });
  }

  Future<void> _stopCamera() {
    return _queueFestivalCameraTransition(() async {
      if (_controllerReleased) return;
      await _controller.stop();
    });
  }

  Future<void> _releaseCamera() {
    return _queueFestivalCameraTransition(() async {
      if (_controllerReleased) return;
      await _controller.stop();
      await _controller.dispose();
      _controllerReleased = true;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed) return;
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(_startCamera());
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        unawaited(_stopCamera());
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_barcodeSubscription?.cancel());
    _barcodeSubscription = null;
    unawaited(_releaseCamera());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: Colors.black),
        MobileScanner(
          controller: _controller,
          placeholderBuilder: (_, __) => const ColoredBox(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          errorBuilder: (context, _, __) => ColoredBox(
            color: Colors.black,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.no_photography_outlined,
                      color: Colors.white,
                      size: 46,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr('festival_camera_error'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const IgnorePointer(
          child: CustomPaint(painter: _ScannerFramePainter()),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: ValueListenableBuilder<MobileScannerState>(
              valueListenable: _controller,
              builder: (_, state, __) => IconButton(
                tooltip: context.tr('festival_flashlight'),
                color: Colors.white,
                onPressed: state.isRunning &&
                        state.torchState != TorchState.unavailable
                    ? () => unawaited(_controller.toggleTorch())
                    : null,
                icon: Icon(
                  state.torchState == TorchState.on
                      ? Icons.flashlight_on_rounded
                      : Icons.flashlight_on_outlined,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScannerFramePainter extends CustomPainter {
  const _ScannerFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide * 0.68;
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: side,
      height: side,
    );
    final overlay = Paint()..color = Colors.black.withOpacity(0.42);
    final framePath = Path()
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(18)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(framePath, overlay);

    final frame = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const length = 34.0;
    canvas.drawLine(
        rect.topLeft, rect.topLeft + const Offset(length, 0), frame);
    canvas.drawLine(
        rect.topLeft, rect.topLeft + const Offset(0, length), frame);
    canvas.drawLine(
        rect.topRight, rect.topRight - const Offset(length, 0), frame);
    canvas.drawLine(
        rect.topRight, rect.topRight + const Offset(0, length), frame);
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + const Offset(length, 0),
      frame,
    );
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft - const Offset(0, length),
      frame,
    );
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight - const Offset(length, 0),
      frame,
    );
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight - const Offset(0, length),
      frame,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FestivalResultView extends StatelessWidget {
  final Object result;
  final FestivalOperation operation;
  final VoidCallback onContinue;
  final FestivalHotlineGuest? seatingGuest;
  final List<FestivalPrefixColor> prefixColors;
  final bool loadingSeating;
  final String? seatingError;
  final bool savingSeating;
  final VoidCallback onRetrySeating;
  final VoidCallback onAssignTable;
  final ValueChanged<FestivalAssignedTable> onChangeTable;
  final ValueChanged<FestivalAssignedTable> onUnassignTable;

  const _FestivalResultView({
    required this.result,
    required this.operation,
    required this.onContinue,
    required this.seatingGuest,
    required this.prefixColors,
    required this.loadingSeating,
    required this.seatingError,
    required this.savingSeating,
    required this.onRetrySeating,
    required this.onAssignTable,
    required this.onChangeTable,
    required this.onUnassignTable,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final checkInResult = result is FestivalCheckInResult
        ? result as FestivalCheckInResult
        : null;
    final giftResult = result is FestivalGiftCheckInResult
        ? result as FestivalGiftCheckInResult
        : null;
    assert(checkInResult != null || giftResult != null);

    final isGift = operation == FestivalOperation.giftRedemption;
    final isSuccess = checkInResult?.success ?? giftResult?.success ?? false;
    final isWarning =
        checkInResult?.alreadyCheckedIn ?? giftResult?.alreadyReceived ?? false;
    final fullName = checkInResult?.fullName ?? giftResult?.fullName;
    final company = checkInResult?.company ?? giftResult?.company;
    final position = checkInResult?.position ?? giftResult?.position;
    final vipLevel = checkInResult?.vipLevel ?? giftResult?.vipLevel;
    final vipName = checkInResult?.vipName ?? giftResult?.vipName;
    final guestCode = checkInResult?.guestCode ?? giftResult?.guestCode;
    FestivalPrefixColor? prefixColor = seatingGuest?.prefixColor;
    if (prefixColor == null && guestCode != null) {
      final matches = prefixColors
          .where((color) => guestCode
              .toUpperCase()
              .startsWith(color.prefixCode.toUpperCase()))
          .toList()
        ..sort((a, b) => b.prefixCode.length.compareTo(a.prefixCode.length));
      if (matches.isNotEmpty) prefixColor = matches.first;
    }
    final tableName = checkInResult?.tableName ?? giftResult?.tableName;
    final tableSeat = checkInResult?.tableSeat ?? giftResult?.tableSeat;
    final giftNote = giftResult?.giftNote;
    final message = checkInResult?.message ?? giftResult?.message ?? '';
    final actionTime = isGift
        ? giftResult?.giftReceivedDate
        : (checkInResult?.alreadyCheckedIn ?? false)
            ? checkInResult?.previousCheckInTime
            : checkInResult?.checkInTime;
    final actionGate = isGift
        ? giftResult?.giftGateName
        : (checkInResult?.alreadyCheckedIn ?? false)
            ? checkInResult?.previousGate
            : checkInResult?.gateName;
    final accent = isSuccess
        ? AppColors.primary
        : isWarning
            ? const Color(0xFFD97706)
            : theme.colorScheme.error;
    final icon = isSuccess
        ? Icons.check_circle_rounded
        : isWarning
            ? Icons.warning_amber_rounded
            : Icons.cancel_rounded;
    final titleKey = isGift
        ? isSuccess
            ? 'festival_gift_success'
            : isWarning
                ? 'festival_gift_already_received'
                : 'festival_gift_error'
        : isSuccess
            ? 'festival_checkin_success'
            : isWarning
                ? 'festival_already_checked_in'
                : 'festival_checkin_error';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color:
                  context.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: accent.withOpacity(0.32)),
              boxShadow: context.isDarkMode
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 14,
                        offset: Offset(0, 5),
                      ),
                    ],
            ),
            child: Column(
              children: [
                Icon(icon, size: 64, color: accent),
                const SizedBox(height: 12),
                Text(
                  context.tr(titleKey),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (fullName != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    fullName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                if (vipName != null || (vipLevel ?? 0) > 0) ...[
                  const SizedBox(height: 8),
                  Chip(
                    avatar: const Icon(Icons.workspace_premium, size: 18),
                    label: Text(
                      vipName ?? 'VIP $vipLevel',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
                if (company != null) ...[
                  const SizedBox(height: 8),
                  Text(company, textAlign: TextAlign.center),
                ],
                if (position != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    position,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
                if (guestCode != null) ...[
                  const SizedBox(height: 12),
                  SelectableText(
                    guestCode,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                if (!isGift && prefixColor != null) ...[
                  const SizedBox(height: 16),
                  _FestivalGuestColorBanner(color: prefixColor),
                ],
                if (giftNote != null) ...[
                  const SizedBox(height: 16),
                  _FestivalGiftInformationCard(giftNote: giftNote),
                ],
                if ((isGift || seatingGuest == null) &&
                    (tableName != null || tableSeat != null)) ...[
                  const SizedBox(height: 12),
                  _FestivalSeatingCard(
                    tableName: tableName,
                    tableSeat: tableSeat,
                  ),
                ],
                if (!isGift &&
                    seatingGuest != null &&
                    seatingGuest!.assignedTables.isNotEmpty &&
                    tableSeat != null) ...[
                  const SizedBox(height: 12),
                  Chip(
                    avatar: const Icon(Icons.event_seat_rounded, size: 18),
                    label: Text(tableSeat),
                  ),
                ],
                if (message.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(height: 1.4),
                  ),
                ],
                if (actionTime != null || actionGate != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    [actionTime, actionGate].whereType<String>().join(' • '),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (!isGift && (isSuccess || isWarning) && guestCode != null) ...[
            const SizedBox(height: 14),
            _FestivalSeatingPanel(
              guest: seatingGuest,
              loading: loadingSeating,
              error: seatingError,
              saving: savingSeating,
              onRetry: onRetrySeating,
              onAssign: onAssignTable,
              onChange: onChangeTable,
              onUnassign: onUnassignTable,
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            key: const ValueKey('festival_continue_checkin'),
            onPressed: savingSeating ? null : onContinue,
            icon: Icon(
              isGift
                  ? Icons.card_giftcard_rounded
                  : Icons.qr_code_scanner_rounded,
            ),
            label: Text(
              context.tr(
                isGift ? 'festival_continue_gift' : 'festival_continue_checkin',
              ),
            ),
            style: _festivalPrimaryButtonStyle(height: 54),
          ),
        ],
      ),
    );
  }
}

Color? _festivalHexColor(String? value) {
  if (value == null) return null;
  final hex = value.trim().replaceFirst('#', '');
  if (!RegExp(r'^[0-9a-fA-F]{6}$|^[0-9a-fA-F]{8}$').hasMatch(hex)) {
    return null;
  }
  return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
}

class _FestivalGuestColorBanner extends StatelessWidget {
  final FestivalPrefixColor color;

  const _FestivalGuestColorBanner({required this.color});

  @override
  Widget build(BuildContext context) {
    final background = _festivalHexColor(color.bgColor) ?? Colors.white;
    final foreground =
        _festivalHexColor(color.textColor) ?? const Color(0xFF1F2937);
    return Container(
      key: const ValueKey('festival_guest_color'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: foreground.withAlpha(80)),
      ),
      child: Row(
        children: [
          Icon(Icons.local_offer_rounded, color: foreground, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  color.prefixCode,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (color.note != null)
                  Text(
                    color.note!,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FestivalSeatingPanel extends StatelessWidget {
  final FestivalHotlineGuest? guest;
  final bool loading;
  final String? error;
  final bool saving;
  final VoidCallback onRetry;
  final VoidCallback onAssign;
  final ValueChanged<FestivalAssignedTable> onChange;
  final ValueChanged<FestivalAssignedTable> onUnassign;

  const _FestivalSeatingPanel({
    required this.guest,
    required this.loading,
    required this.error,
    required this.saving,
    required this.onRetry,
    required this.onAssign,
    required this.onChange,
    required this.onUnassign,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      key: const ValueKey('festival_seating_panel'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.table_restaurant_rounded,
                  color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.tr('festival_seating_management'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (loading || saving)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          if (guest == null) ...[
            const SizedBox(height: 12),
            Text(error ?? context.tr('festival_seating_loading')),
            if (error != null)
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(context.tr('festival_retry')),
              ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              '${context.tr('festival_invited_guests')}: ${guest!.numberInvited}  •  '
              '${context.tr('festival_assigned_seats')}: ${guest!.totalAssignedSeats}  •  '
              '${context.tr('festival_remaining_seats')}: ${guest!.remainingNeededSeats}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (guest!.assignedTables.isEmpty) ...[
              const SizedBox(height: 16),
              Text(context.tr('festival_no_table')),
            ],
            for (final table in guest!.assignedTables) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                      AppColors.primary.withAlpha(context.isDarkMode ? 38 : 15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      table.tableName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      [
                        if (table.zone != null) table.zone!,
                        '${table.seatCount} ${context.tr('festival_seat_unit')}',
                      ].join(' • '),
                    ),
                    if (table.seatsDescription != null &&
                        table.seatsDescription != '${table.seatCount} chỗ')
                      Text(table.seatsDescription!),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          key: ValueKey(
                              'festival_change_table_${table.tableId}'),
                          onPressed: saving ? null : () => onChange(table),
                          icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                          label: Text(context.tr('festival_move_table')),
                        ),
                        TextButton.icon(
                          key: ValueKey(
                              'festival_remove_table_${table.tableId}'),
                          onPressed: saving ? null : () => onUnassign(table),
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 18),
                          label: Text(context.tr('festival_remove_table')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            if (guest!.remainingNeededSeats > 0) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const ValueKey('festival_assign_table'),
                  onPressed: saving ? null : onAssign,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(context.tr('festival_assign_table')),
                ),
              ),
            ],
            if (error != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(context.tr('festival_retry')),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _FestivalZonePickerSheet extends StatefulWidget {
  final int minSeats;
  final int? excludeTableId;
  final Future<List<FestivalSeatingZone>> Function() loadZones;

  const _FestivalZonePickerSheet({
    required this.minSeats,
    this.excludeTableId,
    required this.loadZones,
  });

  @override
  State<_FestivalZonePickerSheet> createState() =>
      _FestivalZonePickerSheetState();
}

class _FestivalZonePickerSheetState extends State<_FestivalZonePickerSheet> {
  late Future<List<FestivalSeatingZone>> _future = widget.loadZones();

  @override
  Widget build(BuildContext context) {
    return _FestivalPickerFrame(
      title: context.tr('festival_choose_zone'),
      child: FutureBuilder<List<FestivalSeatingZone>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData && !snapshot.hasError) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: TextButton.icon(
                onPressed: () => setState(() => _future = widget.loadZones()),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(context.tr('festival_seating_load_failed')),
              ),
            );
          }
          final zones = snapshot.data!;
          if (zones.isEmpty) {
            return Center(child: Text(context.tr('festival_no_zones')));
          }
          return ListView.separated(
            itemCount: zones.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final zone = zones[index];
              final eligible = zone.tables.where((table) =>
                  table.id != widget.excludeTableId &&
                  !table.isFull &&
                  table.availableSeats >= widget.minSeats);
              final available = eligible.fold<int>(
                0,
                (sum, table) => sum + table.availableSeats,
              );
              return ListTile(
                key: ValueKey('festival_zone_${zone.name}'),
                leading: CircleAvatar(
                  backgroundColor:
                      _festivalHexColor(zone.color) ?? AppColors.primary,
                  radius: 13,
                ),
                title: Text(zone.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  '${eligible.length} ${context.tr('festival_table_unit')} • '
                  '$available ${context.tr('festival_seats_available')}',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                enabled: available >= widget.minSeats,
                onTap: available >= widget.minSeats
                    ? () => Navigator.pop(context, zone)
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}

class _FestivalTablePickerSheet extends StatefulWidget {
  final String zoneName;
  final int minSeats;
  final int? excludeTableId;
  final Future<List<FestivalSeatingZone>> Function() loadZones;

  const _FestivalTablePickerSheet({
    required this.zoneName,
    required this.minSeats,
    this.excludeTableId,
    required this.loadZones,
  });

  @override
  State<_FestivalTablePickerSheet> createState() =>
      _FestivalTablePickerSheetState();
}

class _FestivalTablePickerSheetState extends State<_FestivalTablePickerSheet> {
  late Future<List<FestivalSeatingZone>> _future = widget.loadZones();

  @override
  Widget build(BuildContext context) {
    return _FestivalPickerFrame(
      title: '${context.tr('festival_choose_table')} • ${widget.zoneName}',
      child: FutureBuilder<List<FestivalSeatingZone>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData && !snapshot.hasError) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: TextButton.icon(
                onPressed: () => setState(() => _future = widget.loadZones()),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(context.tr('festival_seating_load_failed')),
              ),
            );
          }
          final zones = snapshot.data!;
          final tables = zones.isEmpty
              ? <FestivalSeatingTable>[]
              : zones.first.tables
                  .where((table) => table.id != widget.excludeTableId)
                  .toList();
          if (tables.isEmpty) {
            return Center(child: Text(context.tr('festival_no_tables')));
          }
          return ListView.separated(
            itemCount: tables.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final table = tables[index];
              final selectable =
                  !table.isFull && table.availableSeats >= widget.minSeats;
              return ListTile(
                key: ValueKey('festival_table_${table.id}'),
                leading: const Icon(Icons.table_restaurant_rounded),
                title: Text(table.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  '${table.availableSeats}/${table.capacity} '
                  '${context.tr('festival_seats_available')}',
                ),
                trailing: selectable
                    ? const Icon(Icons.chevron_right_rounded)
                    : Text(context.tr('festival_table_full')),
                enabled: selectable,
                onTap: selectable ? () => Navigator.pop(context, table) : null,
              );
            },
          );
        },
      ),
    );
  }
}

class _FestivalPickerFrame extends StatelessWidget {
  final String title;
  final Widget child;

  const _FestivalPickerFrame({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.isDarkMode ? const Color(0xFF292929) : Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      )),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _FestivalSeatConfirmationDialog extends StatefulWidget {
  final String guestName;
  final String tableName;
  final String zoneName;
  final int maxSeats;
  final int availableSeats;

  const _FestivalSeatConfirmationDialog({
    required this.guestName,
    required this.tableName,
    required this.zoneName,
    required this.maxSeats,
    required this.availableSeats,
  });

  @override
  State<_FestivalSeatConfirmationDialog> createState() =>
      _FestivalSeatConfirmationDialogState();
}

class _FestivalSeatConfirmationDialogState
    extends State<_FestivalSeatConfirmationDialog> {
  late int _seatCount = widget.maxSeats;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr('festival_confirm_seating')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.guestName,
              style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('${widget.zoneName} • ${widget.tableName}'),
          Text(
              '${context.tr('festival_seats_available')}: ${widget.availableSeats}'),
          const SizedBox(height: 18),
          Text(context.tr('festival_seats_to_assign'),
              style: const TextStyle(fontWeight: FontWeight.w700)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                key: const ValueKey('festival_seat_decrease'),
                onPressed:
                    _seatCount > 1 ? () => setState(() => _seatCount--) : null,
                icon: const Icon(Icons.remove_circle_outline_rounded),
              ),
              Text('$_seatCount',
                  key: const ValueKey('festival_seat_count'),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      )),
              IconButton(
                key: const ValueKey('festival_seat_increase'),
                onPressed: _seatCount < widget.maxSeats
                    ? () => setState(() => _seatCount++)
                    : null,
                icon: const Icon(Icons.add_circle_outline_rounded),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr('festival_cancel')),
        ),
        FilledButton(
          key: const ValueKey('festival_confirm_assign'),
          onPressed: () => Navigator.pop(context, _seatCount),
          child: Text(context.tr('festival_confirm')),
        ),
      ],
    );
  }
}

class _FestivalSeatingCard extends StatelessWidget {
  final String? tableName;
  final String? tableSeat;

  const _FestivalSeatingCard({this.tableName, this.tableSeat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const color = AppColors.primary;
    return Container(
      key: const ValueKey('festival_seating_info'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(context.isDarkMode ? 46 : 20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(71)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_seat_rounded, color: color, size: 22),
              const SizedBox(width: 8),
              Text(
                context.tr('festival_seating_location'),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tableName != null)
                Expanded(
                  child: _FestivalLocationValue(
                    label: context.tr('festival_table_name'),
                    value: tableName!,
                  ),
                ),
              if (tableName != null && tableSeat != null)
                const SizedBox(width: 12),
              if (tableSeat != null)
                Expanded(
                  child: _FestivalLocationValue(
                    label: context.tr('festival_table_seat'),
                    value: tableSeat!,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FestivalLocationValue extends StatelessWidget {
  final String label;
  final String value;

  const _FestivalLocationValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _FestivalGiftInformationCard extends StatelessWidget {
  final String giftNote;

  const _FestivalGiftInformationCard({required this.giftNote});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const color = Color(0xFFE87500);
    return Container(
      key: const ValueKey('festival_gift_information'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.isDarkMode
            ? const Color(0xFF3D2819)
            : const Color(0xFFFFF1DA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(170), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.card_giftcard_rounded, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('festival_gift_information'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: context.isDarkMode
                        ? const Color(0xFFFFB66B)
                        : const Color(0xFF9B4C00),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  giftNote,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GatePickerSheet extends StatelessWidget {
  final List<FestivalGate> gates;
  final FestivalGate? selected;

  const _GatePickerSheet({required this.gates, this.selected});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: context.isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.onSurface.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: Text(
                context.tr('festival_choose_gate_title'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                itemCount: gates.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final gate = gates[index];
                  final isSelected = gate == selected;
                  return ListTile(
                    key: ValueKey('festival_gate_${gate.id}'),
                    selected: isSelected,
                    selectedTileColor: AppColors.primary.withOpacity(0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: Icon(
                      Icons.door_front_door_outlined,
                      color: isSelected ? AppColors.primary : null,
                    ),
                    title: Text(
                      gate.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: gate.code.isEmpty ? null : Text(gate.code),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                          )
                        : const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).pop(gate),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenteredStatus extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool loading;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _CenteredStatus({
    required this.icon,
    required this.label,
    this.loading = false,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const CircularProgressIndicator(color: AppColors.primary)
            else
              Icon(icon, size: 54, color: AppColors.primary),
            const SizedBox(height: 18),
            Text(label, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onAction,
                style: _festivalPrimaryButtonStyle(),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
