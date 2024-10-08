import 'package:flutter/material.dart';
import 'package:moneytracker/common/color_extension.dart';
import 'package:moneytracker/common_widget/home_income.dart';
import 'package:moneytracker/view/home/helper.dart';
import 'package:moneytracker/view/sqflite/db_helper.dart';
import 'package:moneytracker/view/subscription_info/subscription_info_view.dart';
import '../../common_widget/custom_arc_painter.dart';
import '../../common_widget/segment_button.dart';
import '../../common_widget/status_button.dart';
import '../../common_widget/subscription_home_row.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool isSubscription = true; // True for Expense, False for Income
  List<Map<String, dynamic>> transactionData = [];
  double highestExpense = 0.0;
  double lowestExpense = 0.0;
  double monthTotalExpense = 0.0;
  double monthTotal = 0.0;
  double percentage = 0.0;
  double arcEndValue = 0.0;
  bool isLoading = false;

  Color getCategoryColor() {
    if (percentage <= 20) return Colors.green;
    if (percentage <= 40) return Colors.green.shade800; // Dark Green
    if (percentage <= 60) return Colors.orange;
    if (percentage <= 80) return Colors.red.shade200; // Light Red
    return Colors.red;
  }

  String getCategory() {
    if (percentage <= 20) return "Super Low";
    if (percentage <= 40) return "Low";
    if (percentage <= 60) return "Moderate";
    if (percentage <= 80) return "High";
    return "Very High";
  }

  @override
  void initState() {
    super.initState();
    _fetchTransactionData();
  }

  Future<void> _fetchTransactionData() async {
    setState(() {
      isLoading = true;
    });

    final dbHelper = DatabaseHelper();

    highestExpense = await dbHelper.getMonthHighestExpense();
    lowestExpense = await dbHelper.getMonthLowestExpense();
    monthTotalExpense = await dbHelper.getMonthTotalExpense();
    monthTotal = await dbHelper.getMonthIncomeTotal();

    percentage = (monthTotal == 0) ? 0 : (monthTotalExpense * 100) / monthTotal;
    percentage = percentage.clamp(0, 100);
    arcEndValue = (percentage * 270) / 100;

    final data = await dbHelper.getHomeTransactions();
    final creditData = await dbHelper.getIncomeForCurrentMonth();

    setState(() {
      transactionData = isSubscription ? data : creditData;
      isLoading = false; // Set loading to false when data is loaded
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No transactions available',
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 35.0, bottom: 15.0),
                            child: Text(
                              "Home",
                              style: TextStyle(
                                color: TColor.gray30,
                                fontSize: 16,
                                fontFamily: 'assets/font/Inter-Medium.ttf',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.only(bottom: media.width * 0.05),
                        width: media.width * 0.72,
                        height: media.width * 0.72,
                        child: CustomPaint(
                          painter: CustomArcPainter(end: arcEndValue),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: media.width * 0.05),
                      Text(
                        HomeHelper.formatIndianCurrency(monthTotalExpense),
                        style: TextStyle(
                          color: TColor.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: media.width * 0.07),
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
                          _fetchTransactionData();
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
                            getCategory(),
                            style: TextStyle(
                              color: getCategoryColor(),
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
                                    highestExpense),
                                statusColor: TColor.secondary,
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: StatusButton(
                                title: "Avg (per day)",
                                value: (monthTotalExpense /
                                        HomeHelper.getDaysInCurrentMonth())
                                    .toStringAsFixed(1),
                                statusColor: TColor.primary10,
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: StatusButton(
                                title: "Lowest",
                                value: HomeHelper.formatIndianCurrency(
                                    lowestExpense),
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
                          _fetchTransactionData();
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
                          _fetchTransactionData();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Show loading indicator when isLoading is true
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (transactionData.isNotEmpty)
              ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: transactionData.length,
                itemBuilder: (context, index) {
                  var transaction = transactionData[index];
                  return InkWell(
                    onTap: () {
                      // Handle the click event
                      print("Item clicked: ${transaction['description']}");
                      // Navigate to another screen or perform any action here
                    },
                    child: isSubscription
                        ? SubScriptionHomeRow(
                            sObj: {
                              "name": transaction['category'],
                              "icon": transaction['categoryImg'],
                              "price": HomeHelper.formatIndianCurrency(
                                      transaction['amount'])
                                  .toString(),
                            },
                            onPressed: () {
                              print("omega:" + isSubscription.toString());
                              if (isSubscription) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SubscriptionInfoView(
                                              sObj: {
                                                "icon":
                                                    transaction['categoryImg'],
                                                "name": transaction['category'],
                                                "date": transaction['date'],
                                                "price": HomeHelper
                                                        .formatIndianCurrency(
                                                            transaction[
                                                                'amount'])
                                                    .toString(),
                                              },
                                              onCallBack: () {
                                                // Call setState or any function to refresh the parent widget
                                                setState(() {
                                                  _fetchTransactionData();
                                                  // Refresh the state or reload the data
                                                });
                                              },
                                            )));
                              } else {}
                            }, // Optional, since we handle taps via InkWell
                          )
                        : HomeIncomeList(
                            sObj: {
                              "name": transaction['description'],
                              "date": transaction['date'],
                              "price": HomeHelper.formatIndianCurrency(
                                      transaction['amount'])
                                  .toString(),
                            },
                            onPressed: () {
                              if (isSubscription) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            SubscriptionInfoView(
                                              sObj: const {
                                                "icon": "",
                                                "name": "food",
                                                "price": "360",
                                              },
                                              onCallBack: () {
                                                // Call setState or any function to refresh the parent widget
                                                setState(() {
                                                  _fetchTransactionData();
                                                  // Refresh the state or reload the data
                                                });
                                              },
                                            )));
                              } else {}
                            }, // Optional, since we handle taps via InkWell
                          ),
                  );
                },
              )
            else
              _buildEmptyState(),
            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }
}
