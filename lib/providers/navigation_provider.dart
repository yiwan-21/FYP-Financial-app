import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 2; // starting page

  int get getCurrentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void goToHome() {
    _currentIndex = 0;
    notifyListeners();
  }

  void goToTracker() {
    _currentIndex = 1;
    notifyListeners();
  }

  void goToAnalytics() {
    _currentIndex = 2;
    notifyListeners();
  }

  void goToSplitMoney() {
    _currentIndex = 3;
    notifyListeners();
  }

  void goToGoal() {
    _currentIndex = 4;
    notifyListeners();
  }
}