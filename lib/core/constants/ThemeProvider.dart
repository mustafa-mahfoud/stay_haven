import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // تبديل الوضع وحفظه
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    // حفظ الخيار لكي لا يضيع عند إغلاق التطبيق
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  // تحميل الوضع المحفوظ عند تشغيل التطبيق
  void _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
}
