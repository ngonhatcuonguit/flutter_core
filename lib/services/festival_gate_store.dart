import 'dart:convert';

import 'package:flutter_core_project/data/models/festival/festival_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FestivalGateStore {
  Future<FestivalGate?> readSelectedGate();

  Future<void> saveSelectedGate(FestivalGate gate);

  Future<void> clearSelectedGate();
}

class SharedPreferencesFestivalGateStore implements FestivalGateStore {
  static const _selectedGateKey = 'thp_festival_selected_gate';

  @override
  Future<FestivalGate?> readSelectedGate() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_selectedGateKey);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final gate = FestivalGate.fromJson(Map<String, dynamic>.from(decoded));
      return gate.id > 0 && gate.name.isNotEmpty ? gate : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveSelectedGate(FestivalGate gate) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_selectedGateKey, jsonEncode(gate.toJson()));
  }

  @override
  Future<void> clearSelectedGate() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_selectedGateKey);
  }
}
