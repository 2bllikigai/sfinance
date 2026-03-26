import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../providers/theme_provider.dart';

class AddEditScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const AddEditScreen({super.key, this.transaction});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descController;
  
  String _selectedType = 'Chi tiêu';
  DateTime _selectedDate = DateTime.now();
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    final txn = widget.transaction;
    _titleController = TextEditingController(text: txn?.title ?? '');
    _amountController = TextEditingController(
      text: txn != null ? txn.amount.toStringAsFixed(txn.amount == txn.amount.toInt() ? 0 : 1) : ''
    );
    _descController = TextEditingController(text: txn?.description ?? '');
    
    if (txn != null) {
      _selectedType = txn.type;
      try {
        _selectedDate = DateFormat('dd/MM/yyyy').parse(txn.date);
        if (txn.dueDate != null && txn.dueDate!.isNotEmpty) {
          _dueDate = DateFormat('dd/MM/yyyy').parse(txn.dueDate!);
        }
      } catch (e) {
        _selectedDate = DateTime.now();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- LOGIC XỬ LÝ DỮ LIỆU ---
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final bool isLoanType = _selectedType == 'Cho mượn' || _selectedType == 'Vay nợ';

      final newTxn = TransactionModel(
        id: widget.transaction?.id,
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        date: DateFormat('dd/MM/yyyy').format(_selectedDate),
        type: _selectedType,
        description: _descController.text.trim(),
        dueDate: _dueDate != null ? DateFormat('dd/MM/yyyy').format(_dueDate!) : null,
        isLoan: isLoanType ? 1 : 0,
        isCompleted: widget.transaction?.isCompleted ?? 0,
      );

      final provider = Provider.of<TransactionProvider>(context, listen: false);

      if (widget.transaction == null) {
        provider.addTransaction(newTxn);
      } else {
        provider.updateTransaction(newTxn);
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lắng nghe Theme
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    // 2. Thiết lập màu sắc động
    final Color primaryColor = isDark ? Colors.greenAccent : const Color(0xFF001A72);
    final Color bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF5F7FF);
    final Color cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF001A72);

    final isEditMode = widget.transaction != null;
    final bool isLoanSelected = _selectedType == 'Cho mượn' || _selectedType == 'Vay nợ';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isEditMode ? 'Sửa giao dịch' : 'Thêm giao dịch', 
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildAmountField(isDark, textColor),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTypeSelector(primaryColor, isDark),
                      const SizedBox(height: 24),
                      _buildTextField(_titleController, 'Tên giao dịch', Icons.edit_note, isDark),
                      const SizedBox(height: 16),
                      _buildListTile('Ngày giao dịch', DateFormat('dd/MM, yyyy').format(_selectedDate), Icons.event, () => _presentDatePicker(), isDark),
                      if (isLoanSelected) ...[
                        const SizedBox(height: 12),
                        _buildListTile(
                          'Hạn thanh toán', 
                          _dueDate == null ? 'Chưa chọn hạn' : DateFormat('dd/MM, yyyy').format(_dueDate!), 
                          Icons.notification_important_outlined, 
                          () => _presentDueDatePicker(), 
                          isDark,
                          color: Colors.orangeAccent
                        ),
                      ],
                      const SizedBox(height: 16),
                      _buildTextField(_descController, 'Ghi chú thêm', Icons.description_outlined, isDark, maxLines: 2),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildSaveButton(isEditMode, primaryColor, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // --- CÁC WIDGET HELPER ---

  Widget _buildAmountField(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: TextFormField(
        controller: _amountController,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: textColor),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: '0', 
          border: InputBorder.none, 
          suffixText: ' ₫',
          hintStyle: TextStyle(color: isDark ? Colors.white10 : Colors.black12),
        ),
        validator: (value) => (value == null || double.tryParse(value) == null) ? 'Nhập số tiền' : null,
      ),
    );
  }

  Widget _buildTypeSelector(Color primary, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<String>(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: primary,
          selectedForegroundColor: isDark ? Colors.black : Colors.white,
          side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
        segments: const [
          ButtonSegment(value: 'Chi tiêu', label: Text('Chi'), icon: Icon(Icons.outbound, size: 16)),
          ButtonSegment(value: 'Thu nhập', label: Text('Thu'), icon: Icon(Icons.next_plan, size: 16)),
          ButtonSegment(value: 'Cho mượn', label: Text('Cho mượn'), icon: Icon(Icons.handshake, size: 16)),
          ButtonSegment(value: 'Vay nợ', label: Text('Vay nợ'), icon: Icon(Icons.money_off, size: 16)),
        ],
        selected: {_selectedType},
        onSelectionChanged: (newSelection) => setState(() => _selectedType = newSelection.first),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, bool isDark, {int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: isDark ? Colors.white38 : Colors.black38),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha:  0.03) : Colors.black.withValues(alpha: 0.03),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildListTile(String title, String subtitle, IconData icon, VoidCallback onTap, bool isDark, {Color? color}) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
      leading: Icon(icon, color: color ?? (isDark ? Colors.white70 : Colors.black54)),
      title: Text(title, style: TextStyle(fontSize: 13, color: isDark ? Colors.white38 : Colors.black38)),
      subtitle: Text(subtitle, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87, fontSize: 16)),
      onTap: onTap,
    );
  }

  Widget _buildSaveButton(bool isEditMode, Color primary, bool isDark) {
    return SizedBox(
      width: double.infinity, height: 60,
      child: ElevatedButton(
        onPressed: _saveForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isDark ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Text(isEditMode ? 'CẬP NHẬT GIAO DỊCH' : 'LƯU GIAO DỊCH', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      ),
    );
  }

  // --- HÀM CHỌN NGÀY (Giữ nguyên logic của Trường) ---
  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (pickedDate != null) setState(() => _selectedDate = pickedDate);
  }

  void _presentDueDatePicker() async {
    final pickedDate = await showDatePicker(context: context, initialDate: _dueDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
    if (pickedDate != null) setState(() => _dueDate = pickedDate);
  }
}