import 'package:financial_app/pages/navigation.dart';
import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 2; // starting page

  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void reset() {
    _currentIndex = 2;
    notifyListeners();
  }

  void goToTracker() {
    _currentIndex = 0;
    Navigation.appBarKey.currentState!.animateTo(0);
    notifyListeners();
  }

  void goToAnalytics() {
    _currentIndex = 1;
    Navigation.appBarKey.currentState!.animateTo(1);
    notifyListeners();
  }

  void goToHome() {
    _currentIndex = 2;
    Navigation.appBarKey.currentState!.animateTo(2);
    notifyListeners();
  }

  void goToSplitMoney() {
    _currentIndex = 3;
    Navigation.appBarKey.currentState!.animateTo(3);
    notifyListeners();
  }

  void goToGoal() {
    _currentIndex = 4;
    Navigation.appBarKey.currentState!.animateTo(4);
    notifyListeners();
  }
}