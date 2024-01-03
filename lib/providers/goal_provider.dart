import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../components/goal.dart';
import '../components/monitor_goal_chart.dart';
import '../constants/constant.dart';
import '../services/goal_service.dart';
import '../utils/date_utils.dart';

class GoalProvider extends ChangeNotifier {
  // Goal details
  Goal? _goal;
  double _amount = 0;
  double _saved = 0;
  bool _pinned = false;

  // List of goals
  Goal? _pinnedGoal;
  final List<Goal> _goals = [];
  StreamSubscription<QuerySnapshot>? _listener;

  GoalProvider() {
    init();
  }

  double get goalRemaining => _amount - _saved;
  double get goalProgress => _saved / _amount * 100;
  bool get isPinned => _pinned;
  Goal get goal => _goal ?? Goal(
    id: '',
    title: '',
    amount: 0,
    saved: 0,
    targetDate: DateTime.now(),
    pinned: false,
    createdAt: DateTime.now(),
  );
  Goal? get pinnedGoal => _pinnedGoal;
  List<Goal> get goals => _goals;

  Future<void> setGoal(String id, String title, double amount, double saved, DateTime targetDate, bool pinned, DateTime createdAt) async {
    _amount = amount;
    _saved = saved;
    _pinned = pinned;
    _goal = Goal(
      id: id,
      title: title,
      amount: amount,
      saved: saved,
      targetDate: targetDate,
      pinned: pinned,
      createdAt: createdAt,
    );
    notifyListeners();
  }

  void setPinned(bool pinned) {
    _pinned = pinned;
    notifyListeners();
  }

  void init() {
    _listener = GoalService.getAllGoalStream().listen((event) {
      event.metadata.isFromCache
          ? debugPrint("Goal Stream: Data from local cache")
          : debugPrint("Goal Stream: Data from server");
      event.metadata.hasPendingWrites // pendingWrites ? "Local" : "Server";
          ? debugPrint("Goal Stream: There are pending writes")
          : debugPrint("Goal Stream: There are no pending writes");
      debugPrint("Goal Stream: Document changes: ${event.docChanges.length}");

      for (var change in event.docChanges) {
        if (change.type == DocumentChangeType.added) {
          _goals.add(Goal.fromSnapshot(change.doc));
        } else if (change.type == DocumentChangeType.modified) {
          int index = _goals.indexWhere((element) => element.id == change.doc.id);
          _goals[index] = Goal.fromSnapshot(change.doc);
        } else if (change.type == DocumentChangeType.removed) {
          _goals.removeWhere((element) => element.id == change.doc.id);
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
      _sortGoals();
      notifyListeners();
    });
  }

  void reset() {
    _goal = null;
    _listener?.cancel();
    _pinnedGoal = null;
    _goals.clear();
    notifyListeners();
  }

  List<MonitorGoalData> getMonitorGoalData({int monthCount = 5}) {
    List<MonitorGoalData> lineData = [];

    final month = DateTime.now().month;
    final monthRange = [];

    for (int i = (month + 12) - (monthCount - 1) - 1; i < month + 12; i++) {
      lineData.add(MonitorGoalData(Constant.monthLabels[(i % 12)], 0, 0, 0, 0));
      monthRange.add((i % 12) + 1);
    }

    for (Goal goal in _goals) {
      int monthIndex = monthRange.indexOf(goal.createdAt.month);
      if (monthIndex >= 0) {
        if (goal.saved >= goal.amount) {
          lineData[monthIndex].addComplete(1);
        } else if (goal.targetDate.isBefore(getOnlyDate(DateTime.now())) && goal.saved < goal.amount) {
          lineData[monthIndex].addExpired(1);
        } else if (!goal.targetDate.isBefore(getOnlyDate(DateTime.now())) && goal.saved == 0) {
          lineData[monthIndex].addToDo(1);
        } else {
          lineData[monthIndex].addInProgress(1);
        }
      }
    }
    
    return lineData;
  }

  void _sortGoals() {
    _goals.sort((a, b) {
      // return -1: [a, b]
      // return 1: [b, a]
      // return 0: equal
      bool aIsComplete = a.saved >= a.amount;
      bool bIsComplete = b.saved >= b.amount;
      if (a.pinned) {
        return -1;
      } else if (b.pinned) {
        return 1;
      } else if (aIsComplete == bIsComplete) {
        return a.targetDate.isBefore(b.targetDate) ? -1 : 1;
      } else {
        return aIsComplete ? 1 : -1;
      }
    });
  }
}