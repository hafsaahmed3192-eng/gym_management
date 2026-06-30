import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark;

  ThemeProvider(this._isDark);

  bool get isDark => _isDark;

  ThemeMode get themeMode =>
      _isDark ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() async {
    _isDark = !_isDark;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
  }

  //////////////////////////////////////////////////////
  /// STATIC METHOD TO LOAD THEME BEFORE APP STARTS
  //////////////////////////////////////////////////////
  static Future<bool> loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDark') ?? true;
  }
}