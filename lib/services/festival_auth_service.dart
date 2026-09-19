import 'package:flutter_core_project/data/data_sources/remote/festival_api_service.dart';
import 'package:flutter_core_project/data/models/festival/festival_models.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class FestivalTokenStore {
  Future<String?> readToken();

  Future<void> writeToken(String token);

  Future<void> deleteToken();
}

class SecureFestivalTokenStore implements FestivalTokenStore {
  static const _tokenKey = 'thp_festival_access_token';

  final FlutterSecureStorage _storage;

  SecureFestivalTokenStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  @override
  Future<String?> readToken() async {
    final token = (await _storage.read(key: _tokenKey))?.trim();
    return token == null || token.isEmpty ? null : token;
  }

  @override
  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token.trim());

  @override
  Future<void> deleteToken() => _storage.delete(key: _tokenKey);
}

class FestivalAuthService {
  final FestivalApiService _api;
  final FestivalTokenStore _tokenStore;

  FestivalAuthService(this._api, this._tokenStore);

  Future<String?> getAccessToken() => _tokenStore.readToken();

  Future<bool> hasSession() async => (await getAccessToken()) != null;

  Future<FestivalSession> login({
    required String username,
    required String password,
  }) async {
    final session = await _api.login(username: username, password: password);
    await _tokenStore.writeToken(session.accessToken);
    return session;
  }

  Future<void> logout() => _tokenStore.deleteToken();
}
