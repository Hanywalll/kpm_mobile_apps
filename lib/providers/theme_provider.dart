import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HeaderThemePreset {
  final String key;
  final String name;
  final List<Color> colors;
  final Color primaryAccent;

  const HeaderThemePreset({
    required this.key,
    required this.name,
    required this.colors,
    required this.primaryAccent,
  });
}

class ThemeProvider extends ChangeNotifier {
  static const String _themePrefKey = 'kpm_theme_mode';
  static const String _headerThemePrefKey = 'kpm_header_theme';

  ThemeMode _themeMode = ThemeMode.light;
  String _headerThemeKey = 'classic_blue';

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  String get headerThemeKey => _headerThemeKey;

  static const List<HeaderThemePreset> headerPresets = [
    HeaderThemePreset(
      key: 'classic_blue',
      name: 'Classic KPM Deep Blue',
      colors: [Color(0xFF081F42), Color(0xFF0D3B66), Color(0xFF1D4ED8)],
      primaryAccent: Color(0xFF1D4ED8),
    ),
    HeaderThemePreset(
      key: 'ocean_teal',
      name: 'Ocean Teal & Cyan',
      colors: [Color(0xFF0F2E3D), Color(0xFF0D5C75), Color(0xFF0284C7)],
      primaryAccent: Color(0xFF0284C7),
    ),
    HeaderThemePreset(
      key: 'royal_purple',
      name: 'Royal Purple & Nebula',
      colors: [Color(0xFF1E1035), Color(0xFF4C1D95), Color(0xFF7C3AED)],
      primaryAccent: Color(0xFF7C3AED),
    ),
    HeaderThemePreset(
      key: 'ruby_sunset',
      name: 'Ruby Sunset Crimson',
      colors: [Color(0xFF3B0712), Color(0xFF991B1B), Color(0xFFDC2626)],
      primaryAccent: Color(0xFFDC2626),
    ),
    HeaderThemePreset(
      key: 'emerald_gold',
      name: 'Emerald Green & Jade',
      colors: [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF059669)],
      primaryAccent: Color(0xFF059669),
    ),
    HeaderThemePreset(
      key: 'midnight_dark',
      name: 'Midnight Obsidian Dark',
      colors: [Color(0xFF090D16), Color(0xFF1E293B), Color(0xFF334155)],
      primaryAccent: Color(0xFF38BDF8),
    ),
  ];

  HeaderThemePreset get currentHeaderPreset {
    return headerPresets.firstWhere(
      (p) => p.key == _headerThemeKey,
      orElse: () => headerPresets.first,
    );
  }

  LinearGradient get headerGradient {
    return LinearGradient(
      colors: currentHeaderPreset.colors,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_themePrefKey);
      if (savedMode == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (savedMode == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.light;
      }

      final savedHeader = prefs.getString(_headerThemePrefKey);
      if (savedHeader != null && savedHeader.isNotEmpty) {
        _headerThemeKey = savedHeader;
      }
      notifyListeners();
    } catch (_) {
      // Fallback
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePrefKey, isDark ? 'dark' : 'light');
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themePrefKey, mode == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {}
  }

  Future<void> setHeaderTheme(String themeKey) async {
    _headerThemeKey = themeKey;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_headerThemePrefKey, themeKey);
    } catch (_) {}
  }
}
