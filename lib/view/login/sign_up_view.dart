import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:moneytracker/common_widget/password_textfield.dart';
import 'package:moneytracker/common_widget/secondary_boutton.dart';
import 'package:moneytracker/view/login/sign_in_view.dart';
import 'package:moneytracker/view/main_tab/main_tab_view.dart';
import '../../common/color_extension.dart';
import '../../common_widget/primary_button.dart';
import '../../common_widget/round_textfield.dart';
import 'package:moneytracker/view/sqflite/db_helper.dart'; // Import the SQLite helper

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  final TextEditingController txtUsername =
      TextEditingController(); // Username Controller
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // SQLite Helper

  int passwordStrength = 0;
  bool isLoading = false; // Loading state

  Future<void> _signUp() async {
    setState(() {
      isLoading = true; // Set loading to true
    });

    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: txtEmail.text.trim(),
        password: txtPassword.text.trim(),
      );

      // Store the username in Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'username': txtUsername.text.trim(),
        'email': txtEmail.text.trim(),
        'dataChange': "No",
      });

      Fluttertoast.showToast(
        msg: "Sign up successful!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Log out the user
      await _auth.signOut();

      // Navigate to the SignInView and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignInView()),
        (Route<dynamic> route) => false, // Remove all previous routes
      );
    } catch (e) {
      print("Error signing up: ${e.toString()}");
      Fluttertoast.showToast(
        msg: "Error signing up: ${e.toString()}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      setState(() {
        isLoading = false; // Set loading to false after the process
      });
    }
  }

  void _updatePasswordStrength(String password) {
    setState(() {
      passwordStrength = _calculatePasswordStrength(password);
    });
  }

  int _calculatePasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    return strength;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: TColor.gray,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/img/app_logo.png",
                  width: media.width * 0.5, fit: BoxFit.contain),
              const Spacer(),
              RoundTextField(
                title: "Username", // Username input field
                controller: txtUsername,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 15),
              RoundTextField(
                title: "E-mail address",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              RoundPTextField(
                title: "Password",
                controller: txtPassword,
                obscureText: true,
                onChanged: (password) => _updatePasswordStrength(password),
              ),
              const SizedBox(height: 20),
              // Password strength indicator
              Row(
                children: List.generate(
                  4,
                  (index) => Expanded(
                    child: Container(
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: index < passwordStrength
                            ? Colors.green // Strength indicator color
                            : TColor.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Password must be at least 8 characters long and \ninclude uppercase letters, numbers, and \nspecial symbols.",
                    style: TextStyle(color: TColor.gray50, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Show loading indicator or button based on loading state
              isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator()) // Show loading spinner
                  : PrimaryButton(
                      title: "Get started, it's free!",
                      onPressed: _signUp,
                    ),
              const Spacer(),
              Text(
                "Do you have already an account?",
                textAlign: TextAlign.center,
                style: TextStyle(color: TColor.white, fontSize: 14),
              ),
              const SizedBox(height: 20),
              SecondaryButton(
                title: "Sign in",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInView(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
