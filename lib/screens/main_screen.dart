import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'home_screen.dart';
import 'transaction_list_screen.dart';
import 'settings_screen.dart';
import 'add_edit_screen.dart';
import 'statistics_screen.dart'; // ✅ Thêm import này

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Danh sách các màn hình tương ứng với các Tab
  final List<Widget> _pages = [
    const HomeScreen(),            // Tab 0
    const TransactionListScreen(), // Tab 1
    const StatisticsScreen(),      // ✅ Tab 2: Thay thế đoạn Text "đang phát triển" bằng trang mới
    const SettingsScreen(),        // Tab 3
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final Color activeColor = isDark ? Colors.greenAccent : const Color(0xFF001A72);
    final Color inactiveColor = isDark ? Colors.white24 : Colors.black26;
    final Color barColor = isDark ? const Color(0xFF171717) : Colors.white;
    final Color fabColor = isDark ? Colors.greenAccent : const Color(0xFF4A5568);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditScreen())),
        backgroundColor: fabColor,
        shape: const CircleBorder(),
        elevation: 4,
        child: Icon(Icons.add, color: isDark ? Colors.black : Colors.white, size: 30),
      ),

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: barColor,
        elevation: 20,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _buildNavItem(icon: Icons.home_filled, index: 0, activeColor: activeColor, inactiveColor: inactiveColor),
              _buildNavItem(icon: Icons.account_balance_wallet_outlined, index: 1, activeColor: activeColor, inactiveColor: inactiveColor),
              const Spacer(), 
              _buildNavItem(icon: Icons.pie_chart_outline, index: 2, activeColor: activeColor, inactiveColor: inactiveColor),
              _buildNavItem(icon: Icons.more_horiz, index: 3, activeColor: activeColor, inactiveColor: inactiveColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index, required Color activeColor, required Color inactiveColor}) {
    bool isActive = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? activeColor : inactiveColor, size: 28),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(top: 4),
              width: isActive ? 4 : 0, height: 4,
              decoration: BoxDecoration(color: activeColor, shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }
}