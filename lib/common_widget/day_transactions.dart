import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class DayTransactions extends StatelessWidget {
  final Map sObj;
  final VoidCallback onPressed;

  const DayTransactions(
      {super.key, required this.sObj, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // Assuming "transaction_type" holds the value "Income" or "Expense"
    String transactionType = sObj["transaction_type"]; // "Income" or "Expense"

    // Determine the border and price text color based on the transaction type
    Color borderColor;
    Color priceTextColor;
    if (transactionType == "Income") {
      borderColor = Colors.green.shade200; // Green for Income
      priceTextColor =
          Colors.green.shade200; // Green for the price text as well
    } else if (transactionType == "Expense") {
      borderColor = Colors.orange.shade500; // Red for Expense
      priceTextColor = Colors.orange.shade500; // Red for the price text as well
    } else {
      borderColor = TColor.border.withOpacity(0.15); // Default border color
      priceTextColor = TColor.white; // Default text color
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Container(
          height: 64,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor, // Use the dynamically set border color
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Row(
            children: [
              Image.asset(
                sObj["icon"],
                width: 40,
                height: 40,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  sObj["name"],
                  style: TextStyle(
                      color: TColor.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                "${sObj["price"]}",
                style: TextStyle(
                    color:
                        priceTextColor, // Use the dynamically set price text color
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              )
            ],
          ),
        ),
      ),
    );
  }
}
