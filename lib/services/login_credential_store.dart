import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginCredentials {
  final String username;
  final String password;

  const LoginCredentials({
    required this.username,
    required this.password,
  });
}

abstract class LoginCredentialStore {
  Future<LoginCredentials?> read();

  Future<void> write(LoginCredentials credentials);

  Future<void> delete();
}

class SecureLoginCredentialStore implements LoginCredentialStore {
  static const _mainAppKey = 'main_app_login_credentials';
  static const _festivalKey = 'thp_festival_login_credentials';

  final String _key;
  final FlutterSecureStorage _storage;

  SecureLoginCredentialStore._(this._key, this._storage);

  factory SecureLoginCredentialStore.mainApp({
    FlutterSecureStorage? storage,
  }) {
    return SecureLoginCredentialStore._(
      _mainAppKey,
      storage ?? _defaultStorage(),
    );
  }

  factory SecureLoginCredentialStore.festival({
    FlutterSecureStorage? storage,
  }) {
    return SecureLoginCredentialStore._(
      _festivalKey,
      storage ?? _defaultStorage(),
    );
  }

  static FlutterSecureStorage _defaultStorage() {
    return const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
  }

  @override
  Future<LoginCredentials?> read() async {
    final rawValue = await _storage.read(key: _key);
    if (rawValue == null || rawValue.isEmpty) return null;

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map) return null;
      final username = decoded['username']?.toString().trim() ?? '';
      final password = decoded['password']?.toString() ?? '';
      if (username.isEmpty || password.isEmpty) return null;
      return LoginCredentials(username: username, password: password);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> write(LoginCredentials credentials) {
    return _storage.write(
      key: _key,
      value: jsonEncode({
        'username': credentials.username.trim(),
        'password': credentials.password,
      }),
    );
  }

  @override
  Future<void> delete() => _storage.delete(key: _key);
}
