import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class Transaction {
  final int id;
  final String description;
  final String transactionType;
  final double amount;
  final String date;
  final String category;
  final String categoryImg;
  final int isSynced;

  Transaction({
    required this.id,
    required this.description,
    required this.transactionType,
    required this.amount,
    required this.date,
    required this.category,
    required this.categoryImg,
    required this.isSynced,
  });

  // Factory constructor to create a Transaction from a Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      description: map['description'],
      transactionType: map['transaction_type'],
      amount: map['amount'],
      date: map['date'],
      category: map['category'],
      categoryImg: map['categoryImg'],
      isSynced: map['isSynced'],
    );
  }

  // Method to convert a Transaction object to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'transaction_type': transactionType,
      'amount': amount,
      'date': date,
      'category': category,
      'categoryImg': categoryImg,
      'isSynced': isSynced,
    };
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // ******************* Create tables *******************

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
    categoryImg TEXT NOT NULL,
    isSynced INTEGER NOT NULL DEFAULT 0,  -- 0 = Not synced, 1 = Synced
    UNIQUE (date)  -- Ensures that the combination of date and category is unique
  )
''');

    // Create the Budget table
    await db.execute('''
      CREATE TABLE budget (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        budget REAL NOT NULL,
        month TEXT NOT NULL
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
    return maps.isNotEmpty ? maps.first : null;
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
    SELECT category, categoryImg, SUM(CASE WHEN transaction_type = 'Expense' THEN amount ELSE 0 END) as amount, date
    FROM transactions
    WHERE transaction_type = 'Expense'
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
    WHERE transaction_type = 'Expense'
      AND strftime('%Y', date) = ? 
      AND strftime('%m', date) = ?
  ''', ['$year', '$month']);

    // Check if the result is not empty and return the max amount or 0
    return result.isNotEmpty ? result.first['maxAmount'] ?? 0.0 : 0.0;
  }

  Future<double> getMonthIncomeTotal() async {
    final db = await database;

    // Get the current year and month
    final DateTime now = DateTime.now();
    final int year = now.year;
    final int month = now.month;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT SUM(amount) AS maxAmount
    FROM transactions
    WHERE transaction_type = 'Income' 
      AND strftime('%Y', date) = ? 
      AND strftime('%m', date) = ?
  ''', ['$year', '$month']);

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
    WHERE transaction_type = 'Expense'
      AND strftime('%Y', date) = ? 
      AND strftime('%m', date) = ?
  ''', ['$year', '$month']);

    // Check if the result is not empty and return the max amount or 0
    return result.isNotEmpty ? result.first['maxAmount'] ?? 0.0 : 0.0;
  }

  Future<double> getMonthTotalExpense() async {
    final db = await database;

    // Get the current year and month
    final DateTime now = DateTime.now();
    final int year = now.year;
    final int month = now.month;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT SUM(amount) AS maxAmount
    FROM transactions
    WHERE transaction_type = 'Expense'
      AND strftime('%Y', date) = ? 
      AND strftime('%m', date) = ?
  ''', ['$year', '$month']);

    // Check if the result is not empty and return the max amount or 0
    return result.isNotEmpty ? result.first['maxAmount'] ?? 0.0 : 0.0;
  }

  Future<List<Map<String, dynamic>>> getIncomeForCurrentMonth() async {
    final db = await database;

    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT *
    FROM transactions
    WHERE transaction_type = 'Income'
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
    return maps.isNotEmpty ? maps.first : null;
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
    await db.delete('transactions');
  }

  // ******************* Budget Table Methods *******************

  // Insert a budget into the database
  Future<int> insertBudget(Map<String, dynamic> budget) async {
    final db = await database;

    var existingEntry = await db.query(
      'budget',
      where: 'category = ? AND month = ?',
      whereArgs: [budget['category'], budget['month']],
    );

    if (existingEntry.isNotEmpty) {
      return await db.update(
        'budget',
        budget,
        where: 'category = ? AND month = ?',
        whereArgs: [budget['category'], budget['month']],
      );
    } else {
      return await db.insert('budget', budget);
    }
  }

// Fetch all budgets
  Future<List<Map<String, dynamic>>> getAllBudgets() async {
    final db = await database;
    return await db.query('budget');
  }

