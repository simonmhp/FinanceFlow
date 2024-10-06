import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize the database if it doesn't exist
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get the path to the database
    String path =
        join(await getDatabasesPath(), 'app_database.db'); // Unified DB

    // Open or create the database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // ******************* Create both users and transactions tables *******************

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        username TEXT NOT NULL,
        dataChange TEXT DEFAULT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        transaction_type TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        categoryImg TEXT NOT NULL
      )
    ''');
  }

  // ******************* User Table Methods *******************

  // Insert a user into the database
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  // Fetch a single user (returns the first user found)
  Future<Map<String, dynamic>?> getUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users', limit: 1);
    return maps.isNotEmpty ? maps.first : null; // Return the first user or null
  }

  // Truncate users table (log out)
  Future<void> truncateUsers() async {
    final db = await database;
    await db.execute('DELETE FROM users'); // Truncate the table
  }

  // ******************* Transaction Table Methods *******************

  // Insert a transaction into the database
  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction);
  }

  // Fetch all transactions and group them by category and image
  Future<List<Map<String, dynamic>>> getHomeTransactions() async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT category, categoryImg, SUM(CASE WHEN transaction_type = 'Debit' THEN amount ELSE 0 END) as amount
    FROM transactions
    WHERE transaction_type = 'Debit'
    GROUP BY category, categoryImg
  ''');

    return result;
  }

  Future<double> getMonthHighestExpense() async {
    final db = await database;

    // Get the current year and month
    final DateTime now = DateTime.now();
    final int year = now.year;
    final int month = now.month;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT MAX(amount) AS maxAmount
    FROM transactions
    WHERE transaction_type = 'Debit'
      AND strftime('%Y', date) = ? 
      AND strftime('%m', date) = ?
  ''', ['$year', '$month']); // Bind year and month as parameters

    // Check if the result is not empty and return the max amount or 0
    return result.isNotEmpty ? result.first['maxAmount'] ?? 0.0 : 0.0;
  }

  Future<double> getMonthLowestExpense() async {
    final db = await database;

    // Get the current year and month
    final DateTime now = DateTime.now();
    final int year = now.year;
    final int month = now.month;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT MIN(amount) AS maxAmount
    FROM transactions
    WHERE transaction_type = 'Debit'
      AND strftime('%Y', date) = ? 
      AND strftime('%m', date) = ?
  ''', ['$year', '$month']); // Bind year and month as parameters

    // Check if the result is not empty and return the max amount or 0
    return result.isNotEmpty ? result.first['maxAmount'] ?? 0.0 : 0.0;
  }

  Future<double> getMonthCreditTotalExpense() async {
    final db = await database;

    // Get the current year and month
    final DateTime now = DateTime.now();
    final int year = now.year;
    final int month = now.month;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT SUM(amount) AS maxAmount
    FROM transactions
    WHERE transaction_type = 'Debit'
      AND strftime('%Y', date) = ? 
      AND strftime('%m', date) = ?
  ''', ['$year', '$month']); // Bind year and month as parameters

    // Check if the result is not empty and return the max amount or 0
    return result.isNotEmpty ? result.first['maxAmount'] ?? 0.0 : 0.0;
  }

  Future<List<Map<String, dynamic>>>
      getCreditTransactionsForCurrentMonth() async {
    final db = await database;

    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT description, amount, date
    FROM transactions
    WHERE transaction_type = 'Credit'
    AND strftime('%m', date) = ? 
    AND strftime('%Y', date) = ?
  ''', [currentMonth.toString().padLeft(2, '0'), currentYear.toString()]);

    return result;
  }

  // Fetch a single transaction by ID
  Future<Map<String, dynamic>?> getTransaction(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty
        ? maps.first
        : null; // Return the first transaction or null
  }

  // Update a transaction by ID
  Future<int> updateTransaction(
      int id, Map<String, dynamic> transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a transaction by ID
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Truncate transactions table
  Future<void> truncateTransactions() async {
    final db = await database;
    await db.delete('transactions'); // This effectively truncates the table
  }
}
