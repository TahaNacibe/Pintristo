import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkTheme = false;

  bool get isDarkTheme => _isDarkTheme;

  ThemeProvider() {
    _loadThemeFromPreferences();
  }

  // Load theme from SharedPreferences
  void _loadThemeFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkTheme = prefs.getBool('isDarkTheme') ?? false; // Default to light theme
    notifyListeners(); // Notify listeners after loading theme
  }

  // Save theme to SharedPreferences
  Future<void> _saveThemeToPreferences(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkTheme', value);
  }

  // Toggle theme and persist the change
  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    _saveThemeToPreferences(_isDarkTheme);
    notifyListeners(); // Notify listeners to rebuild UI
  }
}
