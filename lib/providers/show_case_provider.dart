import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './navigation_provider.dart';

class ShowcaseProvider with ChangeNotifier {
  bool _isFirstTime = true;
  bool _isRunning = false;
  final String _firstTimeKey = "firstTimeShowcase";

  final GlobalKey _navTrackerKey = GlobalKey();
  final GlobalKey _navGoalKey = GlobalKey();
  final GlobalKey _navGroupKey = GlobalKey();
  final GlobalKey _navMoreKey = GlobalKey();
  final GlobalKey _navBudgetingKey = GlobalKey();
  final GlobalKey _navBillKey = GlobalKey();
  final GlobalKey _navDebtKey = GlobalKey();
  final GlobalKey _endTourKey = GlobalKey();

  bool get isFirstTime => _isFirstTime;
  bool get isRunning => _isRunning;
  String get firstTimeKey => _firstTimeKey;

  GlobalKey get navTrackerKey => _navTrackerKey;
  GlobalKey get navGoalKey => _navGoalKey;
  GlobalKey get navGroupKey => _navGroupKey;
  GlobalKey get navMoreKey => _navMoreKey;
  GlobalKey get navBudgetingKey => _navBudgetingKey;
  GlobalKey get navBillKey => _navBillKey;
  GlobalKey get navDebtKey => _navDebtKey;
  GlobalKey get endTourKey => _endTourKey;

  void setFirstTime(bool isFirstTime) {
    _isFirstTime = isFirstTime;
    notifyListeners();
  }

  void startTour() {
    _isRunning = true;
    notifyListeners();
  }

  void endTour() {
    _isRunning = false;
    notifyListeners();
  }

  void endAllTour(BuildContext context) {
    Provider.of<NavigationProvider>(context, listen: false).goToHome();
    _isFirstTime = false;
    _isRunning = false;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(_firstTimeKey, false);
    });
    notifyListeners();
  }
}
