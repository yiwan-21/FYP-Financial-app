import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../components/goal.dart';
import '../services/goal_service.dart';

class TotalGoalProvider extends ChangeNotifier {
  Goal? _pinnedGoal;
  final List<Goal> _goals = [];
  StreamSubscription<QuerySnapshot>? _listener;

  TotalGoalProvider() {
    init();
  }

  Goal? get getPinnedGoal => _pinnedGoal;
  List<Goal> get getGoals => _goals;

  void init() {
    _listener = GoalService.getAllGoalStream().listen((event) {
      event.metadata.isFromCache
          ? print("Goal Stream: Data from local cache")
          : print("Goal Stream: Data from server");
      event.metadata.hasPendingWrites // pendingWrites ? "Local" : "Server";
          ? print("Goal Stream: There are pending writes")
          : print("Goal Stream: There are no pending writes");
      print("Goal Stream: Document changes: ${event.docChanges.length}");

      for (var change in event.docChanges) {
        if (change.type == DocumentChangeType.added) {
          _goals.insert(0, Goal.fromSnapshot(change.doc));
        } else if (change.type == DocumentChangeType.modified) {
          int index = _goals.indexWhere((element) => element.goalID == change.doc.id);
          _goals[index] = Goal.fromSnapshot(change.doc);
        } else if (change.type == DocumentChangeType.removed) {
          _goals.removeWhere((element) => element.goalID == change.doc.id);
        }
        if (change.doc['pinned']) {
          _pinnedGoal = Goal.fromSnapshot(change.doc);
        }
      }
      if (_pinnedGoal == null && _goals.isNotEmpty) {
        for (Goal goal in _goals) {
          if (goal.amount > goal.saved) {
            _pinnedGoal = goal;
            break;
          }
        }
      }
      notifyListeners();
    });
  }

  void reset() {
    _listener?.cancel();
    _pinnedGoal = null;
    _goals.clear();
    notifyListeners();
  }
}