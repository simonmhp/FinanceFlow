import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moneytracker/view/login/welcome_view.dart';
import 'package:moneytracker/view/main_tab/main_tab_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  // Function to check if user is logged in
  void _checkUserStatus() async {
    // Simulate a delay for splash screen
    await Future.delayed(const Duration(seconds: 3));

    // Get current Firebase user
    User? user = FirebaseAuth.instance.currentUser;

    // Navigate to MainTabView if user is logged in, otherwise WelcomeView
    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainTabView()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/splash/logo-no-background2.png', // Replace with your background image path
            fit: BoxFit.fill,
          ),
          // Centered content
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image.asset('assets/logo.png', width: 150, height: 150),
                SizedBox(height: 20),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.orange), // Set the color to orange
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
