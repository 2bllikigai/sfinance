import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite_sqlcipher/sqflite.dart'; 
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as ffi;
import 'package:path/path.dart';
import '../models/transaction_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  final String _encryptionKey = "SFINANCE_SECRET_KEY_2024_@123";

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('finance_secure_v3.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      ffi.sqfliteFfiInit();
      return await ffi.databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 3,
          onCreate: _createDB,
          onUpgrade: _onUpgrade,
        ),
      );
    }

    return await openDatabase(
      path,
      password: _encryptionKey,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    // Bảng Giao dịch (Đầy đủ cột cho Grid UI)
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT,
        due_date TEXT,
        is_loan INTEGER DEFAULT 0,
        is_completed INTEGER DEFAULT 0
      )
    ''');

    // Bảng Người dùng
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        otp_code TEXT,
        otp_expiry INTEGER
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE transactions ADD COLUMN due_date TEXT');
      await db.execute('ALTER TABLE transactions ADD COLUMN is_loan INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE transactions ADD COLUMN is_completed INTEGER DEFAULT 0');
    }
  }

  // --- LOGIC BẢO MẬT & TÀI KHOẢN ---
  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<int> registerUser(String email, String password) async {
    final db = await instance.database;
    return await db.insert('users', {
      'email': email,
      'password': _hashPassword(password),
    });
  }

  Future<bool> loginUser(String email, String password) async {
    final db = await instance.database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, _hashPassword(password)],
    );
    return result.isNotEmpty;
  }

  // --- CÁC HÀM THAO TÁC DỮ LIỆU (CRUD) ---

  // 1. Thêm mới
  Future<int> insert(TransactionModel txn) async {
    final db = await instance.database;
    return await db.insert('transactions', txn.toMap());
  }

  // 2. Lấy danh sách
  Future<List<TransactionModel>> fetchAll() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'id DESC');
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  // 3. Cập nhật (Hàm này giúp hết lỗi đỏ ở Provider)
  Future<int> update(TransactionModel txn) async {
    final db = await instance.database;
    return await db.update(
      'transactions',
      txn.toMap(),
      where: 'id = ?',
      whereArgs: [txn.id],
    );
  }

  // 4. Xóa (Hàm này giúp hết lỗi đỏ ở Provider)
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Hàm tính tổng (Dashboard)
  Future<double> getTotalByLoanType(String type, bool completed) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM transactions WHERE type = ? AND is_completed = ?',
      [type, completed ? 1 : 0]
    );
    return result.first['total'] != null ? (result.first['total'] as num).toDouble() : 0.0;
  }
}