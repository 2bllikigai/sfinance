import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final provider = context.watch<TransactionProvider>();
    final chartData = provider.getExpenseChartData(isDark);
    
    final Color bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F7FF);
    final Color textColor = isDark ? Colors.white : const Color(0xFF001A72);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Thống kê chi tiêu', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: chartData.isEmpty 
                ? const Center(child: Text('Chưa có dữ liệu tháng này'))
                : PieChart(
                    PieChartData(
                      sections: chartData,
                      centerSpaceRadius: 60,
                      sectionsSpace: 4,
                    ),
                  ),
            ),
            const SizedBox(height: 20),
            Text('Tổng chi tiêu tháng này: ${NumberFormat.currency(locale: "vi_VN", symbol: "₫").format(provider.currentMonthTotalExpense)}', 
              style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}