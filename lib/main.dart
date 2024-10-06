import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core for initialization
import 'package:moneytracker/common/color_extension.dart';
import 'package:moneytracker/view/lets_get_Started/SplashPage.dart'; // Ensure correct file path // Ensure correct file path
import 'package:moneytracker/view/sqflite/db_helper.dart';
import 'firebase_options.dart'; // This is autogenerated by the Firebase CLI

void main() async {
  // Ensure that Flutter engine is properly initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase before the app runs
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ensure SQLite is also initialized if you're using it
  await DatabaseHelper().database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trackizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Inter",
        colorScheme: ColorScheme.fromSeed(
          seedColor: TColor.primary,
          background: TColor.gray80,
          primary: TColor.primary,
          primaryContainer: TColor.gray60,
          secondary: TColor.secondary,
        ),
        useMaterial3: false,
      ),
      home: const SplashScreen(), // Splash screen will load first
    );
  }
}
