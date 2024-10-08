import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:moneytracker/common/color_extension.dart';
import 'package:moneytracker/common_widget/primary_button.dart';
import 'package:moneytracker/common_widget/round_dropdown.dart';
import 'package:moneytracker/common_widget/round_textfield.dart';
import 'package:moneytracker/view/sqflite/db_helper.dart';
import '../../common_widget/image_button.dart';

class AddSubScriptionView extends StatefulWidget {
  const AddSubScriptionView({super.key});

  @override
  State<AddSubScriptionView> createState() => _AddSubScriptionViewState();
}

class _AddSubScriptionViewState extends State<AddSubScriptionView> {
  final TextEditingController txtDescription = TextEditingController();
  late TextEditingController
      _amountController; // Declare a persistent controller for amount
  String? selectedTransactionType;
  String? selectedCategory;
  String? selectedCategoryImg;

  final List<Map<String, String>> subCategories = [
    {"name": "Salary", "icon": "assets/add_icons/salary.png"},
    {"name": "Freelancing", "icon": "assets/add_icons/freelancer.png"},
    {"name": "Investments", "icon": "assets/add_icons/investment.png"},
    {"name": "Entertainment", "icon": "assets/add_icons/popcorn.png"},
    {"name": "Housing", "icon": "assets/add_icons/mansion.png"},
    {"name": "Transportation", "icon": "assets/add_icons/commuting.png"},
    {"name": "Food", "icon": "assets/add_icons/hot-pot.png"},
    {"name": "Healthcare", "icon": "assets/add_icons/drugs.png"},
    {"name": "Clothing", "icon": "assets/add_icons/clothes-hanger.png"},
    {"name": "Personal Care", "icon": "assets/add_icons/personal-hygiene.png"},
    {"name": "Miscellaneous", "icon": "assets/add_icons/magic-box.png"},
    {"name": "Others", "icon": "assets/add_icons/application.png"},
  ];

  double amountVal = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize the amount controller with the current amount value
    _amountController =
        TextEditingController(text: amountVal.toStringAsFixed(0));
    print("omega:" + DateTime.now().toIso8601String());
  }

  @override
  void dispose() {
    // Dispose controllers to free up resources
    txtDescription.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _addTransaction(BuildContext context) async {
    if (selectedCategory != null &&
        selectedTransactionType != null &&
        amountVal != 0 &&
        txtDescription.text.isNotEmpty) {
      try {
        final transactionData = {
          'description': txtDescription.text,
          'transaction_type': selectedTransactionType,
          'amount': amountVal,
          'date': DateTime.now().toIso8601String(),
          'category': selectedCategory,
          'categoryImg': selectedCategoryImg,
        };

        final dbHelper = DatabaseHelper();
        int id = await dbHelper.insertTransaction(transactionData);

        if (id > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction added successfully!')),
          );
          Navigator.pop(context);
        } else {
          throw Exception("Transaction failed to insert");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to add transaction: $e")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select and Insert all Fields.")),
      );
    }
  }

  // double amountVal = 0.0; // Use double for financial amounts

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: TColor.gray,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(media),
            _buildCarousel(media),
            _buildDescriptionField(),
            _buildTransactionTypeDropdown(),
            _buildAmountControls(),
            _buildAddTransactionButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Size media) {
    return Container(
      decoration: BoxDecoration(
        color: TColor.gray70.withOpacity(0.5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Image.asset(
                        "assets/img/back.png",
                        width: 25,
                        height: 25,
                        color: TColor.gray30,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "New",
                      style: TextStyle(color: TColor.gray30, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "Transaction",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel(Size media) {
    return SizedBox(
      width: media.width,
      height: media.width * 0.6,
      child: CarouselSlider.builder(
        options: CarouselOptions(
          autoPlay: false,
          aspectRatio: 1,
          enlargeCenterPage: true,
          enableInfiniteScroll: true,
          viewportFraction: 0.65,
          enlargeFactor: 0.4,
          enlargeStrategy: CenterPageEnlargeStrategy.zoom,
          initialPage: 0,
        ),
        itemCount: subCategories.length,
        itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
          var category = subCategories[itemIndex];
          bool isSelected = selectedCategory ==
              category["name"]; // Check if this category is selected

          return GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategory = category["name"];
                  selectedCategoryImg = category["icon"];
                });
              },
              child: TweenAnimationBuilder(
                tween: ColorTween(
                  begin: Colors.transparent,
                  end: isSelected
                      ? Colors.blue.withOpacity(0.2)
                      : Colors.transparent,
                ),
                duration: const Duration(milliseconds: 300),
                builder: (context, color, child) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category["name"];
                        selectedCategoryImg = category["icon"];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              category["icon"]!,
                              width: media.width * 0.4,
                              height: media.width * 0.4,
                              fit: BoxFit.fitHeight,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              category["name"]!,
                              style: TextStyle(
                                color: TColor.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ));
        },
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Padding(
      padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
      child: RoundTextField(
        title: "Description",
        titleAlign: TextAlign.center,
        controller: txtDescription,
      ),
    );
  }

  Widget _buildTransactionTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
      child: RoundDropdown(
        title: "Transaction Type",
        items: const ["Income", "Expense"],
        selectedValue: selectedTransactionType,
        onChanged: (String? newValue) {
          setState(() {
            selectedTransactionType = newValue;
          });
        },
      ),
    );
  }

  Widget _buildAmountControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ImageButton(
            image: "assets/img/minus.png",
            onPressed: () {
              setState(() {
                amountVal -= 1;
                if (amountVal < 0) {
                  amountVal = 0;
                }
                _amountController.text =
                    amountVal.toStringAsFixed(0); // Update controller
              });
            },
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  "Amount",
                  style: TextStyle(
                    color: TColor.gray40,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: TColor.gray70),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: TColor.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                      controller:
                          _amountController, // Use the persistent controller
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixText: "₹",
                        prefixStyle: TextStyle(
                          color: TColor.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          amountVal = double.tryParse(value) ?? amountVal;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          ImageButton(
            image: "assets/img/plus.png",
            onPressed: () {
              setState(() {
                amountVal += 1;
                _amountController.text =
                    amountVal.toStringAsFixed(0); // Update controller
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAddTransactionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: PrimaryButton(
        title: "Add this transaction",
        onPressed: () => _addTransaction(context),
      ),
    );
  }
}
