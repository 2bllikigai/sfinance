import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';
import '../models/transaction_model.dart';
import 'detail_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final List<DateTime> _months = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Tạo 12 tháng từ 6 tháng trước đến 5 tháng sau
    for (int i = -6; i <= 5; i++) {
      _months.add(DateTime(now.year, now.month + i, 1));
    }
    _tabController = TabController(initialIndex: 6, length: _months.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final primaryBlue = isDark ? Colors.greenAccent : const Color(0xFF001A72);
    final bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F7FF);
    final textColor = isDark ? Colors.white : const Color(0xFF001A72);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Tìm tiêu đề hoặc ghi chú...',
                  hintStyle: TextStyle(color: textColor.withOpacity(0.3)),
                  border: InputBorder.none,
                ),
                onChanged: (val) => context.read<TransactionProvider>().updateFilters(search: val),
              )
            : Text('Giao dịch', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textColor)),
        actions: [
          // Nút Tìm kiếm
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: primaryBlue),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<TransactionProvider>().updateFilters(search: '');
                }
              });
            },
          ),
          // Nút Lọc
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: primaryBlue),
            onPressed: () => _showFilterSheet(context, isDark),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: primaryBlue,
          indicatorWeight: 3,
          labelColor: primaryBlue,
          unselectedLabelColor: isDark ? Colors.white38 : Colors.black38,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: _months.map((date) => Tab(text: 'Tháng ${date.month}\n${date.year}')).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _months.map((date) => _MonthList(month: date.month, year: date.year)).toList(),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterBottomSheet(isDark: isDark),
    );
  }
}

// --- DANH SÁCH GIAO DỊCH THEO THÁNG ---
class _MonthList extends StatelessWidget {
  final int month;
  final int year;
  const _MonthList({required this.month, required this.year});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final provider = context.watch<TransactionProvider>();
    final txns = provider.getFilteredTransactionsByMonth(month, year);

    if (txns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: isDark ? Colors.white10 : Colors.black12),
            const SizedBox(height: 16),
            Text('Không có dữ liệu', style: TextStyle(color: isDark ? Colors.white24 : Colors.black26)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: txns.length,
      itemBuilder: (context, index) {
        final txn = txns[index];
        final isIncome = txn.type == 'Thu nhập';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ListTile(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(transaction: txn))),
            leading: CircleAvatar(
              backgroundColor: isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              child: Icon(isIncome ? Icons.add : Icons.remove, color: isIncome ? Colors.green : Colors.red),
            ),
            title: Text(txn.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(txn.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            trailing: Text(
              NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(txn.amount),
              style: TextStyle(color: isIncome ? Colors.green : (isDark ? Colors.white : Colors.black87), fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}

// --- BỘ LỌC BOTTOM SHEET (GIỐNG ẢNH MẪU) ---
class _FilterBottomSheet extends StatefulWidget {
  final bool isDark;
  const _FilterBottomSheet({required this.isDark});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  RangeValues _currentRange = const RangeValues(-5000000, 5000000);
  List<String> _selectedTypes = [];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Tất cả', 'icon': Icons.grid_view_rounded},
    {'name': 'Ăn uống', 'icon': Icons.restaurant},
    {'name': 'Tạp hóa', 'icon': Icons.shopping_basket},
    {'name': 'Mua sắm', 'icon': Icons.local_mall},
    {'name': 'Di chuyển', 'icon': Icons.directions_bus},
  ];

  @override
  Widget build(BuildContext context) {
    final primary = widget.isDark ? Colors.greenAccent : const Color(0xFF001A72);
    final bg = widget.isDark ? const Color(0xFF171717) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Text('Bộ Lọc', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: primary))),
          const SizedBox(height: 24),
          
          // 1. Logo Categories
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: primary.withOpacity(0.1),
                      child: Icon(_categories[i]['icon'], color: primary),
                    ),
                    const SizedBox(height: 4),
                    Text(_categories[i]['name'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text('Khoảng giá', style: TextStyle(fontWeight: FontWeight.bold, color: primary)),
          RangeSlider(
            values: _currentRange,
            min: -20000000, max: 20000000,
            divisions: 40,
            activeColor: primary,
            labels: RangeLabels(_currentRange.start.round().toString(), _currentRange.end.round().toString()),
            onChanged: (v) => setState(() => _currentRange = v),
          ),

          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: ['Thu nhập', 'Chi tiêu', 'Cho mượn', 'Vay nợ'].map((type) {
              final isSelected = _selectedTypes.contains(type);
              return FilterChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (val) {
                  setState(() {
                    val ? _selectedTypes.add(type) : _selectedTypes.remove(type);
                  });
                },
                selectedColor: primary.withOpacity(0.2),
                checkmarkColor: primary,
              );
            }).toList(),
          ),

          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đặt lại'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primary),
                  onPressed: () {
                    context.read<TransactionProvider>().updateFilters(
                      types: _selectedTypes,
                      range: _currentRange,
                    );
                    Navigator.pop(context);
                  },
                  child: Text('Áp dụng', style: TextStyle(color: widget.isDark ? Colors.black : Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}