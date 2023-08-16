import 'package:flutter/material.dart';
import '../components/goal.dart';
import '../services/goal_service.dart';

class TotalGoalProvider extends ChangeNotifier {
  List<Goal> _goals = [];
  List<Goal> _pinnedGoals = [];

  TotalGoalProvider() {
    updateGoals();
  }

  List<Goal> get getGoals => _goals;
  List<Goal> get getPinnedGoal => _pinnedGoals;

  Future<void> updateGoals() async {
    _goals = await GoalService.getAllGoals();
    _pinnedGoals = await GoalService.getPinnedGoal();
    notifyListeners();
  }

  void reset() {
    _goals = [];
    _pinnedGoals = [];
    notifyListeners();
  }
}