import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './firebase_instance.dart';
import './pages/financial_app.dart';
import './pages/login.dart';
import './pages/register.dart';
import './pages/navigation.dart';
import './pages/add_transaction.dart';
import './pages/edit_transaction.dart';
import './pages/edit_profile.dart';
import './pages/add_goal.dart';
import './pages/goal_progress.dart';
import './pages/split_money_group.dart';
import './pages/split_money_expense.dart';
import './providers/goal_provider.dart';
import './providers/navigation_provider.dart';
import './providers/total_goal_provider.dart';
import './providers/total_transaction_provider.dart';
import './providers/user_provider.dart';
import './providers/transaction_provider.dart';
import './providers/total_split_money_provider.dart';

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
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => TotalTransactionProvider()),
        ChangeNotifierProvider(create: (_) => TotalGoalProvider()),
        ChangeNotifierProvider(create: (_) => TotalSplitMoneyProvider()),
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
      debugShowCheckedModeBanner: false,
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
          case RouteName.splitMoneyGroup:
            if (isLoggedIn()) {
              // get argument from route
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                  builder: (_) => SplitMoneyGroup(groupID: args['id']));
            } else {
              return MaterialPageRoute(builder: (_) => const FinancialApp());
            }
          case RouteName.splitMoneyExpense:
            if (isLoggedIn()) {
              // get argument from route
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                  builder: (_) => SplitMoneyExpense(expenseID: args['id']));
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
  static const splitMoneyGroup = '/group';
  static const splitMoneyExpense = '/group/expense';
}
