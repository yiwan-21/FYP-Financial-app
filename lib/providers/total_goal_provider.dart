import 'package:flutter/material.dart';
import '../components/goal.dart';
import '../services/goal_service.dart';

class TotalGoalProvider extends ChangeNotifier {
  Future<List<Goal>> _goals = Future.value([]);
  Future<List<Goal>> _pinnedGoals = Future.value([]);

  TotalGoalProvider() {
    _goals = GoalService.getAllGoals();
    _pinnedGoals = GoalService.getPinnedGoal();
  }

  Future<List<Goal>> get getGoals => _goals;
  Future<List<Goal>> get getPinnedGoal => _pinnedGoals;

  Future<void> updateGoals() async {
    _goals = GoalService.getAllGoals();
    _pinnedGoals = GoalService.getPinnedGoal();
    notifyListeners();
  }

  void reset() {
    _goals = Future.value([]);
    _pinnedGoals = Future.value([]);
    notifyListeners();
  }
}