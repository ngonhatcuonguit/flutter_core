import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _hasSeenIntroKey = 'has_seen_intro';

  /// Check if user has seen the intro/onboarding
  static Future<bool> hasSeenIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenIntroKey) ?? false;
  }

  /// Mark that user has seen the intro/onboarding
  static Future<void> setIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenIntroKey, true);
  }

  /// Reset intro flag (for testing purposes)
  static Future<void> resetIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasSeenIntroKey);
  }
}
