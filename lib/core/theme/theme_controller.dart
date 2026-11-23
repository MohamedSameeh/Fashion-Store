import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the theme choice (system / light / dark) and persists it.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController._() : super(ThemeMode.system);
  static final ThemeController instance = ThemeController._();
  static const _key = 'themeMode';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    switch (prefs.getString(_key)) {
      case 'light':
        value = ThemeMode.light;
      case 'dark':
        value = ThemeMode.dark;
      default:
        value = ThemeMode.system;
    }
  }

  Future<void> toggle(BuildContext context) => setMode(
      Theme.of(context).brightness == Brightness.dark
          ? ThemeMode.light
          : ThemeMode.dark);

  Future<void> setMode(ThemeMode mode) async {
    value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}
