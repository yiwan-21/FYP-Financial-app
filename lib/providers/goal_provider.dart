import 'package:flutter/material.dart';

class GoalProvider extends ChangeNotifier {
  String id = '';
  String title = '';
  double amount = 0;
  double saved = 0;
  DateTime targetDate = DateTime.now();
  bool pinned = false;

  GoalProvider();

  String get getId => id;
  String get getTitle => title;
  double get getAmount => amount;
  double get getSaved => saved;
  double get getRemaining => amount - saved;
  double get getProgress => saved / amount * 100;
  DateTime get getTargetDate => targetDate;
  bool get getPinned => pinned;

  Future<void> setGoal(String id, String title, double amount, double saved, DateTime targetDate, bool pinned) async {
    this.id = id;
    this.title = title;
    this.amount = amount;
    this.saved = saved;
    this.targetDate = targetDate;
    this.pinned = pinned;
    notifyListeners();
  }

  Future<void> setSaved(double saved) async {
    this.saved = saved;
    notifyListeners();
  }

  Future<void> setPinned(bool pinned) async {
    this.pinned = pinned;
    notifyListeners();
  }
}