import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './firebase_instance.dart';
import 'pages/landing.dart';
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
import './pages/add_group_expense.dart';
import './pages/group_settings.dart';
import './pages/budget_detail.dart';
import './pages/manage_bill.dart';
import './pages/manage_debt.dart';
import './constants/route_name.dart';
import './constants/style_constant.dart';
import './providers/goal_provider.dart';
import './providers/navigation_provider.dart';
import './providers/total_goal_provider.dart';
import './providers/total_transaction_provider.dart';
import './providers/user_provider.dart';
import './providers/transaction_provider.dart';
import './providers/split_money_provider.dart';
import './providers/notification_provider.dart';
import './pages/home_settings.dart';
import 'providers/home_provider.dart';

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
        ChangeNotifierProvider(create: (_) => SplitMoneyProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
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
      title: 'Financial App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: lightRed,
      ),
      // home: const Navigation(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case RouteName.titlePage:
            if (isLoggedIn()) {
              return MaterialPageRoute(builder: (_) => const Navigation());
            } else {
              return MaterialPageRoute(builder: (_) => const Landing());
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
              return MaterialPageRoute(builder: (_) => const Landing());
            }
          case RouteName.homeSettings:
            if (isLoggedIn()) {
              return MaterialPageRoute(builder: (_) => const HomeSettings());
            } else {
              return MaterialPageRoute(builder: (_) => const Landing());
            }
          case RouteName.editProfile:
            if (isLoggedIn()) {
              return MaterialPageRoute(builder: (_) => const EditProfileForm());
            } else {
              return MaterialPageRoute(builder: (_) => const Landing());
            }
          case RouteName.addTransaction:
            if (isLoggedIn()) {
              return MaterialPageRoute(builder: (_) => const AddTransaction());
            } else {
              return MaterialPageRoute(builder: (_) => const Landing());
            }
          case RouteName.editTransaction:
            if (isLoggedIn()) {
              return MaterialPageRoute(builder: (_) => const EditTransaction());
            } else {
              return MaterialPageRoute(builder: (_) => const Landing());
            }
          case RouteName.addGoal:
            if (isLoggedIn()) {
              return MaterialPageRoute(builder: (_) => const AddGoal());
            } else {
              return MaterialPageRoute(builder: (_) => const Landing());
            }
          case RouteName.goalProgress:
            if (isLoggedIn()) {
              return MaterialPageRoute(builder: (_) => const GoalProgress());
            } else {
              return MaterialPageRoute(builder: (_) => const Landing());
            }
          case RouteName.splitMoneyGroup:
            if (isLoggedIn()) {
              return MaterialPageRoute(builder: (_) => const SplitMoneyGroup());
            } else {
              return MaterialPageRoute(builder: (_) => const Landing());
            }
          case RouteName.groupSettings:
            if (isLoggedIn()) {
              return MaterialPageRoute(builder: (_) => const GroupSettings());
            } else {
              return MaterialPageRoute(builder: (_) => const Landing());
            }
          case RouteName.splitMoneyExpense:
            if (isLoggedIn()) {
              // get argument from route
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                  builder: (_) => SplitMoneyExpense(
                      expenseID: args['id'], tabIndex: args['tabIndex']));
            } else {
              return MaterialPageRoute(builder: (_) => const Landing());
            }
          case RouteName.addGroupExpense:
            if (isLoggedIn()) {
              return MaterialPageRoute(builder: (_) => const AddGroupExpense());
            } else {
              return MaterialPageRoute(builder: (_) => const Landing());
            }
          case RouteName.budgetDetail:
            if (isLoggedIn()) {
              // get argument from route
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => BudgetDetail(category: args['category']),
              );
            } else {
              return MaterialPageRoute(builder: (_) => const Landing());
            }
          case RouteName.manageBill:
            if (isLoggedIn()) {
              // get argument from route
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => ManageBill(
                  args['isEditing'], 
                  args['id'], 
                  args['title'], 
                  args['amount'], 
                  args['date'],
                  args['fixed'],
                ),
              );
            } else {
              return MaterialPageRoute(builder: (_) => const Landing());
            }
          case RouteName.manageDebt:
            if (isLoggedIn()) {
              // get argument from route
              final args = settings.arguments as Map<String, dynamic>;
              return MaterialPageRoute(
                builder: (_) => ManageDebt(
                  args['isEditing'], 
                  args['id'], 
                  args['title'], 
                  args['amount'], 
                  args['interest'],
                  args['year'],
                  args['month'],
                ),
              );
            } else {
              return MaterialPageRoute(builder: (_) => const Landing());
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
