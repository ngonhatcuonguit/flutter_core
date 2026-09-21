import 'package:flutter_core_project/services/login_credential_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('main app and Festival credentials are encrypted-store scoped',
      () async {
    FlutterSecureStorage.setMockInitialValues({});
    final mainStore = SecureLoginCredentialStore.mainApp();
    final festivalStore = SecureLoginCredentialStore.festival();

    await mainStore.write(
      const LoginCredentials(
        username: ' 43950 ',
        password: r'main-$ecret',
      ),
    );
    await festivalStore.write(
      const LoginCredentials(
        username: 'festival-user',
        password: 'festival-secret',
      ),
    );

    final mainCredentials = await mainStore.read();
    final festivalCredentials = await festivalStore.read();
    expect(mainCredentials?.username, '43950');
    expect(mainCredentials?.password, r'main-$ecret');
    expect(festivalCredentials?.username, 'festival-user');
    expect(festivalCredentials?.password, 'festival-secret');

    await mainStore.delete();
    expect(await mainStore.read(), isNull);
    expect((await festivalStore.read())?.username, 'festival-user');
  });
}
