import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moneytracker/view/add_transaction/add_transaction_view.dart';
import 'package:moneytracker/view/main_tab/helper.dart';
import 'package:moneytracker/view/settings/settings_view.dart';
import 'package:moneytracker/common/color_extension.dart';
import 'package:moneytracker/view/sqflite/db_helper.dart';

import '../calender/calender_view.dart';
import '../home/home_view.dart';
import '../spending_budgets/spending_budgets_view.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selectTab = 0;
  PageStorageBucket pageStorageBucket = PageStorageBucket();
  Widget currentTabView = const HomeView();

  bool isFirstLogin = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    checkAndTruncateBudget();

    if (isFirstLogin) {
      fetchRemoteTransactions();
      setState(() {
        isFirstLogin = false;
      });
    }
  }

  Future<void> fetchRemoteTransactions() async {
    final user = FirebaseAuth.instance.currentUser;

    DatabaseReference ref =
        FirebaseDatabase.instance.ref("users/${user?.uid}/transactions");
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      for (var key in data.keys) {
        if (data[key] != null) {
          Map<String, dynamic> dt = Map<String, dynamic>.from(data[key]);
          dt.remove('id');
          dt['isSynced'] = 1;

          final dbHelper = DatabaseHelper();
          await dbHelper.insertTransaction(dt);
        } else {}
      }
      setState(() {
        currentTabView = const HomeView();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.gray,
      body: Stack(children: [
        PageStorage(bucket: pageStorageBucket, child: currentTabView),
        SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset("assets/img/bottom_bar_bg.png"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  selectTab = 0;
                                  currentTabView = const HomeView();
                                });
                              },
                              icon: Image.asset(
                                "assets/img/home.png",
                                width: 20,
                                height: 20,
                                color: selectTab == 0
                                    ? TColor.white
                                    : TColor.gray30,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  selectTab = 1;
                                  currentTabView = const SpendingBudgetsView();
                                });
                              },
                              icon: Image.asset(
                                "assets/img/budgets.png",
                                width: 20,
                                height: 20,
                                color: selectTab == 1
                                    ? TColor.white
                                    : TColor.gray30,
                              ),
                            ),
                            const SizedBox(width: 50, height: 50),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  selectTab = 2;
                                  currentTabView = const CalenderView();
                                });
                              },
                              icon: Image.asset(
                                "assets/img/calendar.png",
                                width: 20,
                                height: 20,
                                color: selectTab == 2
                                    ? TColor.white
                                    : TColor.gray30,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  selectTab = 3;
                                  currentTabView = const SettingsView();
                                });
                              },
                              icon: Image.asset(
                                "assets/img/settings.png",
                                width: 20,
                                height: 20,
                                color: selectTab == 3
                                    ? TColor.white
                                    : TColor.gray30,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddTransactionView(),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: TColor.secondary.withOpacity(0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Image.asset(
                          "assets/img/center_btn.png",
                          width: 55,
                          height: 55,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ]),
    );
  }
}

class Transaction {
  final int id;
  final String description;
  final String transactionType;
  final double amount;
  final String date;
  final String category;
  final String categoryImg;
  final int isSynced;

  Transaction({
    required this.id,
    required this.description,
    required this.transactionType,
    required this.amount,
    required this.date,
    required this.category,
    required this.categoryImg,
    required this.isSynced,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      description: map['description'],
      transactionType: map['transaction_type'],
      amount: map['amount'],
      date: map['date'],
      category: map['category'],
      categoryImg: map['categoryImg'],
      isSynced: map['isSynced'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'transaction_type': transactionType,
      'amount': amount,
      'date': date,
      'category': category,
      'categoryImg': categoryImg,
      'isSynced': isSynced,
    };
  }
}
