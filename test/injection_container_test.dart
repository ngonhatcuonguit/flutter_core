import 'package:dio/dio.dart';
import 'package:flutter_core_project/data/data_sources/remote/login_api_service.dart';
import 'package:flutter_core_project/data/data_sources/remote/level_up_api_service.dart';
import 'package:flutter_core_project/data/data_sources/remote/festival_api_service.dart';
import 'package:flutter_core_project/injection_container.dart';
import 'package:flutter_core_project/services/festival_auth_service.dart';
import 'package:flutter_core_project/services/festival_gate_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    await sl.reset();
  });

  tearDown(() async {
    await sl.reset();
  });

  test('initializeDependencies completes when Dio is already registered',
      () async {
    sl.registerSingleton<Dio>(Dio());

    await initializeDependencies();

    expect(sl.isRegistered<Dio>(), isTrue);
    expect(sl.isRegistered<LoginApiService>(), isTrue);
    expect(sl.isRegistered<LevelUpApiService>(), isTrue);
    expect(sl.isRegistered<FestivalApiService>(), isTrue);
    expect(sl.isRegistered<FestivalAuthService>(), isTrue);
    expect(sl.isRegistered<FestivalGateStore>(), isTrue);
  });

  test('initializeDependencies can be called more than once', () async {
    await initializeDependencies();
    await initializeDependencies();

    expect(sl.isRegistered<Dio>(), isTrue);
    expect(sl.isRegistered<LoginApiService>(), isTrue);
    expect(sl.isRegistered<LevelUpApiService>(), isTrue);
    expect(sl.isRegistered<FestivalApiService>(), isTrue);
  });
}
