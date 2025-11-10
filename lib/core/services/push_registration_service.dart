import 'dart:math';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:artisans_circle/core/storage/secure_storage.dart';
import 'package:artisans_circle/features/notifications/data/datasources/notification_remote_data_source.dart';

class PushRegistrationService {
  static const _deviceIdKey = 'device_id';
  static const _lastStatusKey = 'push_last_status'; // success | error
  static const _lastStatusAtKey = 'push_last_status_at';
  static const _lastErrorKey = 'push_last_error';

  final NotificationRemoteDataSource remote;
  final SecureStorage secureStorage;

  PushRegistrationService({required this.remote, required this.secureStorage});

  String _platformDeviceType() {
    if (kIsWeb) return 'web';
    try {
      if (Platform.isIOS) return 'ios';
      if (Platform.isAndroid) return 'android';
    } catch (_) {}
    return 'web';
  }

  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(_deviceIdKey);
    if (id != null && id.isNotEmpty) return id;
    final rand = Random();
    id =
        'dev-${DateTime.now().millisecondsSinceEpoch}-${rand.nextInt(1 << 32)}';
    await prefs.setString(_deviceIdKey, id);
    return id;
  }

  Future<void> registerIfPossible() async {
    try {
      // iOS permission prompt
      if (!kIsWeb) {
        final settings = await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        debugPrint('FCM permission status: ${settings.authorizationStatus}');
        await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('FCM token is null/empty; skip registration');
        return;
      }

      await secureStorage.setFcmToken(token);

      final deviceType = _platformDeviceType();
      final deviceId = await _getOrCreateDeviceId();

      debugPrint('Registering device token with backend…');
      debugPrint(' • deviceType=$deviceType');
      debugPrint(' • deviceId=$deviceId');
      debugPrint(
          ' • fcmToken=${token.substring(0, token.length > 12 ? 12 : token.length)}…');

      await remote.registerDeviceToken(
        token: token,
        deviceType: deviceType,
        deviceId: deviceId,
      );

      // Persist last successful registration metadata
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastStatusKey, 'success');
        await prefs.setString(
            _lastStatusAtKey, DateTime.now().toIso8601String());
        await prefs.remove(_lastErrorKey);
      } catch (_) {}

      debugPrint('✅ Push registration successful');

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        try {
          await secureStorage.setFcmToken(newToken);
          await remote.registerDeviceToken(
            token: newToken,
            deviceType: deviceType,
            deviceId: deviceId,
          );
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_lastStatusKey, 'success');
            await prefs.setString(
                _lastStatusAtKey, DateTime.now().toIso8601String());
            await prefs.remove(_lastErrorKey);
          } catch (_) {}
          debugPrint('🔄 FCM token refreshed and re-registered');
        } catch (e) {
          debugPrint('FCM token refresh registration failed: $e');
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_lastStatusKey, 'error');
            await prefs.setString(
                _lastStatusAtKey, DateTime.now().toIso8601String());
            await prefs.setString(_lastErrorKey, e.toString());
          } catch (_) {}
        }
      });
    } catch (e) {
      debugPrint('PushRegistrationService error: $e');
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_lastStatusKey, 'error');
        await prefs.setString(
            _lastStatusAtKey, DateTime.now().toIso8601String());
        await prefs.setString(_lastErrorKey, e.toString());
      } catch (_) {}
    }
  }

  /// Returns a snapshot of current push registration diagnostics.
  Future<Map<String, String>> getDiagnostics() async {
    final prefs = await SharedPreferences.getInstance();
    final fcmToken = await secureStorage.getFcmToken();
    final deviceId = prefs.getString(_deviceIdKey);
    final deviceType = _platformDeviceType();
    final status = prefs.getString(_lastStatusKey);
    final statusAt = prefs.getString(_lastStatusAtKey);
    final lastError = prefs.getString(_lastErrorKey);
    return {
      if (fcmToken != null) 'fcmToken': fcmToken,
      if (deviceId != null) 'deviceId': deviceId,
      'deviceType': deviceType,
      if (status != null) 'lastStatus': status,
      if (statusAt != null) 'lastStatusAt': statusAt,
      if (lastError != null) 'lastError': lastError,
    };
  }
}
