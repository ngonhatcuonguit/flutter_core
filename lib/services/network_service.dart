import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

/// Enum for network status
enum NetworkStatus {
  online,
  offline,
  unknown,
}

/// Service to monitor and manage network connectivity
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  // Stream to notify listeners about network status changes
  final ValueNotifier<NetworkStatus> _networkStatus =
      ValueNotifier<NetworkStatus>(NetworkStatus.unknown);

  ValueNotifier<NetworkStatus> get networkStatus => _networkStatus;

  // List of API cancel tokens to cancel ongoing requests
  final List<CancelToken> _cancelTokens = [];

  factory NetworkService() {
    return _instance;
  }

  NetworkService._internal();

  /// Initialize network monitoring
  Future<void> init() async {
    try {
      // Check initial connectivity
      final result = await _connectivity.checkConnectivity();
      _updateNetworkStatus(result);

      // Listen to connectivity changes
      _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen((result) {
        _updateNetworkStatus(result);
      });
    } catch (e) {
      debugPrint('NetworkService init error: $e');
      _networkStatus.value = NetworkStatus.unknown;
    }
  }

  /// Update network status based on connectivity result
  void _updateNetworkStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      debugPrint('📡 Network: OFFLINE');
      _networkStatus.value = NetworkStatus.offline;
      _cancelAllRequests();
    } else if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet) {
      debugPrint('📡 Network: ONLINE');
      _networkStatus.value = NetworkStatus.online;
    } else {
      debugPrint('📡 Network: UNKNOWN');
      _networkStatus.value = NetworkStatus.unknown;
    }
  }

  /// Check if device has internet connection
  Future<bool> hasInternetConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        return false;
      }

      // Actually test internet connectivity by DNS lookup
      try {
        final response = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 5));
        return response.isNotEmpty && response[0].rawAddress.isNotEmpty;
      } on SocketException catch (e) {
        debugPrint('⚠️ DNS lookup failed: $e');
        return false;
      } on TimeoutException catch (e) {
        debugPrint('⚠️ Connection timeout: $e');
        return false;
      }
    } catch (e) {
      debugPrint('hasInternetConnection error: $e');
      return false;
    }
  }

  /// Register a cancel token for API request
  void registerCancelToken(CancelToken token) {
    _cancelTokens.add(token);
  }

  /// Unregister a cancel token
  void unregisterCancelToken(CancelToken token) {
    _cancelTokens.remove(token);
  }

  /// Cancel all ongoing API requests
  void _cancelAllRequests() {
    for (var token in _cancelTokens) {
      if (!token.isCancelled) {
        token.cancel('No internet connection');
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription.cancel();
    _networkStatus.dispose();
    _cancelAllRequests();
  }
}

/// Cancel token for managing API requests
class CancelToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel(String reason) {
    debugPrint('Cancel token: $reason');
    _isCancelled = true;
  }

  void reset() {
    _isCancelled = false;
  }
}
