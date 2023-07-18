import 'package:flutter/material.dart';
import '../components/goal.dart';
import '../services/goal_service.dart';

class TotalGoalProvider extends ChangeNotifier {
  final GoalService _goalService = GoalService();
  Future<List<Goal>> _goals = Future.value([]);
  Future<List<Goal>> _pinnedGoals = Future.value([]);

  TotalGoalProvider() {
    _goals = _goalService.getAllGoals();
    _pinnedGoals = _goalService.getPinnedGoal();
  }

  Future<List<Goal>> get getGoals => _goals;
  Future<List<Goal>> get getPinnedGoal => _pinnedGoals;

  Future<void> updateGoals() async {
    _goals = _goalService.getAllGoals();
    _pinnedGoals = _goalService.getPinnedGoal();
    notifyListeners();
  }

  void reset() {
    _goals = Future.value([]);
    _pinnedGoals = Future.value([]);
    notifyListeners();
  }
}