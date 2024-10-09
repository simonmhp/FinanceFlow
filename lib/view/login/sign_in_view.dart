import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:moneytracker/view/login/sign_up_view.dart';
import 'package:moneytracker/view/main_tab/main_tab_view.dart';
import 'package:moneytracker/view/sqflite/db_helper.dart';

import '../../common/color_extension.dart';
import '../../common_widget/primary_button.dart';
import '../../common_widget/round_textfield.dart';
import '../../common_widget/secondary_boutton.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  bool isRemember = false;
  bool isLoading = false;

  Future<void> signInUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Firebase sign-in logic
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: txtEmail.text.trim(),
        password: txtPassword.text.trim(),
      );

      // Retrieve user info
      String uid = userCredential.user!.uid;
      String email = userCredential.user!.email!;

      String username = await getUsernameFromFirebase(uid);

      // Prepare user data for SQLite insertion
      Map<String, dynamic> userData = {
        'email': email,
        'password': txtPassword.text.trim(),
        'username': username,
        'dataChange': DateTime.now().toString()
      };

      // Insert user data into SQLite
      await DatabaseHelper().insertUser(userData);

      Fluttertoast.showToast(
        msg: "Login successful!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      // 3-second pause before navigating to the next screen
      await Future.delayed(const Duration(seconds: 3));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainTabView()),
      );
    } catch (e) {
      print("Login failed: ${e.toString()}");
      Fluttertoast.showToast(
        msg: "Incorrect Email and Password",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String> getUsernameFromFirebase(String uid) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      return userDoc.data()?['username'] ?? '';
    }
    return '';
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
              Padding(
                padding: const EdgeInsets.only(top: 35.0),
                child: Image.asset("assets/img/logo-no-background.png",
                    width: media.width * 0.5, fit: BoxFit.contain),
              ),
              const Spacer(),
              RoundTextField(
                title: "Login",
                controller: txtEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(
                height: 15,
              ),
              RoundTextField(
                title: "Password",
                controller: txtPassword,
                obscureText: true,
              ),
              const SizedBox(
                height: 8,
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     TextButton(
              //       onPressed: () {
              //         setState(() {
              //           isRemember = !isRemember;
              //         });
              //       },
              //       child: Row(
              //         mainAxisSize: MainAxisSize.min,
              //         children: [
              //           Icon(
              //             isRemember
              //                 ? Icons.check_box_rounded
              //                 : Icons.check_box_outline_blank_rounded,
              //             size: 25,
              //             color: TColor.gray50,
              //           ),
              //           const SizedBox(
              //             width: 8,
              //           ),
              //           Text(
              //             "Remember me",
              //             style: TextStyle(color: TColor.gray50, fontSize: 14),
              //           ),
              //         ],
              //       ),
              //     ),
              //     TextButton(
              //       onPressed: () {},
              //       child: Text(
              //         "Forgot password",
              //         style: TextStyle(color: TColor.gray50, fontSize: 14),
              //       ),
              //     ),
              //   ],
              // ),
              const SizedBox(
                height: 15,
              ),
              isLoading
                  ? const CircularProgressIndicator()
                  : PrimaryButton(
                      title: "Sign In",
                      onPressed: signInUser,
                    ),
              const Spacer(),
              Text(
                "if you don't have an account yet?",
                textAlign: TextAlign.center,
                style: TextStyle(color: TColor.white, fontSize: 14),
              ),
              const SizedBox(
                height: 20,
              ),
              SecondaryButton(
                title: "Sign up",
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpView(),
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
