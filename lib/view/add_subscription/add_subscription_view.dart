import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:moneytracker/common/color_extension.dart';
import 'package:moneytracker/common_widget/primary_button.dart';
import 'package:moneytracker/common_widget/round_dropdown.dart';
import 'package:moneytracker/common_widget/round_textfield.dart';
import '../../common_widget/image_button.dart';

class AddSubScriptionView extends StatefulWidget {
  const AddSubScriptionView({super.key});

  @override
  State<AddSubScriptionView> createState() => _AddSubScriptionViewState();
}

class _AddSubScriptionViewState extends State<AddSubScriptionView> {
  TextEditingController txtDescription = TextEditingController();
  String? selectedTransactionType; // Added for dropdown state management

  List subArr = [
    {
      "name": "Salary",
      "icon": "assets/add_icons/salary.png",
    },
    {
      "name": "Freelancing",
      "icon": "assets/add_icons/freelancer.png",
    },
    {
      "name": "Investments",
      "icon": "assets/add_icons/investment.png",
    },
    {
      "name": "Entertainment",
      "icon": "assets/add_icons/popcorn.png",
    },
    {
      "name": "Housing",
      "icon": "assets/add_icons/mansion.png",
    },
    {
      "name": "Transportation",
      "icon": "assets/add_icons/commuting.png",
    },
    {
      "name": "Food",
      "icon": "assets/add_icons/hot-pot.png",
    },
    {
      "name": "Healthcare",
      "icon": "assets/add_icons/drugs.png",
    },
    {
      "name": "Clothing",
      "icon": "assets/add_icons/clothes-hanger.png",
    },
    {
      "name": "Personal Care",
      "icon": "assets/add_icons/personal-hygiene.png",
    },
    {
      "name": "Miscellaneous",
      "icon": "assets/add_icons/magic-box.png",
    },
    {
      "name": "Others",
      "icon": "assets/add_icons/application.png",
    },
  ];

  int amountVal = 90;

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
                              style:
                                  TextStyle(color: TColor.gray30, fontSize: 16),
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
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(
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
                            initialPage: 0, // Always start from the first index
                          ),
                          itemCount: subArr.length,
                          itemBuilder: (BuildContext context, int itemIndex,
                              int pageViewIndex) {
                            var sObj = subArr[itemIndex] as Map? ?? {};
                            return Container(
                              margin: const EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    sObj["icon"],
                                    width: media.width * 0.4,
                                    height: media.width * 0.4,
                                    fit: BoxFit.fitHeight,
                                  ),
                                  const Spacer(),
                                  Text(
                                    sObj["name"],
                                    style: TextStyle(
                                        color: TColor.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            );
                          },
                        ))
                  ],
                ),
              ),
            ),
            // Separate Padding for RoundTextField
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
              child: RoundTextField(
                title: "Description",
                titleAlign: TextAlign.center,
                controller: txtDescription,
              ),
            ),
            // Separate Padding for RoundDropdown
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
              child: RoundDropdown(
                title: "Transaction Type",
                items: const ["Credit", "Debit"],
                selectedValue: selectedTransactionType,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTransactionType = newValue;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Minus Button
                  ImageButton(
                    image: "assets/img/minus.png",
                    onPressed: () {
                      amountVal -= 1;
                      if (amountVal < 0) {
                        amountVal = 0;
                      }
                      setState(() {});
                    },
                  ),

                  Expanded(
                    child: Column(
                      children: [
                        // "Monthly price" Text
                        Text(
                          "Monthly price",
                          style: TextStyle(
                            color: TColor.gray40,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Input field for manual rupee entry
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
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
                              controller: TextEditingController(
                                text: amountVal.toString(), // Remove decimals
                              ),
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
                                  // Update amountVal when the user manually enters a value
                                  amountVal = int.tryParse(value) ?? amountVal;
                                });
                              },
                            ),
                          ),

                          // const SizedBox(height: 8),
                          // // Horizontal line
                          // Container(
                          //   width: double.maxFinite,
                          //   height: 1,
                          //   color: TColor.gray70,
                          // ),
                        ),
                      ],
                    ),
                  ),

                  // Plus Button
                  ImageButton(
                    image: "assets/img/plus.png",
                    onPressed: () {
                      amountVal += 1;
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: PrimaryButton(
                title: "Add this transaction",
                onPressed: () {},
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
