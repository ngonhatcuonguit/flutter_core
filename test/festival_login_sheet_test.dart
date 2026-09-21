import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core_project/data/data_sources/remote/festival_api_service.dart';
import 'package:flutter_core_project/presentation/pages/festival/festival_login_sheet.dart';
import 'package:flutter_core_project/services/festival_auth_service.dart';
import 'package:flutter_core_project/services/localization_service.dart';
import 'package:flutter_core_project/services/login_credential_store.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Festival login sheet restores its own remembered credentials',
      (tester) async {
    final authService = FestivalAuthService(
      _UnusedFestivalApi(),
      _MemoryTokenStore(),
      credentialStore: _MemoryCredentialStore(
        const LoginCredentials(
          username: 'festival-user',
          password: 'remembered-secret',
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('vi'),
        supportedLocales: const [Locale('vi'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showFestivalLoginSheet(
                context,
                authService: authService,
              ),
              child: const Text('Open Festival login'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Festival login'));
    await tester.pumpAndSettle();

    final usernameField = tester.widget<TextFormField>(
      find.byKey(const ValueKey('festival_username')),
    );
    final passwordField = tester.widget<TextFormField>(
      find.byKey(const ValueKey('festival_password')),
    );
    expect(usernameField.controller?.text, 'festival-user');
    expect(passwordField.controller?.text, 'remembered-secret');
    final passwordInput = tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const ValueKey('festival_password')),
        matching: find.byType(EditableText),
      ),
    );
    expect(passwordInput.obscureText, isTrue);
  });
}

class _UnusedFestivalApi extends FestivalApiService {
  _UnusedFestivalApi() : super(Dio());
}

class _MemoryTokenStore implements FestivalTokenStore {
  String? token;

  @override
  Future<void> deleteToken() async => token = null;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String value) async => token = value;
}

class _MemoryCredentialStore implements LoginCredentialStore {
  LoginCredentials? credentials;

  _MemoryCredentialStore([this.credentials]);

  @override
  Future<void> delete() async => credentials = null;

  @override
  Future<LoginCredentials?> read() async => credentials;

  @override
  Future<void> write(LoginCredentials value) async => credentials = value;
}
