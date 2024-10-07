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
  double monthTotal = 0.0;
  double percentage = 0.0;
  double arcEndValue = 0.0;

  Color getCategoryColor() {
    if (percentage <= 20) {
      return Colors.green;
    } else if (percentage <= 40) {
      return Colors.green[800]!; // Dark Green
    } else if (percentage <= 60) {
      return Colors.orange;
    } else if (percentage <= 80) {
      return Colors.red[200]!; // Light Red
    } else {
      return Colors.red;
    }
  }

  // Function to determine category based on percentage
  String getCategory() {
    if (percentage <= 20) {
      return "Super Low";
    } else if (percentage <= 40) {
      return "Low";
    } else if (percentage <= 60) {
      return "Moderate";
    } else if (percentage <= 80) {
      return "High";
    } else {
      return "Very High";
    }
  }

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
    monthTotalExpense = await dbHelper.getMonthTotalExpense();
    monthTotal = await dbHelper.getMonthTotal();
    percentage = (monthTotalExpense * 100) / monthTotal;
    percentage = percentage > 100 ? 100 : percentage;
    arcEndValue = (percentage * 270) / 100;
    arcEndValue = arcEndValue.clamp(0, 270);

    if (isSubscription) {
      List<Map<String, dynamic>> data = await dbHelper.getHomeTransactions();
      setState(() {
        transactionData = data;
      });
    } else {
      List<Map<String, dynamic>> creditData = await dbHelper
          .getIncomeForCurrentMonth(); // Fetch Credit Transactions
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
                          painter: CustomArcPainter(end: arcEndValue),
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
                        onTap: () {
                          // Handle the onTap action if needed
                        },
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
                            getCategory(), // Use the category text
                            style: TextStyle(
                              color: getCategoryColor(), // Use category color
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
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
                      title: "Expense",
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
                      title: "Income",
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
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) =>
                      //         SubscriptionInfoView(sObj: transaction),
                      //   ),
                      // );
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
}
