import 'package:flutter/material.dart';
import 'pages/financialApp.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/home.dart';
import 'pages/addTransaction.dart';
import 'pages/editTransaction.dart';
import 'pages/editProfile.dart';
import 'pages/addGoal.dart';
import 'pages/goalProgress.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter layout demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      routes: {
        '/': (context) => const FinancialApp(),
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
        '/home': (context) => const Home(),
        '/profile': (context) => const EditProfileForm(),
        '/tracker/add': (context) => const AddTransaction(),
        '/tracker/edit': (context) => const EditTransaction(),
        '/goal/add': (context) => const AddGoal(),
        '/goal/progress': (context) => const GoalProgress(),
      },
    );
  }
}
