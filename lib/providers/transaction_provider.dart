import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';
import '../data/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  // --- TRẠNG THÁI BỘ LỌC (Dùng cho tìm kiếm và lọc) ---
  String? _searchTerm;
  List<String> _selectedTypes = [];
  RangeValues _priceRange = const RangeValues(-15000000, 15000000);

  // --- LOGIC TÍNH TOÁN DASHBOARD ---
  double get totalIncome => _sumByType('Thu nhập');
  double get totalExpense => _sumByType('Chi tiêu');
  double get totalBalance => totalIncome - totalExpense;

  double get totalLending => _transactions.where((t) => t.type == 'Cho mượn' && t.isCompleted == 0).fold(0, (sum, t) => sum + t.amount);
  double get totalBorrowing => _transactions.where((t) => t.type == 'Vay nợ' && t.isCompleted == 0).fold(0, (sum, t) => sum + t.amount);

  double get overdueAmount {
    final now = DateTime.now();
    return _transactions.where((t) {
      if (t.isCompleted == 1 || t.dueDate == null) return false;
      try {
        final d = DateFormat('dd/MM/yyyy').parse(t.dueDate!);
        return d.isBefore(now);
      } catch (e) { return false; }
    }).fold(0, (sum, t) => sum + t.amount);
  }

  double get upcomingAmount {
    final now = DateTime.now();
    return _transactions.where((t) {
      if (t.isCompleted == 1 || t.dueDate == null || t.dueDate!.isEmpty) return false;
      try {
        final d = DateFormat('dd/MM/yyyy').parse(t.dueDate!);
        return d.isAfter(now);
      } catch (e) { return false; }
    }).fold(0, (sum, t) => sum + t.amount);
  }

  double _sumByType(String type) => _transactions.where((t) => t.type == type).fold(0, (sum, t) => sum + t.amount);

  // --- LOGIC BIỂU ĐỒ THẬT ---
  double get currentMonthTotalExpense {
    final now = DateTime.now();
    return _transactions.where((t) {
      try {
        final date = DateFormat('dd/MM/yyyy').parse(t.date);
        return t.type == 'Chi tiêu' && date.month == now.month && date.year == now.year;
      } catch (e) { return false; }
    }).fold(0, (sum, t) => sum + t.amount);
  }

  List<PieChartSectionData> getExpenseChartData(bool isDark) {
    final now = DateTime.now();
    final monthExpenses = _transactions.where((t) {
      try {
        final date = DateFormat('dd/MM/yyyy').parse(t.date);
        return t.type == 'Chi tiêu' && date.month == now.month && date.year == now.year;
      } catch (e) { return false; }
    }).toList();

    if (monthExpenses.isEmpty) return [];
    var grouped = groupBy(monthExpenses, (TransactionModel t) => t.title);
    double total = currentMonthTotalExpense;
    
    List<Color> colors = isDark 
        ? [Colors.greenAccent, Colors.purpleAccent, Colors.orangeAccent, Colors.blueAccent] 
        : [const Color(0xFF001A72), Colors.purple, Colors.orange, Colors.blue];

    int i = 0;
    return grouped.entries.map((e) {
      double sum = e.value.fold(0, (s, t) => s + t.amount);
      return PieChartSectionData(
        color: colors[i++ % colors.length], 
        value: sum, 
        title: '${(sum / total * 100).toStringAsFixed(0)}%', 
        radius: 50, 
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)
      );
    }).toList();
  }

  // --- HÀM CẬP NHẬT BỘ LỌC ---
  void updateFilters({String? search, List<String>? types, RangeValues? range}) {
    if (search != null) _searchTerm = search;
    if (types != null) _selectedTypes = types;
    if (range != null) _priceRange = range;
    notifyListeners();
  }

  List<TransactionModel> getFilteredTransactionsByMonth(int month, int year) {
    return _transactions.where((t) {
      try {
        final date = DateFormat('dd/MM/yyyy').parse(t.date);
        if (date.month != month || date.year != year) return false;

        // 1. Lọc theo tìm kiếm (Dùng description thay cho note)
        if (_searchTerm != null && _searchTerm!.isNotEmpty) {
          final term = _searchTerm!.toLowerCase();
          bool match = t.title.toLowerCase().contains(term) || (t.description?.toLowerCase().contains(term) ?? false);
          if (!match) return false;
        }

        // 2. Lọc theo loại
        if (_selectedTypes.isNotEmpty && !_selectedTypes.contains(t.type)) return false;

        // 3. Lọc theo giá
        if (t.amount < _priceRange.start || t.amount > _priceRange.end) return false;

        return true;
      } catch (e) { return false; }
    }).toList();
  }

  // --- DATABASE ACTIONS (ĐÃ ĐỦ CRUD) ---
  
  Future<void> loadTransactions() async {
    _isLoading = true; 
    notifyListeners();
    _transactions = await DatabaseHelper.instance.fetchAll();
    _isLoading = false; 
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel txn) async {
    await DatabaseHelper.instance.insert(txn);
    await loadTransactions();
  }

  // ✅ HÀM UPDATE ĐÃ QUAY TRỞ LẠI
  Future<void> updateTransaction(TransactionModel txn) async {
    await DatabaseHelper.instance.update(txn);
    await loadTransactions();
  }

  // ✅ HÀM DELETE CŨNG ĐÃ QUAY TRỞ LẠI
  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper.instance.delete(id);
    await loadTransactions();
  }
}