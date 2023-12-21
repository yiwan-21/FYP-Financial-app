import 'dart:ui';

import 'package:financial_app/providers/show_case_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import './firebase_instance.dart';
import './pages/landing.dart';
import './pages/login.dart';
import './pages/register.dart';
import './pages/navigation.dart';
import './pages/home_settings.dart';
import './pages/manage_transaction.dart';
import './pages/edit_profile.dart';
import './pages/add_goal.dart';
import './pages/goal_detail.dart';
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
import './providers/user_provider.dart';
import './providers/transaction_provider.dart';
import './providers/split_money_provider.dart';
import './providers/notification_provider.dart';
import './providers/home_provider.dart';

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
        ChangeNotifierProvider(create: (_) => SplitMoneyProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ShowcaseProvider()),
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
    return ShowCaseWidget(
      onComplete: (index, key) {
        ShowcaseProvider showcaseProvider = Provider.of<ShowcaseProvider>(context, listen: false);
        NavigationProvider navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
        if (key == showcaseProvider.navTrackerKey) {
          navigationProvider.goToTracker();
        } else if (key == showcaseProvider.navGoalKey) {
          navigationProvider.goToGoal();
        } else if (key == showcaseProvider.navGroupKey) {
          navigationProvider.goToSplitMoney();
        } else if (key == showcaseProvider.navMoreKey) {
          navigationProvider.toggleMoreTab();
        } else if (key == showcaseProvider.navBudgetingKey) {
          navigationProvider.goToBudgeting();
        } else if (key == showcaseProvider.navBillKey) {
          navigationProvider.goToBill();
        } else if (key == showcaseProvider.navDebtKey) {
          navigationProvider.goToDebt();
        } else if (key == showcaseProvider.endTourKey) {
          showcaseProvider.endAllTour(context);
        }
      },
      onStart: (index, key) {
        Provider.of<ShowcaseProvider>(context, listen: false).startTour();
      },
      onFinish: () {
        Provider.of<ShowcaseProvider>(context, listen: false).endTour();
      },
      builder: Builder(
        builder: (context) {
          return MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Financial App',
            debugShowCheckedModeBanner: false,
            scrollBehavior: MyCustomScrollBehavior(),
            theme: ThemeData(
              primarySwatch: lightRed,
            ),
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
                case RouteName.manageTransaction:
                  if (isLoggedIn()) {
                    // get argument from route
                    final args = settings.arguments as Map<String, dynamic>;
                    return MaterialPageRoute(
                      builder: (_) => ManageTransaction(
                        args['isEditing'],
                      ),
                    );
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
                    return MaterialPageRoute(builder: (_) => const GoalDetail());
                  } else {
                    return MaterialPageRoute(builder: (_) => const Landing());
                  }
                case RouteName.splitMoneyGroup:
                  if (isLoggedIn()) {
                    // get argument from route
                    final args = settings.arguments as Map<String, dynamic>;
                    return MaterialPageRoute(
                        builder: (_) => SplitMoneyGroup(groupID: args['id']));
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
                        id: args['id'],
                        title: args['title'],
                        amount: args['amount'],
                        date: args['date'],
                        fixed: args['fixed'],
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
                        id: args['id'],
                        title: args['title'],
                        amount: args['amount'],
                        interest: args['interest'],
                        year: args['year'],
                        month: args['month'],
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
        },
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
