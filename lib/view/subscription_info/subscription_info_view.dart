import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:moneytracker/common_widget/expense_card_transaction.dart';
import 'package:moneytracker/common_widget/secondary_boutton.dart';
import 'package:moneytracker/view/home/helper.dart';
import 'package:moneytracker/view/sqflite/db_helper.dart';
import 'package:moneytracker/view/subscription_info/delete_dialog.dart';

import '../../common/color_extension.dart';

class SubscriptionInfoView extends StatefulWidget {
  final Map sObj;
  final VoidCallback onCallBack;
  const SubscriptionInfoView({
    super.key,
    required this.sObj,
    required this.onCallBack,
  });

  @override
  State<SubscriptionInfoView> createState() => _SubscriptionInfoViewState();
}

class _SubscriptionInfoViewState extends State<SubscriptionInfoView> {
  List<Map<String, dynamic>> transactionData = [];
  String dayTotalExpense = "";
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();

    _fetchTransactionData();
  }

  Future<void> _fetchTransactionData() async {
    // Pass the formatted date to the database method to get transactions
    List<Map<String, dynamic>> data =
        await dbHelper.getMonthCategoryExpense(widget.sObj['name']);

    // Update the transaction data
    setState(() {
      transactionData = data;
    });

    // Fetch the total expense for the selected day
    double totalExpense =
        await dbHelper.getDateTotalExpense(widget.sObj['date']);

    // Update the dayTotalExpense state
    setState(() {
      dayTotalExpense = HomeHelper.formatIndianCurrency(totalExpense);
    });

    // Refresh UI after fetching data
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: TColor.gray,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xff282833).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Container(
                      height: media.width * 0.9,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: TColor.gray70,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  widget.onCallBack();
                                },
                                icon: Image.asset("assets/img/dorp_down.png",
                                    width: 20,
                                    height: 20,
                                    color: TColor.gray30),
                              ),
                              Text(
                                "Subscription info",
                                style: TextStyle(
                                    color: TColor.gray30, fontSize: 16),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Image.asset("assets/img/Trash.png",
                                    width: 25,
                                    height: 25,
                                    color: TColor.gray30),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Image.asset(
                            widget.sObj["icon"],
                            width: media.width * 0.25,
                            height: media.width * 0.25,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            widget.sObj["name"],
                            style: TextStyle(
                                color: TColor.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            "\$${widget.sObj["price"]}",
                            style: TextStyle(
                                color: TColor.gray30,
                                fontSize: 20,
                                fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: TColor.border.withOpacity(0.1),
                              ),
                              color: TColor.gray60.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 0),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: transactionData.length,
                              itemBuilder: (context, index) {
                                var transaction = transactionData[index];
                                return DayExpenseTransactions(
                                  sObj: {
                                    "date": transaction['date'],
                                    "transaction_type":
                                        transaction['transaction_type'],
                                    "name": transaction[
                                        'description'], // Use category column
                                    "icon": transaction[
                                        'categoryImg'], // Use category image
                                    "price": HomeHelper.formatIndianCurrency(
                                            transaction['amount'])
                                        .toString(),
                                    // Use the amount
                                  },
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return TransactionDeleteDialog(
                                          transactionType:
                                              transaction['transaction_type'],
                                          name: transaction['description'],
                                          icon: transaction['categoryImg'],
                                          price:
                                              HomeHelper.formatIndianCurrency(
                                                      transaction['amount'])
                                                  .toString(),
                                          date: transaction['date'],
                                          dbHelper: dbHelper,
                                          onDeleteSuccess: () {
                                            // Call setState or any function to refresh the parent widget
                                            setState(() {
                                              _fetchTransactionData();
                                              // Refresh the state or reload the data
                                            });
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SecondaryButton(title: "Save", onPressed: () {})
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20, left: 4, right: 4),
                height: media.width * 0.9 + 15,
                alignment: Alignment.bottomCenter,
                child: Row(children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: TColor.gray,
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  Expanded(
                      child: DottedBorder(
                    dashPattern: const [5, 10],
                    padding: EdgeInsets.zero,
                    strokeWidth: 1,
                    radius: const Radius.circular(16),
                    color: TColor.gray,
                    child: const SizedBox(
                      height: 0,
                    ),
                  )),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: TColor.gray,
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ]),
              )
            ],
          ),
        ),
      ),
    );
  }
}
