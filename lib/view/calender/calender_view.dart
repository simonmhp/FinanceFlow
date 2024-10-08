import 'dart:math';

import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moneytracker/common/color_extension.dart';
import 'package:moneytracker/common_widget/day_transactions.dart';
import 'package:moneytracker/view/home/helper.dart';
import 'package:moneytracker/view/settings/settings_view.dart';
import 'package:moneytracker/view/sqflite/db_helper.dart';

import '../../common_widget/subscription_cell.dart';

class CalenderView extends StatefulWidget {
  const CalenderView({super.key});

  @override
  State<CalenderView> createState() => _CalenderViewState();
}

class _CalenderViewState extends State<CalenderView> {
  CalendarAgendaController calendarAgendaControllerNotAppBar =
      CalendarAgendaController();
  late DateTime selectedDateNotAppBBar;
  List<Map<String, dynamic>> transactionData = [];
  String dayTotalExpense = "";

  Random random = Random();

  @override
  void initState() {
    super.initState();
    selectedDateNotAppBBar = DateTime.now();
    _fetchTransactionData();
  }

  Future<void> _fetchTransactionData() async {
    DatabaseHelper dbHelper = DatabaseHelper();

    // Format selected date to "yyyy-MM-dd"
    String formattedDate =
        DateFormat('yyyy-MM-dd').format(selectedDateNotAppBBar);

    // Pass the formatted date to the database method to get transactions
    List<Map<String, dynamic>> data =
        await dbHelper.getAllTransactionsForTheDaySelected(formattedDate);

    // Update the transaction data
    setState(() {
      transactionData = data;
    });

    // Fetch the total expense for the selected day
    double totalExpense = await dbHelper.getDateTotalExpense(formattedDate);

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
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: TColor.gray70.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25))),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Text(
                                      "Calendar",
                                      style: TextStyle(
                                          color: TColor.gray30, fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              // Row(
                              //   children: [
                              //     Spacer(),
                              //     IconButton(
                              //         onPressed: () {
                              //           Navigator.push(
                              //               context,
                              //               MaterialPageRoute(
                              //                   builder: (context) =>
                              //                       const SettingsView()));
                              //         },
                              //         icon: Image.asset(
                              //             "assets/img/settings.png",
                              //             width: 25,
                              //             height: 25,
                              //             color: TColor.gray30))
                              //   ],
                              // )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Transactions\nCalender",
                            style: TextStyle(
                                color: TColor.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${transactionData.length} transaction for the day",
                                style: TextStyle(
                                    color: TColor.gray30,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  calendarAgendaControllerNotAppBar
                                      .openCalender();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: TColor.border.withOpacity(0.1),
                                    ),
                                    color: TColor.gray60.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    children: [
                                      Text(
                                        DateFormat('MMMM')
                                            .format(selectedDateNotAppBBar),
                                        style: TextStyle(
                                            color: TColor.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Icon(
                                        Icons.expand_more,
                                        color: TColor.white,
                                        size: 16.0,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    CalendarAgenda(
                      controller: calendarAgendaControllerNotAppBar,
                      backgroundColor: Colors.transparent,
                      fullCalendarBackgroundColor: TColor.gray80,
                      locale: 'en',
                      weekDay: WeekDay.short,
                      fullCalendarDay: WeekDay.short,
                      selectedDateColor: TColor.white,
                      initialDate: DateTime.now(),
                      calendarEventColor: TColor.secondary,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 140)),
                      lastDate: DateTime.now().add(const Duration(days: 140)),
                      events: List.generate(
                          100,
                          (index) => DateTime.now().subtract(
                              Duration(days: index * random.nextInt(5)))),
                      onDateSelected: (date) {
                        setState(() {
                          selectedDateNotAppBBar = date;
                          _fetchTransactionData();
                        });
                      },
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: TColor.border.withOpacity(0.15),
                        ),
                        color: TColor.gray60.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      selectDecoration: BoxDecoration(
                        border: Border.all(
                          color: TColor.border.withOpacity(0.15),
                        ),
                        color: TColor.gray60,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      selectedEventLogo: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: TColor.secondary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      eventLogo: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: TColor.secondary,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('MMMM').format(selectedDateNotAppBBar),
                        style: TextStyle(
                            color: TColor.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        dayTotalExpense.toString(),
                        style: TextStyle(
                            color: TColor.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd-MM-yyyy').format(selectedDateNotAppBBar),
                        style: TextStyle(
                            color: TColor.gray30,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Day Expenditure",
                        style: TextStyle(
                            color: TColor.gray30,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      )
                    ],
                  )
                ],
              ),
            ),
            // Conditional rendering of transaction data
            transactionData.isNotEmpty
                ? ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: transactionData.length,
                    itemBuilder: (context, index) {
                      var transaction = transactionData[index];
                      return DayTransactions(
                        sObj: {
                          "transaction_type": transaction['transaction_type'],
                          "name":
                              transaction['description'], // Use category column
                          "icon":
                              transaction['categoryImg'], // Use category image
                          "price": HomeHelper.formatIndianCurrency(
                                  transaction['amount'])
                              .toString(), // Use the amount
                        },
                        onPressed: () {
                          // Handle row press
                        },
                      );
                    },
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {},
                        child: Container(
                          height: 64,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: TColor.border.withOpacity(0.1)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "No transactions found for the selected date.",
                                style: TextStyle(
                                    color: TColor.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(
              height: 130,
            ),
          ],
        ),
      ),
    );
  }
}
