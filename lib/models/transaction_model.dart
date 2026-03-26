class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final String date;
  final String type; // 'Thu nhập', 'Chi tiêu', 'Cho mượn', 'Vay nợ'
  final String? description; // Đây là biến Ghi chú
  final String? dueDate;
  final int isLoan;
  final int isCompleted;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    this.description,
    this.dueDate,
    this.isLoan = 0,
    this.isCompleted = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date,
      'type': type,
      'description': description,
      'due_date': dueDate,
      'is_loan': isLoan,
      'is_completed': isCompleted,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: map['date'] ?? '',
      type: map['type'] ?? '',
      description: map['description'],
      dueDate: map['due_date'],
      isLoan: map['is_loan'] ?? 0,
      isCompleted: map['is_completed'] ?? 0,
    );
  }

  TransactionModel copyWith({
    int? id, String? title, double? amount, String? date,
    String? type, String? description, String? dueDate,
    int? isLoan, int? isCompleted,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isLoan: isLoan ?? this.isLoan,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}