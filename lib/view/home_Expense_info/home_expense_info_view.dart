import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneytracker/common_widget/expense_card_transaction.dart';
import 'package:moneytracker/view/home/helper.dart';
import 'package:moneytracker/view/sqflite/db_helper.dart';
import 'package:moneytracker/view/home_Expense_info/delete_dialog.dart';

import '../../common/color_extension.dart';

class HomeExpenseInfoView extends StatefulWidget {
  final Map sObj;
  final VoidCallback onCallBack;
  const HomeExpenseInfoView({
    super.key,
    required this.sObj,
    required this.onCallBack,
  });

  @override
  State<HomeExpenseInfoView> createState() => _HomeExpenseInfoViewState();
}

class _HomeExpenseInfoViewState extends State<HomeExpenseInfoView> {
  List<Map<String, dynamic>> transactionData = [];
  String dayTotalExpense = "";
  DatabaseHelper dbHelper = DatabaseHelper();
  String formattedMonth = "";

  @override
  void initState() {
    super.initState();

    DateTime parsedDate = DateTime.parse(widget.sObj['date']);
    formattedMonth = DateFormat('MMMM').format(parsedDate);
    _fetchTransactionData();
  }

  Future<void> _fetchTransactionData() async {
    List<Map<String, dynamic>> data =
        await dbHelper.getMonthCategoryExpense(widget.sObj['name']);

    setState(() {
      transactionData = data;
    });

    double totalExpense =
        await dbHelper.getDateTotalExpense(widget.sObj['date']);
    setState(() {
      dayTotalExpense = HomeHelper.formatIndianCurrency(totalExpense);
    });
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
                                formattedMonth,
                                style: TextStyle(
                                    color: TColor.gray30, fontSize: 16),
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
                            "${widget.sObj["price"]}",
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
                                    "name": transaction['description'],
                                    "icon": transaction['categoryImg'],
                                    "price": HomeHelper.formatIndianCurrency(
                                            transaction['amount'])
                                        .toString(),
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
                                            setState(() {
                                              _fetchTransactionData();
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
