import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/userProvider.dart';
import 'pages/financialApp.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/navigation.dart';
import 'pages/addTransaction.dart';
import 'pages/editTransaction.dart';
import 'pages/editProfile.dart';
import 'pages/addGoal.dart';
import 'pages/goalProgress.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAYKKuHLL4Hm2V4I3fiFQdcFQC-oTY82Zw",
        projectId: "fyp-financial-app",
        storageBucket: "fyp-financial-app.appspot.com",
        messagingSenderId: "368968416992",
        appId: "1:368968416992:web:efbd4f20534b8718671a85",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
        '/home': (context) => const Navigation(),
        '/profile': (context) => const EditProfileForm(),
        '/tracker/add': (context) => const AddTransaction(),
        '/tracker/edit': (context) => const EditTransaction(),
        '/goal/add': (context) => const AddGoal(),
        '/goal/progress': (context) => const GoalProgress(),
      },
    );
  }
}
