import 'package:shared_preferences/shared_preferences.dart';

/// Service to track login state and determine if user should see instructional video
class LoginStateService {
  static const String _lastLoginMethodKey = 'last_login_method';
  static const String _lastLoginTimestampKey = 'last_login_timestamp';
  static const String _hasSeenInstructionalVideoKey = 'has_seen_instructional_video';

  // Login method types
  static const String loginMethodManual = 'manual';
  static const String loginMethodAutomatic = 'automatic';
  static const String loginMethodGoogle = 'google';
  static const String loginMethodApple = 'apple';

  static LoginStateService? _instance;
  static LoginStateService get instance => _instance ??= LoginStateService._();
  
  LoginStateService._();

  /// Record that user logged in manually (fresh login)
  Future<void> recordManualLogin() async {
    await _recordLogin(loginMethodManual);
  }

  /// Record that user logged in automatically from saved credentials
  Future<void> recordAutomaticLogin() async {
    await _recordLogin(loginMethodAutomatic);
  }

  /// Record that user logged in with Google
  Future<void> recordGoogleLogin() async {
    await _recordLogin(loginMethodGoogle);
  }

  /// Record that user logged in with Apple
  Future<void> recordAppleLogin() async {
    await _recordLogin(loginMethodApple);
  }

  /// Internal method to record login with timestamp
  Future<void> _recordLogin(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLoginMethodKey, method);
    await prefs.setInt(_lastLoginTimestampKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Check if the current login session should show the instructional video
  /// Returns true for fresh logins (manual, Google, Apple) but not automatic logins
  Future<bool> shouldShowInstructionalVideo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if user has already seen the video in this session
      final hasSeenVideo = prefs.getBool(_hasSeenInstructionalVideoKey) ?? false;
      print('🔍 LoginStateService: Has seen video this session? $hasSeenVideo');
      
      if (hasSeenVideo) {
        print('❌ LoginStateService: Video already seen this session, not showing again');
        return false;
      }

      // Get the last login method
      final lastLoginMethod = prefs.getString(_lastLoginMethodKey);
      print('🔑 LoginStateService: Last login method: $lastLoginMethod');
      
      // Show video for fresh logins but not automatic logins
      switch (lastLoginMethod) {
        case loginMethodManual:
        case loginMethodGoogle:
        case loginMethodApple:
          print('✅ LoginStateService: Fresh login detected ($lastLoginMethod), should show video');
          return true;
        case loginMethodAutomatic:
          print('🔄 LoginStateService: Automatic login detected, skipping video');
          return false;
        default:
          print('❓ LoginStateService: Unknown login method ($lastLoginMethod), not showing video');
          return false;
      }
    } catch (e) {
      print('❗ LoginStateService error: $e');
      // On error, default to not showing video
      return false;
    }
  }

  /// Mark that the user has seen the instructional video in this session
  Future<void> markInstructionalVideoSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasSeenInstructionalVideoKey, true);
    } catch (e) {
      // Ignore errors when marking video as seen
    }
  }

  /// Reset the instructional video flag (useful for testing or new features)
  Future<void> resetInstructionalVideoFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_hasSeenInstructionalVideoKey);
    } catch (e) {
      // Ignore errors when resetting flag
    }
  }

  /// Get the last login method
  Future<String?> getLastLoginMethod() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastLoginMethodKey);
    } catch (e) {
      return null;
    }
  }

  /// Get the timestamp of the last login
  Future<DateTime?> getLastLoginTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_lastLoginTimestampKey);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if the last login was within a specified duration
  Future<bool> wasLastLoginRecent({Duration duration = const Duration(hours: 24)}) async {
    final lastLogin = await getLastLoginTimestamp();
    if (lastLogin == null) return false;
    
    return DateTime.now().difference(lastLogin) < duration;
  }

  /// Clear all login state (useful for logout)
  Future<void> clearLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastLoginMethodKey);
      await prefs.remove(_lastLoginTimestampKey);
      await prefs.remove(_hasSeenInstructionalVideoKey);
    } catch (e) {
      // Ignore errors when clearing state
    }
  }

  /// Check if this appears to be a fresh app installation or first login
  Future<bool> isFirstTimeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLoginMethod = prefs.getString(_lastLoginMethodKey);
      return lastLoginMethod == null;
    } catch (e) {
      return true; // Assume first time user on error
    }
  }
}