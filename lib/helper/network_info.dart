import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkInfo {
  static bool? _lastKnownConnection;
  static DateTime? _lastCheckTime;

  static void setLastKnownConnection(bool isConnected) {
    _lastKnownConnection = isConnected;
    _lastCheckTime = DateTime.now();
  }

  static bool? get lastKnownConnection => _lastKnownConnection;

  /// Performs a true, active internet connection check.
  /// Does not rely solely on device network adapter state (WiFi/Cellular).
  static Future<bool> hasConnection({bool forceCheck = false}) async {
    // If we checked recently (within 2 seconds) and not forced, return cached state
    if (!forceCheck && _lastCheckTime != null && _lastKnownConnection != null) {
      if (DateTime.now().difference(_lastCheckTime!).inSeconds < 2) {
        return _lastKnownConnection!;
      }
    }

    try {
      final List<ConnectivityResult> connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none) || connectivityResult.isEmpty) {
        setLastKnownConnection(false);
        return false;
      }

      if (kIsWeb) {
        bool connected = !connectivityResult.contains(ConnectivityResult.none);
        setLastKnownConnection(connected);
        return connected;
      }

      // Check real internet via DNS lookup with a short timeout
      try {
        final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 3));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          setLastKnownConnection(true);
          return true;
        }
      } catch (_) {
        // Fallback check in case google.com is blocked / restricted in certain regions
        try {
          final result2 = await InternetAddress.lookup('one.one.one.one').timeout(const Duration(seconds: 2));
          if (result2.isNotEmpty && result2[0].rawAddress.isNotEmpty) {
            setLastKnownConnection(true);
            return true;
          }
        } catch (_) {}
      }

      setLastKnownConnection(false);
      return false;
    } catch (_) {
      setLastKnownConnection(false);
      return false;
    }
  }

  /// Helper to check if a response error is due to network connection issues
  static bool isNoInternetError(dynamic error) {
    if (error == null) return false;
    final str = error.toString().toLowerCase();
    return str.contains('connection_to_api_server_failed') ||
           str.contains('socketexception') ||
           str.contains('network is unreachable') ||
           str.contains('connection timed out') ||
           str.contains('timeoutexception') ||
           str.contains('failed host lookup') ||
           str.contains('handshakeexception');
  }
}
