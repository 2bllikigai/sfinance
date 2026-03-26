import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// --- IMPORT PROVIDERS ---
import 'providers/transaction_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/pin_provider.dart';

// --- IMPORT SCREENS ---
import 'screens/pin_screen.dart';
import 'screens/main_screen.dart'; // ✅ Đảm bảo bạn đã tạo file main_screen.dart

void main() async {
  // 1. Đảm bảo các dịch vụ hệ thống sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Cầu nối Database cho Desktop (Windows/macOS/Linux)
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 3. Khởi tạo các Provider "hạt nhân"
  final themeProvider = ThemeProvider();
  final pinProvider = PinProvider();
  
  // Load cài đặt người dùng trước khi vẽ giao diện
  await themeProvider.loadThemePreference(); 
  await pinProvider.checkPinStatus();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: pinProvider),
        // Khởi tạo TransactionProvider và nạp dữ liệu từ SQLCipher ngay lập tức
        ChangeNotifierProvider(
          create: (_) => TransactionProvider()..loadTransactions(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Lắng nghe trạng thái Dark Mode từ ThemeProvider
    final isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    return MaterialApp(
      title: 'SFINANCE',
      debugShowCheckedModeBanner: false,
      
      // --- CHẾ ĐỘ THEME (Tự động chuyển Sáng/Tối) ---
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // 🟢 THEME SÁNG (Phong cách Quang Trường - Hình 1, 2, 3)
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF001A72),
        brightness: Brightness.light,
        fontFamily: 'BeVietnamPro',
        scaffoldBackgroundColor: const Color(0xFFF5F7FF), // Nền xanh nhạt thanh lịch
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF001A72), 
            fontSize: 24, 
            fontWeight: FontWeight.bold,
            fontFamily: 'BeVietnamPro'
          ),
        ),
      ),
      
      // 🌑 THEME TỐI (Phong cách Deep Black Cashew)
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.greenAccent,
        brightness: Brightness.dark,
        fontFamily: 'BeVietnamPro',
        scaffoldBackgroundColor: const Color(0xFF0F0F0F), // Nền đen sâu
        cardTheme: CardThemeData( 
          color: const Color(0xFF171717),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F0F0F),
          elevation: 0,
          centerTitle: false,
        ),
      ),

      // Màn hình khởi đầu luôn là mã PIN để bảo mật dữ liệu
      home: const PinScreen(),
    );
  }
}