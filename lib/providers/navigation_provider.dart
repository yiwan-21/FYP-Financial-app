import 'package:financial_app/pages/navigation.dart';
import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _navIndex = 2; // starting page
  int _pageIndex = 2; // starting page
  bool _isMoreTabActive = false;

  int get navIndex => _navIndex;
  int get pageIndex => _pageIndex;
  bool get isMoreTabActive => _isMoreTabActive;

  void setIndex(int navIndex, int pageIndex) {
    _navIndex = navIndex;
    _pageIndex = pageIndex;
    closeMoreTab();
    notifyListeners();
  }

  void toggleMoreTab() {
    _isMoreTabActive = !_isMoreTabActive;
    if (_isMoreTabActive) {
      Navigation.appBarKey.currentState!.animateTo(4);
    } else {
      Navigation.appBarKey.currentState!.animateTo(_navIndex);
    }
    notifyListeners();
  }

  void closeMoreTab() {
    _isMoreTabActive = false;
    notifyListeners();
  }

  void reset() {
    _navIndex = 2;
    _pageIndex = 2;
    closeMoreTab();
    notifyListeners();
  }

  void goToSplitMoney() {
    _navIndex = 0;
    _pageIndex = 0;
    Navigation.appBarKey.currentState!.animateTo(_navIndex);
    closeMoreTab();
    notifyListeners();
  }

  void goToGoal() {
    _navIndex = 1;
    _pageIndex = 1;
    Navigation.appBarKey.currentState!.animateTo(_navIndex);
    closeMoreTab();
    notifyListeners();
  }

  void goToHome() {
    _navIndex = 2;
    _pageIndex = 2;
    Navigation.appBarKey.currentState!.animateTo(_navIndex);
    closeMoreTab();
    notifyListeners();
  }

  void goToTracker() {
    _navIndex = 3;
    _pageIndex = 3;
    Navigation.appBarKey.currentState!.animateTo(_navIndex);
    closeMoreTab();
    notifyListeners();
  }

  void goToDebt() {
    _navIndex = 4;
    _pageIndex = 4;
    Navigation.appBarKey.currentState!.animateTo(_navIndex);
    closeMoreTab();
    notifyListeners();
  }

  void goToBill() {
    _navIndex = 4;
    _pageIndex = 5;
    Navigation.appBarKey.currentState!.animateTo(_navIndex);
    closeMoreTab();
    notifyListeners();
  }

  void goToBudgeting() {
    _navIndex = 4;
    _pageIndex = 6;
    Navigation.appBarKey.currentState!.animateTo(_navIndex);
    closeMoreTab();
    notifyListeners();
  }

  void goToAnalytics() {
    _navIndex = 4;
    _pageIndex = 7;
    Navigation.appBarKey.currentState!.animateTo(_navIndex);
    closeMoreTab();
    notifyListeners();
  }
}
