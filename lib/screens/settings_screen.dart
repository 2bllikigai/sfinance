import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
// import 'login_screen.dart'; // Import màn hình đăng nhập của bạn để logout

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt hệ thống'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        children: [
          // --- PHẦN TÀI KHOẢN ---
          _buildSectionTitle('Tài khoản & Cá nhân'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: const Text('Kiều Quang Trường'), // Có thể lấy từ DB sau
                  subtitle: const Text('truongkq@university.edu.vn'),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () {
                    // Logic chỉnh sửa Profile
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text('Đăng xuất', style: TextStyle(color: Colors.redAccent)),
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- PHẦN GIAO DIỆN ---
          _buildSectionTitle('Giao diện & Hiển thị'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              title: const Text('Chế độ Tối (Dark Mode)'),
              subtitle: Text(themeProvider.isDarkMode ? 'Đang bật' : 'Đang tắt'),
              secondary: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: themeProvider.isDarkMode ? Colors.amber : Colors.blue,
              ),
              value: themeProvider.isDarkMode,
              onChanged: (bool value) => themeProvider.toggleTheme(value),
            ),
          ),

          const SizedBox(height: 24),

          // --- PHẦN BẢO MẬT ---
          _buildSectionTitle('Bảo mật & Dữ liệu'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_reset),
                  title: const Text('Thay đổi mã PIN'),
                  subtitle: const Text('Sử dụng mã băm SHA-256'),
                  onTap: () {
                    // Logic đổi PIN
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Mã hóa SQLCipher'),
                  subtitle: const Text('Dữ liệu đang được bảo vệ AES-256'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- THÔNG TIN ỨNG DỤNG ---
          _buildSectionTitle('Khác'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Thông tin đồ án'),
              subtitle: const Text('SFINANCE v1.0 - ĐH Đại Nam'),
              onTap: () => _showAboutApp(context),
            ),
          ),
        ],
      ),
    );
  }

  // Widget hỗ trợ vẽ tiêu đề phân vùng
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Hàm hiển thị Dialog Đăng xuất
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đăng xuất?'),
        content: const Text('Bạn sẽ cần nhập lại mã PIN để truy cập dữ liệu.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Hàm hiển thị Thông tin ứng dụng
  void _showAboutApp(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'SFINANCE',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.account_balance_wallet, size: 50, color: Colors.deepPurple),
      children: const [
        Text('Học phần: Lập trình di động'),
        Text('Sinh viên: Kiều Quang Trường'),
        Text('Công nghệ: Flutter, Provider, SQLCipher.'),
      ],
    );
  }
}