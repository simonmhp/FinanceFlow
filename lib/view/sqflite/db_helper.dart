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
    String path = join(await getDatabasesPath(), 'user_database.db');

    // Open or create the database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create the user table
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
  }

  // Function to insert a user into the database
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  // Fetch all users (for testing purposes)
  // Future<List<Map<String, dynamic>>> getUsers() async {
  //   final db = await database;
  //   return await db.query('users');
  // }
  // logOut Users Truncate Method
  Future<void> truncateUsers() async {
    final db = await database;
    await db.execute('DELETE FROM users'); // Truncate the table
  }

  // Fetch a single user (returns the first user found)
  Future<Map<String, dynamic>?> getUser() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users', limit: 1);
    return maps.isNotEmpty ? maps.first : null; // Return the first user or null
  }
}



      // Store the user details in SQLite
      // await _databaseHelper.insertUser({
      //   'email': txtEmail.text.trim(),
      //   'password': txtPassword.text.trim(),
      //   'username': txtUsername.text.trim(), // Save username
      // });