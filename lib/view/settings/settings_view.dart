import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this for Firebase authentication
import 'package:moneytracker/view/lets_get_Started/SplashPage.dart';
import '../../common/color_extension.dart';
import '../../common_widget/icon_item_row.dart';
import 'package:moneytracker/view/sqflite/db_helper.dart'; // Import the DatabaseHelper

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool isActive = false;
  DatabaseHelper _databaseHelper =
      DatabaseHelper(); // Initialize the database helper
  String username = "";
  String email = "";

  Future<void> _loadUserData() async {
    final userData =
        await _databaseHelper.getUser(); // Adjust this method as needed
    if (userData != null) {
      setState(() {
        username = userData[
            'username']; // Assuming 'username' is a field in your database
        email =
            userData['email']; // Assuming 'email' is a field in your database
      });
    }
  }

  Future<void> _logout() async {
    try {
      // Truncate the users table before logging out
      await _databaseHelper.truncateUsers();

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Navigate to the SplashScreen
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SplashScreen()));
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data on init
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: TColor.gray,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
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
                        "Settings",
                        style: TextStyle(color: TColor.gray30, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/img/u1.png",
                    width: 70,
                    height: 70,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    username.isNotEmpty
                        ? username
                        : "Loading...", // Display username
                    style: TextStyle(
                      color: TColor.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    email.isNotEmpty ? email : "Loading...", // Display email
                    style: TextStyle(
                      color: TColor.gray30,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: TColor.border.withOpacity(0.15),
                    ),
                    color: TColor.gray60.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "Edit profile",
                    style: TextStyle(
                      color: TColor.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15, bottom: 8),
                      child: Text(
                        "General",
                        style: TextStyle(
                          color: TColor.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: TColor.border.withOpacity(0.1),
                        ),
                        color: TColor.gray60.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const IconItemRow(
                            title: "Security",
                            icon: "assets/img/face_id.png",
                            value: "FaceID",
                          ),
                          IconItemSwitchRow(
                            title: "iCloud Sync",
                            icon: "assets/img/icloud.png",
                            value: isActive,
                            didChange: (newVal) {
                              setState(() {
                                isActive = newVal;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 8),
                      child: Text(
                        "My subscription",
                        style: TextStyle(
                          color: TColor.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: TColor.border.withOpacity(0.1),
                        ),
                        color: TColor.gray60.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          IconItemRow(
                            title: "Sorting",
                            icon: "assets/img/sorting.png",
                            value: "Date",
                          ),
                          IconItemRow(
                            title: "Summary",
                            icon: "assets/img/chart.png",
                            value: "Average",
                          ),
                          IconItemRow(
                            title: "Default currency",
                            icon: "assets/img/money.png",
                            value: "USD (\$)",
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 8),
                      child: Text(
                        "Appearance",
                        style: TextStyle(
                          color: TColor.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: TColor.border.withOpacity(0.1),
                        ),
                        color: TColor.gray60.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        children: [
                          IconItemRow(
                            title: "App icon",
                            icon: "assets/img/app_icon.png",
                            value: "Default",
                          ),
                          IconItemRow(
                            title: "Theme",
                            icon: "assets/img/light_theme.png",
                            value: "Dark",
                          ),
                          IconItemRow(
                            title: "Font",
                            icon: "assets/img/font.png",
                            value: "Inter",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20), // Add some spacing
                    Center(
                      child: ElevatedButton(
                        onPressed: _logout, // Call the logout function
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          backgroundColor:
                              Colors.red, // Change to any desired color
                        ),
                        child: Text(
                          "Logout",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
