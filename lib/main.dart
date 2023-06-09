import 'package:financial_app/firebaseInstance.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/userProvider.dart';
import './providers/transactionProvider.dart';
import './pages/financialApp.dart';
import './pages/login.dart';
import './pages/register.dart';
import './pages/navigation.dart';
import './pages/addTransaction.dart';
import './pages/editTransaction.dart';
import './pages/editProfile.dart';
import './pages/addGoal.dart';
import './pages/goalProgress.dart';

final navigatorKey = GlobalKey<NavigatorState>();

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
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  bool isLoggedIn() {
    return FirebaseInstance.auth.currentUser != null;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter layout demo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      // home: const Navigation(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case RouteName.titlePage:
            if (isLoggedIn()) {
              return MaterialPageRoute(builder: (_) => const Navigation());
            } else {
              return MaterialPageRoute(builder: (_) => const FinancialApp());
            }
          case RouteName.login:
            if (isLoggedIn()) {
              return MaterialPageRoute(builder: (_) => const Navigation());
            } else {
              return MaterialPageRoute(builder: (_) => const Login());
            }
          case RouteName.register:
            if (isLoggedIn()) {
              return MaterialPageRoute(builder: (_) => const Navigation());
            } else {
              return MaterialPageRoute(builder: (_) => const Register());
            }
          case RouteName.home:
            if (isLoggedIn()) {
              return MaterialPageRoute(builder: (_) => const Navigation());
            } else {
              return MaterialPageRoute(builder: (_) => const FinancialApp());
            }
          case RouteName.editProfile:
            if (isLoggedIn()) {
              return MaterialPageRoute(builder: (_) => const EditProfileForm());
            } else {
              return MaterialPageRoute(builder: (_) => const FinancialApp());
            }
          case RouteName.addTransaction:
            if (isLoggedIn()) {
              return MaterialPageRoute(builder: (_) => const AddTransaction());
            } else {
              return MaterialPageRoute(builder: (_) => const FinancialApp());
            }
          case RouteName.editTransaction:
            if (isLoggedIn()) {
              return MaterialPageRoute(builder: (_) => const EditTransaction());
            } else {
              return MaterialPageRoute(builder: (_) => const FinancialApp());
            }
          case RouteName.addGoal:
            if (isLoggedIn()) {
              return MaterialPageRoute(builder: (_) => const AddGoal());
            } else {
              return MaterialPageRoute(builder: (_) => const FinancialApp());
            }
          case RouteName.goalProgress:
            if (isLoggedIn()) {
              return MaterialPageRoute(builder: (_) => const GoalProgress());
            } else {
              return MaterialPageRoute(builder: (_) => const FinancialApp());
            }
          default:
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
            );
        }
      },
    );
  }
}

class RouteName {
  static const titlePage = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const editProfile = '/profile';
  static const addTransaction = '/tracker/add';
  static const editTransaction = '/tracker/edit';
  static const addGoal = '/goal/add';
  static const goalProgress = '/goal/progress';
}
