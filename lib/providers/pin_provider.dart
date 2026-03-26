import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart'; // Đảm bảo đã thêm package crypto vào pubspec.yaml

class PinProvider with ChangeNotifier {
  bool _isLocked = true;
  bool _hasPin = false;

  bool get isLocked => _isLocked;
  bool get hasPin => _hasPin;

  PinProvider() {
    checkPinStatus();
  }

  // 1. Hàm băm mã PIN bằng SHA-256 (Bảo mật cốt lõi)
  String _hashPin(String pin) {
    var bytes = utf8.encode(pin); // Chuyển chuỗi thành bytes
    return sha256.convert(bytes).toString(); // Trả về chuỗi hash
  }

  // 2. Kiểm tra xem người dùng đã cài mã PIN chưa
  Future<void> checkPinStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Chúng ta chỉ lưu chuỗi đã băm (hash), không lưu PIN gốc
    String? savedHash = prefs.getString('user_pin_hash');
    _hasPin = savedHash != null;
    notifyListeners();
  }

  // 3. Cài đặt mã PIN mới (Dùng cho lần đầu hoặc đổi PIN)
  Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    String hashedPin = _hashPin(pin);
    await prefs.setString('user_pin_hash', hashedPin);
    _hasPin = true;
    _isLocked = false; // Cài xong thì mở khóa luôn
    notifyListeners();
  }

  // 4. Xác thực mã PIN khi mở App
  Future<bool> verifyPin(String inputPin) async {
    final prefs = await SharedPreferences.getInstance();
    String? savedHash = prefs.getString('user_pin_hash');
    
    if (savedHash == null) return false;

    // Băm mã PIN người dùng vừa nhập và so sánh với bản lưu
    if (_hashPin(inputPin) == savedHash) {
      _isLocked = false;
      notifyListeners();
      return true;
    }
    return false;
  }

  // 5. Khóa lại App (Khi người dùng nhấn Logout hoặc app chạy ngầm quá lâu)
  void lock() {
    _isLocked = true;
    notifyListeners();
  }
}