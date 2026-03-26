import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; 
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'Buổi sáng tốt lành';
    if (hour < 18) return 'Buổi chiều vui vẻ';
    return 'Buổi tối vui vẻ';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    // Bộ màu động theo Theme
    final Color primaryColor = isDark ? Colors.greenAccent : const Color(0xFF001A72);
    final Color bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F7FF);
    final Color cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color subTextColor = isDark ? Colors.white54 : Colors.black54;

    return Material(
      color: bgColor,
      child: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. HEADER (Lời chào & Settings)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_getGreeting(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: subTextColor)),
                          IconButton(
                            icon: Icon(Icons.settings_outlined, color: subTextColor),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())),
                          ),
                        ],
                      ),
                      Text('Quang Trường', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: primaryColor)),
                    ],
                  ),
                ),
              ),

              // 2. THẺ SỐ DƯ HIỆN TẠI
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      if (!isDark) 
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
                    ],
                  ),
                  child: Column(
                    children: [
                      Text('SỐ DƯ HIỆN TẠI', style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                      const SizedBox(height: 8),
                      Text(currencyFormat.format(provider.totalBalance), style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _buildMiniStat(Icons.arrow_downward, 'Thu nhập', provider.totalIncome, Colors.green, subTextColor),
                          Container(width: 1, height: 30, color: isDark ? Colors.white10 : Colors.black12),
                          _buildMiniStat(Icons.arrow_upward, 'Chi tiêu', provider.totalExpense, Colors.redAccent, subTextColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 3. GRID 6 Ô THỐNG KÊ (Số liệu thực tế)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.5,
                  ),
                  delegate: SliverChildListDelegate([
                    _buildGridCard('Chi phí', provider.totalExpense, Colors.redAccent, currencyFormat, cardColor, isDark),
                    _buildGridCard('Thu nhập', provider.totalIncome, Colors.green, currencyFormat, cardColor, isDark),
                    _buildGridCard('Sắp tới', provider.upcomingAmount, Colors.blueAccent, currencyFormat, cardColor, isDark),
                    _buildGridCard('Quá hạn', provider.overdueAmount, Colors.orange, currencyFormat, cardColor, isDark),
                    _buildGridCard('Cho mượn', provider.totalLending, Colors.cyan, currencyFormat, cardColor, isDark),
                    _buildGridCard('Đã mượn', provider.totalBorrowing, Colors.indigoAccent, currencyFormat, cardColor, isDark),
                  ]),
                ),
              ),

              // 4. BIỂU ĐỒ & HEATMAP
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildChartSection(provider, cardColor, isDark),
                      const SizedBox(height: 16),
                      _buildHeatmapSection(cardColor, isDark),
                    ],
                  ),
                ),
              ),

              // Khoảng trống cuối trang
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET BIỂU ĐỒ TRÒN DỮ LIỆU THẬT ---
  Widget _buildChartSection(TransactionProvider provider, Color cardBg, bool isDark) {
    final chartData = provider.getExpenseChartData(isDark);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const CircleAvatar(radius: 4, backgroundColor: Colors.purple),
            const SizedBox(width: 10),
            Text('Phân bổ chi tiêu tháng ${DateTime.now().month}', 
                style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black))
          ]),
          const SizedBox(height: 30),
          SizedBox(
            height: 200,
            child: chartData.isEmpty 
              ? Center(child: Text('Chưa có chi tiêu tháng này', style: TextStyle(color: isDark ? Colors.white24 : Colors.black26)))
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sections: chartData,
                        sectionsSpace: 4,
                        centerSpaceRadius: 65,
                        startDegreeOffset: -90,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('TỔNG CHI', style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38, fontWeight: FontWeight.w800)),
                        FittedBox(
                          child: Text(
                            NumberFormat.compact().format(provider.currentMonthTotalExpense),
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF001A72)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  // --- CÁC WIDGET HELPERS ---
  Widget _buildMiniStat(IconData icon, String label, double amount, Color color, Color subColor) {
    return Expanded(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 12, color: subColor)),
        Text(NumberFormat.compact().format(amount), style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    ]));
  }

  Widget _buildGridCard(String label, double amount, Color color, NumberFormat format, Color cardBg, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(24)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : Colors.black87)),
        const SizedBox(height: 4),
        FittedBox(child: Text(format.format(amount), style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900))),
      ]),
    );
  }

  Widget _buildHeatmapSection(Color cardBg, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Hoạt động gần đây', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 13, mainAxisSpacing: 4, crossAxisSpacing: 4),
          itemCount: 52,
          itemBuilder: (context, index) => Container(
            decoration: BoxDecoration(
              color: (index % 7 == 0) ? Colors.blue.withOpacity(0.5) : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)), 
              borderRadius: BorderRadius.circular(3)
            )
          ),
        ),
      ]),
    );
  }
}