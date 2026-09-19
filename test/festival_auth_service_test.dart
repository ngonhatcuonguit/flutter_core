import 'package:dio/dio.dart';
import 'package:flutter_core_project/data/data_sources/remote/festival_api_service.dart';
import 'package:flutter_core_project/data/models/festival/festival_models.dart';
import 'package:flutter_core_project/services/festival_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Festival session survives service recreation until explicit logout',
      () async {
    final store = _MemoryTokenStore();
    final api = _LoginApi();
    final firstService = FestivalAuthService(api, store);

    final session = await firstService.login(
      username: 'receptionist',
      password: 'password',
    );
    expect(session.accessToken, 'persisted-token');
    expect(await firstService.hasSession(), isTrue);

    final recreatedService = FestivalAuthService(api, store);
    expect(await recreatedService.getAccessToken(), 'persisted-token');

    await recreatedService.logout();
    expect(await firstService.hasSession(), isFalse);
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
