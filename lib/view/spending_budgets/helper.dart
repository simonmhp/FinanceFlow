class Helper {
  String getCurrentmonth() {
    DateTime now = DateTime.now();

    // Extract the current month
    List<String> monthNames = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    String currentMonth = monthNames[now.month - 1];

    // print('Current Month: $currentMonth');
    return currentMonth;
  }
}
