import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class TransactionHelper {
  static final TransactionHelper _instance = TransactionHelper._internal();

  factory TransactionHelper() {
    return _instance;
  }

  TransactionHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Initialize the database if it doesn't exist
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get the path to the database
    String path = join(await getDatabasesPath(), 'transactions_database.db');

    // Open or create the database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create the transactions table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        transaction_type TEXT NOT NULL,
        amount INTEGER NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        categoryImg TEXT NOT NULL
      )
    ''');
  }

  // Function to insert a transaction into the database
  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction);
  }

  // Fetch all transactions
  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;
    return await db.query('transactions');
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

  // Delete a transaction
  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update a transaction
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

  // Clear all transactions (truncate)
  Future<void> truncateTransactions() async {
    final db = await database;
    await db.delete('transactions'); // This effectively truncates the table
  }
}
