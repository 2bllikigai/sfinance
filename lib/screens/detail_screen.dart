import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import 'add_edit_screen.dart';

class DetailScreen extends StatelessWidget {
  final TransactionModel transaction;

  const DetailScreen({super.key, required this.transaction});

  // Dialog xóa giao dịch
  void _showDeleteDialog(BuildContext context, bool isDark, Color primary) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Xác nhận xóa?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Giao dịch này sẽ được gỡ bỏ khỏi hệ thống bảo mật.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Hủy', style: TextStyle(color: isDark ? Colors.white38 : Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<TransactionProvider>(context, listen: false).deleteTransaction(transaction.id!);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Xóa ngay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lắng nghe Theme
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final provider = context.watch<TransactionProvider>();
    
    // 2. Định nghĩa bộ màu động (Khớp với Home & Add/Edit)
    final Color primaryColor = isDark ? Colors.greenAccent : const Color(0xFF001A72);
    final Color bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F7FF);
    final Color cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF001A72);

    // Tìm giao dịch mới nhất để cập nhật UI ngay lập tức khi vừa sửa xong
    final currentTxn = provider.transactions.firstWhere(
      (t) => t.id == transaction.id,
      orElse: () => transaction,
    );

    final isIncome = currentTxn.type == 'Thu nhập';
    final bool isLoan = currentTxn.isLoan == 1;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor), 
          onPressed: () => Navigator.pop(context)
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_note_rounded, color: textColor),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddEditScreen(transaction: currentTxn))),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _showDeleteDialog(context, isDark, primaryColor),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- HEADER: ICON & SỐ TIỀN ---
            _buildHeader(currentTxn, isIncome, currencyFormat, isDark, textColor),

            const SizedBox(height: 40),

            // --- THÔNG TIN CHI TIẾT ---
            _buildDetailCard(currentTxn, isDark, isLoan, cardColor, textColor),

            const SizedBox(height: 32),

            // --- NÚT THAO TÁC (CHỈ DÀNH CHO VAY/NỢ) ---
            if (isLoan) 
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      provider.updateTransaction(currentTxn.copyWith(
                        isCompleted: currentTxn.isCompleted == 1 ? 0 : 1
                      ));
                    },
                    icon: Icon(currentTxn.isCompleted == 1 ? Icons.undo_rounded : Icons.check_circle_rounded),
                    label: Text(
                      currentTxn.isCompleted == 1 ? 'ĐÁNH DẤU CHƯA TRẢ' : 'XÁC NHẬN ĐÃ XONG',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: currentTxn.isCompleted == 1 ? Colors.grey : Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TransactionModel txn, bool isIncome, NumberFormat format, bool isDark, Color textColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: isIncome ? Colors.green.withValues(alpha:  0.1) : Colors.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            txn.isLoan == 1 ? Icons.handshake_rounded : (isIncome ? Icons.account_balance_wallet : Icons.shopping_bag),
            color: isIncome ? Colors.green : Colors.redAccent,
            size: 50,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '${isIncome ? '+' : '-'}${format.format(txn.amount)}',
          style: TextStyle(color: isIncome ? Colors.green : (isDark ? Colors.white : Colors.black87), fontSize: 40, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(txn.title.toUpperCase(), 
          style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
      ],
    );
  }

  Widget _buildDetailCard(TransactionModel txn, bool isDark, bool isLoan, Color cardBg, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          if(!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          _buildRow('Thời gian', txn.date, Icons.calendar_today_rounded, isDark, textColor),
          _buildDivider(isDark),
          _buildRow('Loại giao dịch', txn.type, Icons.category_rounded, isDark, textColor),
          
          if (isLoan) ...[
            _buildDivider(isDark),
            _buildRow('Hạn thanh toán', txn.dueDate ?? 'Không có', Icons.timer_outlined, isDark, textColor, valueColor: Colors.orange),
            _buildDivider(isDark),
            _buildRow(
              'Trạng thái', 
              txn.isCompleted == 1 ? 'Đã hoàn thành' : 'Đang chờ xử lý', 
              Icons.info_outline_rounded, 
              isDark,
              textColor,
              valueColor: txn.isCompleted == 1 ? Colors.green : Colors.redAccent
            ),
          ],
          
          if (txn.description != null && txn.description!.isNotEmpty) ...[
            _buildDivider(isDark),
            _buildRow('Ghi chú', txn.description!, Icons.notes_rounded, isDark, textColor),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, IconData icon, bool isDark, Color mainText, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: isDark ? Colors.white38 : Colors.black38, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor ?? (isDark ? Colors.white : Colors.black87))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1, 
      indent: 70, 
      endIndent: 20, 
      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)
    );
  }
}