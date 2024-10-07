import 'package:flutter/material.dart';
import 'package:moneytracker/common_widget/round_budget_textfield.dart';
import '../common/color_extension.dart';
import 'package:intl/intl.dart';

import '../view/sqflite/db_helper.dart'; // Import for currency formatting

void showAddCategoryDialog(BuildContext context) {
  final TextEditingController budgetController = TextEditingController();
  String? selectedCategory;
  String? selectedMonth;

  List<String> categories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Miscellaneous'
  ];
  List<String> months = [
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

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Center(
          child: Text(
            'Add New Category',
            style: TextStyle(
              color: TColor.secondaryG,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: TColor.gray,
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: TColor.gray,
                      border: Border.all(color: TColor.secondaryG50),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text(
                            'Select Category',
                            style: TextStyle(color: TColor.secondaryG50),
                          ),
                          value: selectedCategory,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCategory = newValue;
                            });
                          },
                          dropdownColor: TColor.gray60,
                          items: categories
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(color: TColor.secondaryG50),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: RoundBudgetTextField(
                      title: 'Budget',
                      controller: budgetController,
                      keyboardType: TextInputType.number,
                      onChanged: (text) {
                        // Only allow numeric characters (0-9)
                        String newText = text.replaceAll(RegExp(r'[^0-9]'), '');

                        // Update the controller with the new text
                        budgetController.value = TextEditingValue(
                          text: newText,
                          selection:
                              TextSelection.collapsed(offset: newText.length),
                        );

                        // If newText is not empty, format it as Indian currency
                        if (newText.isNotEmpty) {
                          double value = double.parse(newText);
                          String formattedText = formatAsIndianCurrency(value);

                          // Update the text field with formatted text
                          budgetController.value = TextEditingValue(
                            text: formattedText,
                            selection: TextSelection.collapsed(
                                offset: formattedText.length),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: TColor.gray,
                      border: Border.all(color: TColor.secondaryG50),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text(
                            'Select Month',
                            style: TextStyle(color: TColor.secondaryG50),
                          ),
                          value: selectedMonth,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedMonth = newValue;
                            });
                          },
                          dropdownColor: TColor.gray60,
                          items: months
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(color: TColor.secondaryG50),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel', style: TextStyle(color: TColor.secondary50)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Add', style: TextStyle(color: Colors.green.shade300)),
            onPressed: () async {
              // Validate and save the data
              if (selectedCategory != null &&
                  budgetController.text.isNotEmpty &&
                  selectedMonth != null) {
                // Convert the formatted currency back to an integer value
                int budgetValue = (double.tryParse(budgetController.text
                            .replaceAll(RegExp(r'[^0-9]'), ''))
                        ?.toInt() ??
                    0);

                Map<String, dynamic> budgetData = {
                  'category': selectedCategory,
                  'budget': budgetValue,
                  'month': selectedMonth,
                };

                // Call your insert method here
                // DatabaseHelper().insertBudget(budgetData);
                final dbHelper =
                    DatabaseHelper(); // Instantiate your DatabaseHelper
                await dbHelper.insertBudget(budgetData);

                Navigator.of(context).pop(); // Close the dialog
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}

// Function to format the input as Indian currency
String formatAsIndianCurrency(double amount) {
  // Use NumberFormat to format the amount
  final format =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
  return format.format(amount);
}
