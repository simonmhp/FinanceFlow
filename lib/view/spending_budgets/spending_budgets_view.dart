import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:moneytracker/common/color_extension.dart';
import 'package:moneytracker/common_widget/budgets_row.dart';
import 'package:moneytracker/common_widget/custom_arc_180_painter.dart';
import 'package:moneytracker/common_widget/show_add_category_dialog.dart';
import 'package:moneytracker/view/sqflite/db_helper.dart';
import '../settings/settings_view.dart';
import 'package:intl/intl.dart';

class SpendingBudgetsView extends StatefulWidget {
  const SpendingBudgetsView({super.key});

  @override
  State<SpendingBudgetsView> createState() => _SpendingBudgetsViewState();
}

class _SpendingBudgetsViewState extends State<SpendingBudgetsView> {
  List<Map<String, dynamic>> budgetArr = [];
  double totalExpense = 0.0;

  Map<String, String> categoryImages = {
    "Food": "assets/add_icons/hot-pot.png",
    "Transportation": "assets/add_icons/commuting.png",
    "Miscellaneous": "assets/add_icons/magic-box.png",
    "Entertainment": "assets/add_icons/popcorn.png",
  };

  String getDisplayCategoryName(String category) {
    switch (category) {
      case 'Transportation':
        return 'Transportation';
      case 'Food':
        return 'Food';
      case 'Miscellaneous':
        return 'Miscellaneous';
      case 'Entertainment':
        return 'Entertainment';
      default:
        return category;
    }
  }

  List<ArcValueModel> arcValues = []; // List to hold arc values

  @override
  void initState() {
    super.initState();
    fetchBudgetData();
  }

  Future<void> fetchBudgetData() async {
    final dbHelper = DatabaseHelper();
    String currentMonth = getCurrentMonth();

    List<Map<String, dynamic>> budgets =
        await dbHelper.getBudgetsForMonth(currentMonth);
    List<Map<String, dynamic>> transactions =
        await dbHelper.getTransactionsForMonth();

    Map<String, double> amountSpentMap = {};
    totalExpense = 0;

    for (var transaction in transactions) {
      String category = transaction['category'];
      double amount = transaction['amount'];
      totalExpense += amount;

      if (amountSpentMap.containsKey(category)) {
        amountSpentMap[category] = amountSpentMap[category]! + amount;
      } else {
        amountSpentMap[category] = amount;
      }
    }

    // print("else: " + totalExpense.toString());

    budgetArr = budgets.map((budget) {
      String category = budget['category'];
      double totalBudget = budget['budget'];
      double amountSpent = amountSpentMap[category] ?? 0.0;
      double leftAmount = totalBudget - amountSpent;
      String displayCategory = getDisplayCategoryName(category);

      if (totalExpense > 0) {
        double percentage = (amountSpent / totalExpense) * 100;

        Color arcColor;

        switch (category) {
          case 'Food':
            arcColor = Colors.orange;
            break;
          case 'Transportation':
            arcColor = Colors.blue;
            break;
          case 'Entertainment':
            arcColor = Colors.purple;
            break;
          case 'Miscellaneous':
            arcColor = Colors.green;
            break;
          default:
            arcColor = Colors.grey;
        }

        arcValues.add(ArcValueModel(
          color: arcColor,
          value: percentage,
        ));
      }

      return {
        "name": displayCategory,
        "icon": categoryImages[category] ?? "assets/img/default.png",
        "spend_amount": amountSpent.toStringAsFixed(2),
        "total_budget": totalBudget.toStringAsFixed(2),
        "left_amount": leftAmount.toStringAsFixed(2),
        "color": TColor.secondaryG,
      };
    }).toList();

    setState(() {});
  }

  String getCurrentMonth() {
    DateTime now = DateTime.now();
    return DateFormat('MMM').format(now).toUpperCase();
  }

  String getBudgetStatus() {
    // Calculate total budget
    double totalBudget = budgetArr.fold<double>(
      0,
      (sum, budget) => sum + double.parse(budget['total_budget']),
    );

    if (totalBudget == 0) {
      return "No budget allocated";
    }
    double percentageSpent = (totalExpense / totalBudget) * 100;

    print("else: " + percentageSpent.toString());
    if (percentageSpent <= 20) {
      return "Your budget is Excellent!👍 ${percentageSpent.toStringAsFixed(2)}%";
    } else if (percentageSpent <= 50) {
      return "Your budgets are on track!😊 ${percentageSpent.toStringAsFixed(2)}%";
    } else if (percentageSpent <= 80) {
      return "Your budget will be depleting soon!😳 ${percentageSpent.toStringAsFixed(2)}%";
    } else if (percentageSpent <= 99) {
      return "Spend a little less!😒 ${percentageSpent.toStringAsFixed(2)}%";
    } else {
      return "Your budgets depleted! 👎";
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: TColor.gray,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 35, right: 10),
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
                    icon: Image.asset("assets/img/settings.png",
                        width: 25, height: 25, color: TColor.gray30),
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                  width: media.width * 0.5,
                  height: media.width * 0.30,
                  child: CustomPaint(
                    painter: CustomArc180Painter(
                      drwArcs: arcValues,
                      end: 100,
                      width: 12,
                      bgWidth: 8,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "\$${(arcValues.fold<double>(0, (sum, arc) => sum + (arc.value * totalExpense / 100))).toStringAsFixed(2)}",
                      style: TextStyle(
                          color: TColor.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      "of \$${(budgetArr.fold<double>(0, (sum, budget) => sum + double.parse(budget['total_budget']))).toStringAsFixed(2)} budget",
                      style: TextStyle(
                          color: TColor.gray30,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: TColor.border.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        getBudgetStatus(),
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
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: budgetArr.length,
              itemBuilder: (context, index) {
                var bObj = budgetArr[index];

                return BudgetsRow(
                  bObj: bObj,
                  onPressed: () {},
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: DottedBorder(
                  dashPattern: const [5, 4],
                  strokeWidth: 1,
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(16),
                  color: TColor.border.withOpacity(0.1),
                  child: GestureDetector(
                    onTap: () {
                      showAddCategoryDialog(context);
                    },
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Add new category ",
                            style: TextStyle(
                                color: TColor.gray30,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                          Image.asset(
                            "assets/img/add.png",
                            width: 12,
                            height: 12,
                            color: TColor.gray30,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }
}
