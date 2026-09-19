import 'package:flutter_core_project/data/models/festival/festival_models.dart';
import 'package:flutter_core_project/services/festival_gate_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('persists and clears the selected Festival gate', () async {
    final store = SharedPreferencesFestivalGateStore();
    const gate = FestivalGate(
      id: 5,
      name: 'Cổng Mobile App',
      code: 'GATE_MOBILE',
      description: 'Scanner',
    );

    expect(await store.readSelectedGate(), isNull);
    await store.saveSelectedGate(gate);
    expect(await store.readSelectedGate(), gate);

    await store.clearSelectedGate();
    expect(await store.readSelectedGate(), isNull);
  });
}
