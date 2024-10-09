import 'package:intl/intl.dart';
import 'package:moneytracker/view/sqflite/db_helper.dart';

Future<void> checkAndTruncateBudget() async {
  final dbHelper = DatabaseHelper();

  DateTime now = DateTime.now();
  String currentMonth = DateFormat('MMM').format(now).toUpperCase();

  final db = await dbHelper.database;
  List<Map<String, dynamic>> lastMonthEntry = await db.query(
    'budget',
    columns: ['month'],
    orderBy: 'id DESC',
    limit: 1,
  );

  if (lastMonthEntry.isNotEmpty) {
    String lastMonth = lastMonthEntry.first['month'];

    if (lastMonth != currentMonth) {
      await dbHelper.truncateBudgets();
    }
  } else {
    await dbHelper.truncateBudgets();
  }
}
