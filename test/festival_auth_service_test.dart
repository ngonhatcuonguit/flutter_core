import 'package:dio/dio.dart';
import 'package:flutter_core_project/data/data_sources/remote/festival_api_service.dart';
import 'package:flutter_core_project/data/models/festival/festival_models.dart';
import 'package:flutter_core_project/services/festival_auth_service.dart';
import 'package:flutter_core_project/services/login_credential_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Festival session survives service recreation until explicit logout',
      () async {
    final store = _MemoryTokenStore();
    final credentialStore = _MemoryCredentialStore();
    final api = _LoginApi();
    final firstService = FestivalAuthService(
      api,
      store,
      credentialStore: credentialStore,
    );

    final session = await firstService.login(
      username: 'receptionist',
      password: 'password',
    );
    expect(session.accessToken, 'persisted-token');
    expect(await firstService.hasSession(), isTrue);
    expect(
      (await firstService.getRememberedCredentials())?.username,
      'receptionist',
    );
    expect(
      (await firstService.getRememberedCredentials())?.password,
      'password',
    );

    final recreatedService = FestivalAuthService(
      api,
      store,
      credentialStore: credentialStore,
    );
    expect(await recreatedService.getAccessToken(), 'persisted-token');

    await recreatedService.logout();
    expect(await firstService.hasSession(), isFalse);
    expect(await firstService.getRememberedCredentials(), isNotNull);

    await recreatedService.forgetRememberedCredentials();
    expect(await firstService.getRememberedCredentials(), isNull);
  });
}

class _LoginApi extends FestivalApiService {
  _LoginApi() : super(Dio());

  @override
  Future<FestivalSession> login({
    required String username,
    required String password,
  }) async =>
      FestivalSession(
        accessToken: 'persisted-token',
        username: username,
      );
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

  @override
  Future<void> delete() async => credentials = null;

  @override
  Future<LoginCredentials?> read() async => credentials;

  @override
  Future<void> write(LoginCredentials value) async {
    credentials = value;
  }
}
