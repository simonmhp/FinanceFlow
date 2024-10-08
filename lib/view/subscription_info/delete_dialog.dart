import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import the toast package
import 'package:moneytracker/common/color_extension.dart';
import 'package:moneytracker/view/sqflite/db_helper.dart'; // Import your DatabaseHelper class

class TransactionDeleteDialog extends StatelessWidget {
  final String transactionType;
  final String name;
  final String icon;
  final String price;
  final String date;
  final DatabaseHelper dbHelper;

  final VoidCallback onDeleteSuccess;

  const TransactionDeleteDialog({
    Key? key,
    required this.transactionType,
    required this.name,
    required this.icon,
    required this.price,
    required this.date,
    required this.dbHelper,
    required this.onDeleteSuccess, // Add this parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the border color based on the transaction type
    Color borderColor;
    if (transactionType == "Income") {
      borderColor = Colors.green.shade200; // Green for Income
    } else if (transactionType == "Expense") {
      borderColor = Colors.orange.shade500; // Orange for Expense
    } else {
      borderColor = TColor.border.withOpacity(0.15); // Default border color
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Center(
        child: Text(
          'Transaction Details',
          style: TextStyle(
            color: TColor.secondaryG,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: TColor.gray70,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInfoContainer(icon, name, borderColor),
          const SizedBox(height: 10),
          _buildInfoContainer(null, transactionType, borderColor),
          const SizedBox(height: 10),
          _buildInfoContainer(null, price, borderColor),
          const SizedBox(height: 10),
          _buildInfoContainer(null, date.substring(0, 10), borderColor),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Close',
            style: TextStyle(color: Colors.green.shade300),
          ),
        ),
        TextButton(
          onPressed: () async {
            print("data:" + date + ":" + transactionType + ":" + price);
            // Call removeExpenseEntry when Delete is pressed
            final success = await dbHelper.removeExpenseEntry(
                date, transactionType); // Make sure to pass price as well
            Navigator.pop(context); // Close the dialog after deletion

            if (success) {
              // Show success toast message
              Fluttertoast.showToast(
                msg: "Transaction deleted successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );

              onDeleteSuccess(); // Call the callback here to refresh the parent
            } else {
              // Show error toast message if deletion failed
              Fluttertoast.showToast(
                msg: "Failed to delete transaction",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          },
          child: Text(
            'Delete',
            style: TextStyle(color: TColor.secondary50),
          ),
        ),
      ],
    );
  }

  // Helper method to create a container with border
  Widget _buildInfoContainer(String? icon, String text, Color borderColor) {
    return Container(
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
          if (icon != null)
            Image.asset(
              icon,
              width: 40,
              height: 40,
            ),
          if (icon != null) const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 18,
              color: TColor.secondaryG,
            ),
          ),
        ],
      ),
    );
  }
}
