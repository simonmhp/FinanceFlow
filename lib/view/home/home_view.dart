import 'package:flutter/material.dart';
import 'package:moneytracker/common/color_extension.dart';
import 'package:moneytracker/view/home/helper.dart';
import 'package:moneytracker/view/sqflite/db_helper.dart';
import '../../common_widget/custom_arc_painter.dart';
import '../../common_widget/segment_button.dart';
import '../../common_widget/status_button.dart';
import '../../common_widget/subscription_home_row.dart';
import '../../common_widget/upcoming_bill_row.dart';
import '../settings/settings_view.dart';
import '../subscription_info/subscription_info_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool isSubscription = true; // True for Expense, False for Credit
  List<Map<String, dynamic>> transactionData =
      []; // To hold data from the transaction table
  double highestExpense = 0.0;
  double lowestExpense = 0.0;
  double monthTotalExpense = 0.0; // Variable to hold the highest expense

  @override
  void initState() {
    super.initState();
    _fetchTransactionData(); // Fetch the data when the view is initialized
  }

  Future<void> _fetchTransactionData() async {
    DatabaseHelper dbHelper = DatabaseHelper();

    // Fetch highest expense for the current month
    highestExpense = await dbHelper.getMonthHighestExpense();
    lowestExpense = await dbHelper.getMonthLowestExpense();
    monthTotalExpense = await dbHelper.getMonthCreditTotalExpense();

    if (isSubscription) {
      List<Map<String, dynamic>> data = await dbHelper
          .getHomeTransactions(); // Fetch Debit Transactions (Expenses)
      setState(() {
        transactionData = data;
      });
    } else {
      List<Map<String, dynamic>> creditData = await dbHelper
          .getCreditTransactionsForCurrentMonth(); // Fetch Credit Transactions
      setState(() {
        transactionData = creditData;
      });
    }

    // Refresh UI after fetching data
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: TColor.gray,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: media.width * 1.1,
              decoration: BoxDecoration(
                color: TColor.gray70.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset("assets/img/home_bg.png"),
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: media.width * 0.05),
                        width: media.width * 0.72,
                        height: media.width * 0.72,
                        child: CustomPaint(
                          painter: CustomArcPainter(end: 220),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Row(
                          children: [
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SettingsView(),
                                  ),
                                );
                              },
                              icon: Image.asset(
                                "assets/img/settings.png",
                                width: 25,
                                height: 25,
                                color: TColor.gray30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: media.width * 0.05),
                      SizedBox(height: media.width * 0.07),
                      Text(
                        HomeHelper.formatIndianCurrency(
                            monthTotalExpense), // x Display the highest expense
                        style: TextStyle(
                          color: TColor.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: media.width * 0.055),
                      Text(
                        "This month's Expenses",
                        style: TextStyle(
                          color: TColor.gray40,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: media.width * 0.07),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: TColor.border.withOpacity(0.15),
                            ),
                            color: TColor.gray60.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            "See your budget",
                            style: TextStyle(
                              color: TColor.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: StatusButton(
                                title: "Highest",
                                value: HomeHelper.formatIndianCurrency(
                                    highestExpense), // Update based on your logic
                                statusColor: TColor.secondary,
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: StatusButton(
                                title: "Avg (per day)",
                                value: (monthTotalExpense.toInt() /
                                        HomeHelper.getDaysInCurrentMonth())
                                    .toStringAsFixed(
                                        1), // Format to 2 decimal points
                                statusColor: TColor.primary10,
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: StatusButton(
                                title: "Lowest",
                                value: HomeHelper.formatIndianCurrency(
                                    lowestExpense), // Update based on your logic
                                statusColor: TColor.secondaryG,
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SegmentButton(
                      title: "Expense Category",
                      isActive: isSubscription,
                      onPressed: () {
                        setState(() {
                          isSubscription = true;
                          _fetchTransactionData(); // Fetch expense data
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: SegmentButton(
                      title: "Credit",
                      isActive: !isSubscription,
                      onPressed: () {
                        setState(() {
                          isSubscription = false;
                          _fetchTransactionData(); // Fetch credit data
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (isSubscription)
              ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: transactionData.length,
                itemBuilder: (context, index) {
                  var transaction = transactionData[index];
                  return SubScriptionHomeRow(
                    sObj: {
                      "name": transaction['category'], // Use category column
                      "icon": transaction['categoryImg'], // Use category image
                      "price":
                          HomeHelper.formatIndianCurrency(transaction['amount'])
                              .toString(), // Use the amount
                    },
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SubscriptionInfoView(sObj: transaction),
                        ),
                      );
                    },
                  );
                },
              ),
            if (!isSubscription)
              ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: transactionData.length,
                itemBuilder: (context, index) {
                  var transaction = transactionData[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8), // Margin for spacing
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TColor.gray60.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          transaction['date'].substring(8,
                              10), // Extracting day from date string (assuming format YYYY-MM-DD)
                          style: TextStyle(
                            color: TColor.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              transaction[
                                  'description'], // Display the description
                              style: TextStyle(
                                color: TColor.white,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        Text(
                          HomeHelper.formatIndianCurrency(
                              transaction['amount']), // Display the amount
                          style: TextStyle(
                            color: TColor.primary5,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(
              height: 110,
            ),
          ],
        ),
      ),
    );
  }

  // String formatIndianCurrency(double amount) {
  //   // Convert the amount to an integer
  //   int wholeAmount = amount.toInt();

  //   // Convert to string and add ₹ symbol
  //   String amountStr = '₹$wholeAmount';

  //   // Split the string into whole and decimal parts
  //   List<String> parts = amountStr.split('.');
  //   String wholePart = parts[0];

  //   // Apply Indian-style formatting
  //   String formattedWholePart = '';
  //   int length = wholePart.length;

  //   // Insert commas for thousands, lakhs, and crores
  //   for (int i = 0; i < length; i++) {
  //     if (i > 0 && (length - i) % 3 == 0 && (length - i) != 3) {
  //       formattedWholePart += ',';
  //     }
  //     formattedWholePart += wholePart[i];
  //   }

  //   return formattedWholePart;
  // }

  // String formatIndianCurrency(double amount) {
  //   // Convert the amount to an integer
  //   int wholeAmount = amount.toInt();

  //   // Handle crore and lakh cases
  //   if (wholeAmount >= 10000000) {
  //     // 1 crore
  //     double inCrores = wholeAmount / 10000000;
  //     return '₹${inCrores.toStringAsFixed(2).replaceAll('.00', '')}Cr'; // Remove .00 if it's a whole number
  //   } else if (wholeAmount >= 100000) {
  //     // 1 lakh
  //     double inLakhs = wholeAmount / 100000;
  //     return '₹${inLakhs.toStringAsFixed(2).replaceAll('.00', '')}L'; // Remove .00 if it's a whole number
  //   } else {
  //     // Convert to string and add ₹ symbol
  //     String amountStr = wholeAmount.toString();

  //     // Apply Indian-style formatting for thousands
  //     String formattedWholePart;

  //     if (amountStr.length > 3) {
  //       // Get last three digits
  //       String lastThreeDigits = amountStr.substring(amountStr.length - 3);
  //       String remainingDigits = amountStr.substring(0, amountStr.length - 3);

  //       // Add commas in the remaining digits
  //       if (remainingDigits.isNotEmpty) {
  //         formattedWholePart = remainingDigits.replaceAllMapped(
  //                 RegExp(r'(?<=\d)(?=(\d{2})+(?!\d))'), (Match m) => ',') +
  //             ',' +
  //             lastThreeDigits;
  //       } else {
  //         formattedWholePart = lastThreeDigits; // No remaining digits
  //       }
  //     } else {
  //       formattedWholePart = amountStr; // Less than 1000, no formatting needed
  //     }

  //     return '₹$formattedWholePart'; // Return the formatted amount
  //   }
  // }

  // int _getDaysInCurrentMonth() {
  //   final now = DateTime.now();
  //   // Using the next month's first day minus one day
  //   return DateTime(now.year, now.month + 1, 0).day;
  // }
}
