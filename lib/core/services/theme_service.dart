import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app theme mode (light/dark)
class ThemeService extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  final SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.light;

  ThemeService(this._prefs) {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _loadThemeMode() async {
    final savedMode = _prefs.getString(_themeModeKey);
    if (savedMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == savedMode,
        orElse: () => ThemeMode.light,
      );
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeModeKey, mode.toString());
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final newMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;
}
