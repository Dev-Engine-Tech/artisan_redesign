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
    id = 'dev-${DateTime.now().millisecondsSinceEpoch}-${rand.nextInt(1 << 32)}';
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
        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
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

      await secureStorage.setFirebaseToken(token);

      final deviceType = _platformDeviceType();
      final deviceId = await _getOrCreateDeviceId();

      await remote.registerDeviceToken(
        token: token,
        deviceType: deviceType,
        deviceId: deviceId,
      );

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        try {
          await secureStorage.setFirebaseToken(newToken);
          await remote.registerDeviceToken(
            token: newToken,
            deviceType: deviceType,
            deviceId: deviceId,
          );
        } catch (e) {
          debugPrint('FCM token refresh registration failed: $e');
        }
      });
    } catch (e) {
      debugPrint('PushRegistrationService error: $e');
    }
  }
}

