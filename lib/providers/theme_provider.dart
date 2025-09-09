import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_color';
  static const String _darkModeKey = 'dark_mode';

  Color _primaryColor = Colors.blue;
  bool _isDarkMode = false;

  Color get primaryColor => _primaryColor;
  bool get isDarkMode => _isDarkMode;

  ThemeData get lightTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      );

  ThemeData get darkTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primaryColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      );

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  final Map<String, Color> availableColors = {
    'Blue': Colors.blue,
    'Red': Colors.red,
    'Green': Colors.green,
    'Purple': Colors.purple,
    'Orange': Colors.orange,
    'Teal': Colors.teal,
    'Pink': Colors.pink,
    'Indigo': Colors.indigo,
  };

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final colorIndex = prefs.getInt(_themeKey) ?? 0;
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;

    final colors = availableColors.values.toList();
    if (colorIndex < colors.length) {
      _primaryColor = colors[colorIndex];
    }

    notifyListeners();
  }

  void setThemeColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    final colorIndex = availableColors.values.toList().indexOf(color);
    await prefs.setInt(_themeKey, colorIndex);
    notifyListeners();
  }

  void setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDark);
    notifyListeners();
  }
}
