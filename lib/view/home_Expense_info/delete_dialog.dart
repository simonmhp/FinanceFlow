import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moneytracker/common/color_extension.dart';
import 'package:moneytracker/view/sqflite/db_helper.dart';

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
    required this.onDeleteSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    if (transactionType == "Income") {
      borderColor = TColor.primary5;
    } else if (transactionType == "Expense") {
      borderColor = Colors.orange.shade500;
    } else {
      borderColor = TColor.border.withOpacity(0.15);
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
            final success =
                await dbHelper.removeTransactionEntry(date, transactionType);
            Navigator.pop(context);

            if (success) {
              Fluttertoast.showToast(
                msg: "Transaction deleted successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0,
              );

              onDeleteSuccess();
            } else {
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

  Widget _buildInfoContainer(String? icon, String text, Color borderColor) {
    return Container(
      height: 64,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor,
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
