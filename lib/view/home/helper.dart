class HomeHelper {
  // Method to format amount in Indian currency style
  static String formatIndianCurrency(double amount) {
    // Convert the amount to an integer
    int wholeAmount = amount.toInt();

    // Handle crore and lakh cases
    if (wholeAmount >= 10000000) {
      // 1 crore
      double inCrores = wholeAmount / 10000000;
      return '₹${inCrores.toStringAsFixed(2).replaceAll('.00', '')}Cr'; // Remove .00 if it's a whole number
    } else if (wholeAmount >= 100000) {
      // 1 lakh
      double inLakhs = wholeAmount / 100000;
      return '₹${inLakhs.toStringAsFixed(2).replaceAll('.00', '')}L'; // Remove .00 if it's a whole number
    } else {
      // Convert to string and add ₹ symbol
      String amountStr = wholeAmount.toString();

      // Apply Indian-style formatting for thousands
      String formattedWholePart;

      if (amountStr.length > 3) {
        // Get last three digits
        String lastThreeDigits = amountStr.substring(amountStr.length - 3);
        String remainingDigits = amountStr.substring(0, amountStr.length - 3);

        // Add commas in the remaining digits
        if (remainingDigits.isNotEmpty) {
          formattedWholePart = remainingDigits.replaceAllMapped(
                  RegExp(r'(?<=\d)(?=(\d{2})+(?!\d))'), (Match m) => ',') +
              ',' +
              lastThreeDigits;
        } else {
          formattedWholePart = lastThreeDigits; // No remaining digits
        }
      } else {
        formattedWholePart = amountStr; // Less than 1000, no formatting needed
      }

      return '₹$formattedWholePart'; // Return the formatted amount
    }
  }

  // Method to get the number of days in the current month
  static int getDaysInCurrentMonth() {
    final now = DateTime.now();
    // Using the next month's first day minus one day
    return DateTime(now.year, now.month + 1, 0).day;
  }
}
