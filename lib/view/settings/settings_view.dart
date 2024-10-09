import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Add this for Firebase authentication
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moneytracker/common_widget/editing_username.dart';
import 'package:moneytracker/common_widget/icon_item_button.dart';
import 'package:moneytracker/view/lets_get_Started/splash_page.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  String username = "";
  String email = "";
  int unsyncCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    someFunction();
  }

  Future<void> getUser() async {
    showToast("Cloud Feature Coming Soon.");
    // final user = FirebaseAuth.instance.currentUser;
    // if (user != null && isActive) {
    //   await syncToFirebase(user.uid);
    // } else if (!isActive) {
    //   showToast("Firebase Sync Session Over");
    // } else {
    //   showToast("Error occurred. Restart app from memory.");
    // }
  }

  Future<void> _loadUserData() async {
    final userData = await _databaseHelper.getUser();
    if (userData != null) {
      setState(() {
        username = userData['username'];
        email = userData['email'];
      });
    }
  }

  Future<void> _logout() async {
    try {
      // Truncate the users table before logging out
      await _databaseHelper.truncateUsers();
      await _databaseHelper.truncateTransactions();
      await _databaseHelper.truncateBudgets();

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Navigate to the SplashScreen
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => SplashScreen()));
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  void someFunction() async {
    final unsyncedCount = await DatabaseHelper().countUnsyncedTransactions();
    unsyncCount = unsyncedCount;
  }

  Future<void> openWebView(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView)) {
      throw Exception("Couldn't launch Url");
    }
  }

  Future<void> openBrowserView(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView)) {
      throw Exception("Couldn't launch Url");
    }
  }

  // Future<void> syncToFirebase(String uid) async {
  //   if (!isActive) {
  //     showToast("Firebase Sync is not active.");
  //     return;
  //   }

  //   // Get unsynced transactions
  //   final unsyncedTransactions =
  //       await _databaseHelper.getUnsyncedTransactions();

  //   if (unsyncedTransactions.isEmpty) {
  //     showToast("No unsynced transactions found.");
  //     return;
  //   }

  //   final database = FirebaseDatabase.instance.ref();

  //   try {
  //     // Upload each transaction to Firebase under the user ID
  //     for (var transaction in unsyncedTransactions) {
  //       await database
  //           .child('users')
  //           .child(uid) // Use the UID here
  //           .child('transactions')
  //           .push()
  //           .set(transaction.toMap());

  //       // Optionally update the local database to mark it as synced
  //       await _databaseHelper.updateTransactionSyncStatus(transaction.id, true);
  //     }

  //     // After successful upload, set isActive to false
  //     setState(() {
  //       isActive = false;
  //     });

  //     showToast("Sync successful!");
  //   } catch (e) {
  //     showToast("Sync failed: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.gray,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 35.0, bottom: 15.0),
                          child: Text(
                            "Settings",
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
                      username.isNotEmpty ? username : "Loading...",
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
                      email.isNotEmpty ? email : "Loading...",
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
                  onTap: () async {
                    bool? isUpdated = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return EditUsernameDialog(
                          currentUsername: username,
                          currentEmail: email,
                        );
                      },
                    );

                    if (isUpdated == true) {
                      setState(() {
                        _loadUserData();
                      });
                    }
                  },
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
                              title: "Created By",
                              icon: "assets/img/coding.png",
                              value: "Simon Mohapatra",
                            ),
                            const IconItemRow(
                              title: "Designed with",
                              icon: "assets/img/code.png",
                              value: "Flutter",
                            ),
                            InkWell(
                              onTap: () {
                                openBrowserView("https://github.com/simonmhp");
                              },
                              child: const IconItemSocialRow(
                                title: "Check Out my",
                                icon: "assets/img/social.png",
                                value: "Github",
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                openWebView("https://simonmhp.github.io/");
                              },
                              child: const IconItemSocialRow(
                                title: "Check Out my",
                                icon: "assets/img/browser.png",
                                value: "Website",
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 8),
                        child: Text(
                          "Cloud Storage",
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
                            IconItemRow(
                              title: "unSync Data",
                              icon: "assets/img/folder.png",
                              value: unsyncCount.toString(),
                            ),
                            IconItemSButton(
                              title: "unSync Data",
                              icon: "assets/img/folder.png",
                              value: "Sync",
                              didChange: (newVal) async {
                                setState(() {
                                  someFunction();
                                  isActive = true;
                                });

                                await getUser();
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 8),
                        child: Text(
                          "About",
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
                              title: "App version",
                              icon: "assets/img/app-development.png",
                              value: "1.0.0",
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
                            IconItemRow(
                              title: "App icon",
                              icon: "assets/img/app_icon.png",
                              value: "Default",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            backgroundColor: Colors.red,
                          ),
                          child: const Text(
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
      ),
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
