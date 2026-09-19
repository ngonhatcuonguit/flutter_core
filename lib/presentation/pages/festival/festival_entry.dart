import 'package:flutter/material.dart';
import 'package:flutter_core_project/injection_container.dart';
import 'package:flutter_core_project/presentation/pages/festival/festival_login_sheet.dart';
import 'package:flutter_core_project/presentation/pages/festival/festival_scanner_page.dart';
import 'package:flutter_core_project/services/festival_auth_service.dart';
import 'package:flutter_core_project/services/localization_service.dart';

class FestivalEntry {
  FestivalEntry._();

  static Future<void> open(
    BuildContext context, {
    FestivalAuthService? authService,
    WidgetBuilder? pageBuilder,
  }) async {
    final auth = authService ?? sl<FestivalAuthService>();
    final navigator = Navigator.of(context);
    String? token;
    try {
      token = await auth.getAccessToken();
    } catch (_) {
      token = null;
    }
    if (!context.mounted) return;

    if (token == null) {
      final loggedIn = await showFestivalLoginSheet(
        context,
        authService: auth,
      );
      if (!loggedIn || !context.mounted) return;
    }

    navigator.push(
      MaterialPageRoute(
        builder: pageBuilder ?? (_) => const FestivalScannerPage(),
      ),
    );
  }

  static void showOpenError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.tr('festival_error_generic'))),
    );
  }
}
