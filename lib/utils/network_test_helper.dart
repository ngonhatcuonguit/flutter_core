import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Helper class to test network connectivity
class NetworkTestHelper {
  /// Test if we can resolve newsapi.org
  static Future<bool> canResolveNewsApi() async {
    try {
      debugPrint('🧪 Testing DNS resolution for newsapi.org...');
      final result = await InternetAddress.lookup('newsapi.org')
          .timeout(const Duration(seconds: 10));

      if (result.isNotEmpty) {
        debugPrint('✅ Successfully resolved newsapi.org');
        debugPrint(
            '   IP addresses: ${result.map((e) => e.address).join(", ")}');
        return true;
      } else {
        debugPrint('❌ No IP addresses found for newsapi.org');
        return false;
      }
    } on SocketException catch (e) {
      debugPrint('❌ SocketException: $e');
      debugPrint('   OS Error: ${e.osError}');
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error (timeout or other): $e');
      return false;
    }
  }

  /// Test if we can resolve google.com (as a baseline)
  static Future<bool> canResolveGoogle() async {
    try {
      debugPrint('🧪 Testing DNS resolution for google.com...');
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 10));

      if (result.isNotEmpty) {
        debugPrint('✅ Successfully resolved google.com');
        debugPrint(
            '   IP addresses: ${result.map((e) => e.address).join(", ")}');
        return true;
      } else {
        debugPrint('❌ No IP addresses found for google.com');
        return false;
      }
    } on SocketException catch (e) {
      debugPrint('❌ SocketException: $e');
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error (timeout or other): $e');
      return false;
    }
  }

  /// Run comprehensive network test
  static Future<Map<String, dynamic>> runNetworkDiagnostics() async {
    debugPrint('🔬 Running network diagnostics...');

    final canResolveGoogle = await NetworkTestHelper.canResolveGoogle();
    final canResolveNewsApi = await NetworkTestHelper.canResolveNewsApi();

    final result = {
      'canResolveGoogle': canResolveGoogle,
      'canResolveNewsApi': canResolveNewsApi,
      'diagnosis': _getDiagnosis(canResolveGoogle, canResolveNewsApi),
    };

    debugPrint('📊 Diagnostics complete: $result');
    return result;
  }

  static String _getDiagnosis(bool google, bool newsApi) {
    if (google && newsApi) {
      return 'Internet connection is working properly';
    } else if (google && !newsApi) {
      return 'Internet works but newsapi.org cannot be reached. '
          'This could be due to firewall, VPN, or DNS settings.';
    } else if (!google && !newsApi) {
      return 'No internet connection detected. '
          'Please check your WiFi or mobile data.';
    } else {
      return 'Unexpected network state. Please check your connection.';
    }
  }
}
