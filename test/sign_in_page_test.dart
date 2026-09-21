import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core_project/data/data_sources/remote/login_api_service.dart';
import 'package:flutter_core_project/data/models/auth/login_model.dart';
import 'package:flutter_core_project/presentation/auth/pages/sign_in.dart';
import 'package:flutter_core_project/services/auth_service.dart';
import 'package:flutter_core_project/services/login_credential_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('login loading overlay locks the whole form', (tester) async {
    final api = _PendingLoginApiService();
    await tester.pumpWidget(
      MaterialApp(
        home: SigninPage(
          apiService: api,
          credentialStore: _MemoryCredentialStore(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '43950');
    await tester.enterText(fields.at(1), 'secret');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
    await tester.pump();

    expect(api.callCount, 1);
    expect(
      find.byKey(const ValueKey('login_loading_overlay')),
      findsOneWidget,
    );
    expect(tester.widget<TextField>(fields.at(0)).focusNode!.hasFocus, isFalse);
    expect(tester.widget<TextField>(fields.at(1)).focusNode!.hasFocus, isFalse);

    await tester.tap(fields.at(0), warnIfMissed: false);
    await tester.pump();
    expect(tester.widget<TextField>(fields.at(0)).focusNode!.hasFocus, isFalse);
    expect(tester.widget<TextField>(fields.at(0)).controller!.text, '43950');

    api.complete(
      const LoginResponse(isSuccess: false, message: 'Sai thông tin'),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('login_loading_overlay')), findsNothing);
    expect(find.text('Sai thông tin'), findsOneWidget);
  });

  testWidgets('restores and updates remembered main app credentials',
      (tester) async {
    final credentialStore = _MemoryCredentialStore(
      const LoginCredentials(username: '43950', password: 'old-secret'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SigninPage(
          apiService: _SuccessfulLoginApiService(),
          credentialStore: credentialStore,
          authenticatedPageBuilder: (_) => const Scaffold(
            body: Text('Authenticated'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    expect(tester.widget<TextField>(fields.at(0)).controller!.text, '43950');
    expect(
      tester.widget<TextField>(fields.at(1)).controller!.text,
      'old-secret',
    );

    await tester.enterText(fields.at(0), ' 43951 ');
    await tester.enterText(fields.at(1), 'new-secret');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Đăng nhập'));
    await tester.pumpAndSettle();

    expect(find.text('Authenticated'), findsOneWidget);
    expect(credentialStore.credentials?.username, '43951');
    expect(credentialStore.credentials?.password, 'new-secret');
    expect(await AuthService.isLoggedIn(), isTrue);
  });

  testWidgets('does not overwrite credentials entered while restore is pending',
      (tester) async {
    final credentialStore = _DeferredCredentialStore();
    await tester.pumpWidget(
      MaterialApp(
        home: SigninPage(
          apiService: _PendingLoginApiService(),
          credentialStore: credentialStore,
        ),
      ),
    );
    await tester.pump();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'new-user');
    credentialStore.complete(
      const LoginCredentials(username: 'old-user', password: 'old-password'),
    );
    await tester.pump();

    expect(
      tester.widget<TextField>(fields.at(0)).controller!.text,
      'new-user',
    );
    expect(tester.widget<TextField>(fields.at(1)).controller!.text, isEmpty);
  });
}

class _PendingLoginApiService extends LoginApiService {
  _PendingLoginApiService() : super(Dio());

  final Completer<LoginResponse> _completer = Completer<LoginResponse>();
  int callCount = 0;

  @override
  Future<LoginResponse> login({
    required String userName,
    required String password,
  }) {
    callCount++;
    return _completer.future;
  }

  void complete(LoginResponse response) => _completer.complete(response);
}

class _SuccessfulLoginApiService extends LoginApiService {
  _SuccessfulLoginApiService() : super(Dio());

  @override
  Future<LoginResponse> login({
    required String userName,
    required String password,
  }) async {
    return LoginResponse(
      isSuccess: true,
      username: userName,
      token: 'main-token',
    );
  }
}

class _MemoryCredentialStore implements LoginCredentialStore {
  LoginCredentials? credentials;

  _MemoryCredentialStore([this.credentials]);

  @override
  Future<void> delete() async => credentials = null;

  @override
  Future<LoginCredentials?> read() async => credentials;

  @override
  Future<void> write(LoginCredentials value) async {
    credentials = LoginCredentials(
      username: value.username.trim(),
      password: value.password,
    );
  }
}

class _DeferredCredentialStore implements LoginCredentialStore {
  final _readCompleter = Completer<LoginCredentials?>();

  void complete(LoginCredentials credentials) {
    _readCompleter.complete(credentials);
  }

  @override
  Future<void> delete() async {}

  @override
  Future<LoginCredentials?> read() => _readCompleter.future;

  @override
  Future<void> write(LoginCredentials credentials) async {}
}
