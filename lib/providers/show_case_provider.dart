import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './navigation_provider.dart';

class ShowcaseProvider with ChangeNotifier {
  bool _isFirstTime = true;
  final List<GlobalKey> _showcaseKeys = [
    GlobalKey(), // 0: home
    GlobalKey(), // 1: tracker
    GlobalKey(), // 2: tracker
    GlobalKey(), // 3: savings goal
    GlobalKey(), // 4: split money
    GlobalKey(), // 5: budgeting
    GlobalKey(), // 6: bill
    GlobalKey(), // 7: debt
    // Add more keys as needed for each showcase widget
  ];

  final Map<int, Function> _showcaseCallbacks = {
    // 0: end of Home tour
    0: (BuildContext context) => Provider.of<NavigationProvider>(context, listen: false).goToTracker(),
    // 2: end of Tracker tour
    2: (BuildContext context) => Provider.of<NavigationProvider>(context, listen: false).goToGoal(),
    // 3: end of Savings Goal tour
    3: (BuildContext context) => Provider.of<NavigationProvider>(context, listen: false).goToSplitMoney(),
    // 4: end of Split Money tour
    4: (BuildContext context) => Provider.of<NavigationProvider>(context, listen: false).goToBudgeting(),
    // 5: end of Budgeting tour
    5: (BuildContext context) => Provider.of<NavigationProvider>(context, listen: false).goToBill(),
    // 6: end of Bill tour
    6: (BuildContext context) => Provider.of<NavigationProvider>(context, listen: false).goToDebt(),
        
    // Add more callbacks as needed for each showcase widget
  };

  bool get isFirstTime => _isFirstTime;
  List<GlobalKey> get showcaseKeys => _showcaseKeys;
  Map<int, Function> get showcaseCallbacks => _showcaseCallbacks;

  void endTour(BuildContext context) {
    Provider.of<NavigationProvider>(context, listen: false).goToHome();
    _isFirstTime = false;
    notifyListeners();
  }
}