// Update a budget by ID
  Future<int> updateBudget(int id, Map<String, dynamic> budget) async {
    final db = await database;
    return await db.update(
      'budget',
      budget,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

// Delete a budget by ID
  Future<int> deleteBudget(int id) async {
    final db = await database;
    return await db.delete(
      'budget',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Truncate budget table
  Future<void> truncateBudgets() async {
    final db = await database;
    await db.delete('budget');
  }

  Future<List<Map<String, dynamic>>> getBudgetsForMonth(String month) async {
    final db = await database;

    List<Map<String, dynamic>> budgets = await db.query(
      'budget',
      where: 'month = ?',
      whereArgs: [month],
    );
    return budgets;
  }

  Future<List<Map<String, dynamic>>> getTransactionsForMonth() async {
    final db = await database;

    final int currentMonth = DateTime.now().month;
    final int currentYear = DateTime.now().year;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
  SELECT t.* 
  FROM transactions t
  JOIN budget b ON t.category = b.category
  WHERE strftime('%m', t.date) = ? 
    AND strftime('%Y', t.date) = ?
    AND t.transaction_type = 'Expense'  -- Ensure that the transaction type is 'Expense'
  ''', [currentMonth.toString().padLeft(2, '0'), currentYear.toString()]);

    return result;
  }

  // ******************* Calender View Methods *******************

  Future<List<Map<String, dynamic>>> getAllTransactionsForTheDaySelected(
      String selectedDate) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT * 
    FROM transactions 
    WHERE date LIKE ? 
  ''', ['$selectedDate%']);

    return result;
  }

  Future<double> getDateTotalExpense(String selectedDate) async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT SUM(amount) as TotalExpense 
    FROM transactions 
    WHERE transaction_type = 'Expense' AND date LIKE ? 
  ''', ['$selectedDate%']);

    if (result.isNotEmpty && result[0]['TotalExpense'] != null) {
      return result[0]['TotalExpense'] as double;
    }
    return 0.0;
  }

  Future<double> getMonthTotalIncome(
      String selectedMonth, String selectedYear) async {
    final db = await database;

    // Construct the date range for the specified month
    String startDate = '$selectedYear-$selectedMonth-01 00:00:00';
    String endDate =
        '$selectedYear-$selectedMonth-31 23:59:59'; // End of the month

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT SUM(amount) as TotalIncome 
    FROM transactions 
    WHERE transaction_type = 'Income' AND date BETWEEN ? AND ?
  ''', [startDate, endDate]);

    if (result.isNotEmpty && result[0]['TotalIncome'] != null) {
      return result[0]['TotalIncome'] as double;
    }
    return 0.0;
  }

  // ******************* Expense Detail Card View Methods *******************

// The function to get category expenses for the current month
  Future<List<Map<String, dynamic>>> getMonthCategoryExpense(
      String category) async {
    final db = await database;

    String currentMonth = DateFormat('MM').format(DateTime.now());
    String currentYear = DateFormat('yyyy').format(DateTime.now());

    List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT * 
    FROM transactions
    WHERE category = ? 
      AND strftime('%m', date) = ? 
      AND strftime('%Y', date) = ? 
      AND transaction_type = ?
  ''', [category, currentMonth, currentYear, 'Expense']);

    return result;
  }

  // ******************* Expense Delete Dialog-Box Methods *******************

  // Handle delete operations only for Sqflite database.
  // Future<bool> removeTransactionEntry(String date, String category) async {
  //   final db = await database; // Your database instance

  //   // Execute the delete query
  //   final result = await db.delete(
  //     'transactions',
  //     where: 'date = ? AND transaction_type = ? ',
  //     whereArgs: [date, category],
  //   );

  //   // Check if the deletion was successful
  //   return result > 0; // If one or more rows were deleted, return true
  // }

  // Handle Delete operation for isSynced = 1 to delete in Sflite and Firebase database.
  Future<bool> removeTransactionEntry(String date, String category) async {
    final db = await database; // Your database instance

    List<Map<String, dynamic>> syncedTransactions = await db.query(
      'transactions',
      where: 'date = ? AND category = ? AND isSynced = 1',
      whereArgs: [date, category],
    );
    if (syncedTransactions.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DatabaseReference ref =
            FirebaseDatabase.instance.ref("users/${user.uid}/transactions");

        DataSnapshot snapshot = await ref.get();

        if (snapshot.exists) {
          Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

          String? keyToDelete;

          data.forEach((key, value) {
            if (value['date'] == date && value['category'] == category) {
              keyToDelete = key;
            }
          });

          if (keyToDelete != null) {
            await ref.child(keyToDelete!).remove();
          }
        }
      }
    }

    final result = await db.delete(
      'transactions',
      where: 'date = ? AND category = ?',
      whereArgs: [date, category],
    );

    return result > 0;
  }

  // ******************* Settings  Methods *******************

  // Method to update the username where email matches
  Future<int> updateUsername(String newUsername, String email) async {
    final db = await database;

    return await db.update(
      'users',
      {'username': newUsername},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // ******************* Settings Firebase related Methods *******************

  Future<int> countUnsyncedTransactions() async {
    final db = await database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT COUNT(*) as count 
    FROM transactions 
    WHERE isSynced = 0
  ''');

    // Return the count or 0 if no result is found
    return result.isNotEmpty ? result.first['count'] as int : 0;
  }

  Future<List<Transaction>> getUnsyncedTransactions() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT * FROM transactions WHERE isSynced = 0
  ''');

    return List.generate(maps.length, (i) {
      return Transaction.fromMap(maps[i]);
    });
  }

  Future<int> updateTransactionSyncStatus(
      int transactionId, bool isSynced) async {
    final db = await database;

    int syncValue = isSynced ? 1 : 0;

    final result = await db.rawUpdate('''
    UPDATE transactions 
    SET isSynced = ? 
    WHERE id = ?
  ''', [syncValue, transactionId]);

    return result;
  }
}
