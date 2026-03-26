import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  // Key cố định để lưu trữ trong bộ nhớ máy
  static const String _themeKey = "is_dark_mode";
  
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // 1. Hàm tải cấu hình Theme (Cần gọi await ở main.dart để tránh nháy màn hình)
  Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  // 2. Hàm thay đổi Theme và lưu lại vĩnh viễn
  Future<void> toggleTheme(bool isOn) async {
    // Chỉ xử lý nếu giá trị thực sự thay đổi để tiết kiệm tài nguyên
    if (_isDarkMode == isOn) return;

    _isDarkMode = isOn;
    notifyListeners();

    // Lưu xuống máy để lần sau mở app vẫn giữ đúng giao diện
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isOn);
  }
}