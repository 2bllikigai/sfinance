import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';
import '../providers/pin_provider.dart';
import '../providers/theme_provider.dart';
import 'main_screen.dart'; // ✅ Đã đổi từ home_screen sang main_screen

class PinScreen extends StatefulWidget {
  const PinScreen({super.key});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  String _inputPin = "";
  bool _isError = false;

  void _handleKeyPress(String value) async {
    if (_inputPin.length < 4) {
      HapticFeedback.lightImpact(); // Rung nhẹ khi chạm phím
      setState(() {
        _inputPin += value;
        _isError = false;
      });
    }

    // Khi đã nhập đủ 4 số
    if (_inputPin.length == 4) {
      final pinProvider = Provider.of<PinProvider>(context, listen: false);
      
      if (!pinProvider.hasPin) {
        // THIẾT LẬP PIN LẦN ĐẦU
        await pinProvider.setPin(_inputPin);
        _navigateToMain();
      } else {
        // XÁC THỰC PIN
        bool isValid = await pinProvider.verifyPin(_inputPin);
        
        if (isValid) {
          _navigateToMain();
        } else {
          // SAI MÃ PIN
          HapticFeedback.heavyImpact(); // Rung mạnh báo lỗi
          setState(() {
            _isError = true;
            _inputPin = ""; 
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mã PIN không chính xác!'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  // ✅ Hàm điều hướng vào trung tâm điều khiển MainScreen
  void _navigateToMain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinProvider = Provider.of<PinProvider>(context);
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    bool isSetupMode = !pinProvider.hasPin;

    final Color primaryColor = isDark ? Colors.greenAccent : const Color(0xFF001A72);
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F7FF),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 2),
            Icon(Icons.lock_outline_rounded, size: 80, color: primaryColor),
            const SizedBox(height: 24),
            Text(
              isSetupMode ? "Thiết lập bảo mật" : "Xác thực mã PIN",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: textColor, fontFamily: 'BeVietnamPro'),
            ),
            const SizedBox(height: 12),
            Text(
              isSetupMode ? "Vui lòng tạo mã PIN 4 số" : "Nhập mã để truy cập SFINANCE",
              style: TextStyle(color: textColor.withValues(alpha: 0.6), fontFamily: 'BeVietnamPro'),
            ),
            const SizedBox(height: 50),
            
            // Hiển thị 4 dấu chấm (Dots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                bool isFilled = index < _inputPin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isError 
                        ? Colors.redAccent 
                        : (isFilled ? primaryColor : Colors.grey.withValues(alpha: 0.2)),
                    border: Border.all(
                      color: isFilled ? primaryColor : Colors.transparent,
                    ),
                  ),
                );
              }),
            ),
            
            const Spacer(flex: 2),
            
            // Bàn phím số (Numpad)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  for (var row in [['1', '2', '3'], ['4', '5', '6'], ['7', '8', '9']])
                    _buildKeyboardRow(row, textColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(width: 80),
                      _buildKey("0", textColor),
                      _buildBackspaceKey(),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: keys.map((key) => _buildKey(key, textColor)).toList(),
      ),
    );
  }

  Widget _buildKey(String text, Color textColor) {
    return InkWell(
      onTap: () => _handleKeyPress(text),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 80,
        height: 80,
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return SizedBox(
      width: 80,
      height: 80,
      child: IconButton(
        onPressed: () {
          if (_inputPin.isNotEmpty) {
            HapticFeedback.selectionClick();
            setState(() => _inputPin = _inputPin.substring(0, _inputPin.length - 1));
          }
        },
        icon: const Icon(Icons.backspace_outlined, color: Colors.redAccent, size: 28),
      ),
    );
  }
}