class HomeHelper {
  // Method to format amount in Indian currency style
  static String formatIndianCurrency(double amount) {
    int wholeAmount = amount.toInt();

    if (wholeAmount >= 10000000) {
      double inCrores = wholeAmount / 10000000;
      return '₹${inCrores.toStringAsFixed(2).replaceAll('.00', '')}Cr';
    } else if (wholeAmount >= 100000) {
      double inLakhs = wholeAmount / 100000;
      return '₹${inLakhs.toStringAsFixed(2).replaceAll('.00', '')}L';
    } else {
      String amountStr = wholeAmount.toString();

      String formattedWholePart;

      if (amountStr.length > 3) {
        String lastThreeDigits = amountStr.substring(amountStr.length - 3);
        String remainingDigits = amountStr.substring(0, amountStr.length - 3);

        if (remainingDigits.isNotEmpty) {
          // ignore: prefer_interpolation_to_compose_strings
          formattedWholePart = remainingDigits.replaceAllMapped(
                  RegExp(r'(?<=\d)(?=(\d{2})+(?!\d))'), (Match m) => ',') +
              ',' +
              lastThreeDigits;
        } else {
          formattedWholePart = lastThreeDigits;
        }
      } else {
        formattedWholePart = amountStr;
      }

      return '₹$formattedWholePart';
    }
  }

  // Method to get the number of days in the current month
  static int getDaysInCurrentMonth() {
    final now = DateTime.now();

    return DateTime(now.year, now.month + 1, 0).day;
  }
}
