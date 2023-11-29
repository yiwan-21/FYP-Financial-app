import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './navigation_provider.dart';

class ShowcaseProvider with ChangeNotifier {
  bool _isFirstTime = true;
  bool _isRunning = false;
  
  final List<GlobalKey> _showcaseKeys = [
    GlobalKey(), // 0: home
    GlobalKey(), // 1: nav-tracker
    GlobalKey(), // 2: tracker
    GlobalKey(), // 3: tracker
    GlobalKey(), // 4: nav-savings goal
    GlobalKey(), // 5: savings goal
    GlobalKey(), // 6: nav-split money
    GlobalKey(), // 7: split money
    GlobalKey(), // 8: nav-more
    GlobalKey(), // 9: nav-budgeting
    GlobalKey(), // 10: budgeting
    GlobalKey(), // 11: nav-more
    GlobalKey(), // 12: nav-bill
    GlobalKey(), // 13: bill
    GlobalKey(), // 14: nav-more
    GlobalKey(), // 15: nav-debt
    GlobalKey(), // 16: debt
  ];

  final Map<int, Function> _showcaseCallbacks = {
    // 1: navigate to Tracker tour
    1: (BuildContext context) => Provider.of<NavigationProvider>(context, listen: false).goToTracker(),
    // 4: navigate to of Savings Goal tour
    4: (BuildContext context) => Provider.of<NavigationProvider>(context, listen: false).goToGoal(),
    // 6: navigate to of Split Money tour
    6: (BuildContext context) => Provider.of<NavigationProvider>(context, listen: false).goToSplitMoney(),
    // 8 & 9: navigate to of Budgeting tour
    8: (BuildContext context) => Provider.of<NavigationProvider>(context, listen: false).toggleMoreTab(),
    9: (BuildContext context) => Provider.of<NavigationProvider>(context, listen: false).goToBudgeting(),
    // 11 & 12: navigate to of Bill tour
    11: (BuildContext context) => Provider.of<NavigationProvider>(context, listen: false).toggleMoreTab(),
    12: (BuildContext context) => Provider.of<NavigationProvider>(context, listen: false).goToBill(),
    // 14 & 15: navigate to of Debt tour
    14: (BuildContext context) => Provider.of<NavigationProvider>(context, listen: false).toggleMoreTab(),
    15: (BuildContext context) => Provider.of<NavigationProvider>(context, listen: false).goToDebt(),
        
    // Add more callbacks as needed for each showcase widget
  };

  bool get isFirstTime => _isFirstTime;
  bool get isRunning => _isRunning;
  List<GlobalKey> get showcaseKeys => _showcaseKeys;
  Map<int, Function> get showcaseCallbacks => _showcaseCallbacks;

  void startTour() {
    _isRunning = true;
    notifyListeners();
  }

  void endTour(BuildContext context) {
    Provider.of<NavigationProvider>(context, listen: false).goToHome();
    _isFirstTime = false;
    _isRunning = false;
    notifyListeners();
  }
}
