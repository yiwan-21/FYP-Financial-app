import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../components/goal.dart';
import '../services/goal_service.dart';

class TotalGoalProvider extends ChangeNotifier {
  late Stream<QuerySnapshot> _goalsStream;
  List<Goal> _pinnedGoals = [];

  TotalGoalProvider() {
    updatePinnedGoal();
    _goalsStream = GoalService.getAllGoalStream();
  }

  Stream<QuerySnapshot> get getGoalsStream => _goalsStream;
  List<Goal> get getPinnedGoal => _pinnedGoals;

  Future<void> init() async {
    _goalsStream = GoalService.getAllGoalStream();
    _pinnedGoals = await GoalService.getPinnedGoal();
    notifyListeners();
  }

  Future<void> updatePinnedGoal() async {
    _pinnedGoals = await GoalService.getPinnedGoal();
    notifyListeners();
  }

  void reset() {
    _goalsStream.listen((snapshot) {}).cancel();
    _goalsStream = const Stream.empty();
    _pinnedGoals = [];
    notifyListeners();
  }
}