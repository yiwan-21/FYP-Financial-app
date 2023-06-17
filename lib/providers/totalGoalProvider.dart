import 'package:financial_app/components/goal.dart';
import 'package:financial_app/firebaseInstance.dart';
import 'package:flutter/material.dart';

class TotalGoalProvider extends ChangeNotifier {
  Future<List<Goal>> _goals = Future.value([]);
  Future<List<Goal>> _pinned_goals = Future.value([]);

  TotalGoalProvider() {
    _goals = _getGoals();
    _pinned_goals = _getPinnedGoal();
  }

  Future<List<Goal>> get getGoals => _goals;
  Future<List<Goal>> get getPinnedGoal => _pinned_goals;

  Future<List<Goal>> _getGoals() async {
    final List<Goal> goalData = [];
    await FirebaseInstance.firestore.collection('goals')
      .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
      .orderBy('targetDate', descending: false)
      .get()
      .then((goals) => {
        for (var goal in goals.docs) {
          goalData.add(Goal(
            goal.id,
            goal['userID'],
            goal['title'],
            goal['amount'].toDouble(),
            goal['saved'].toDouble(),
            goal['targetDate'].toDate(),
            goal['pinned'],
          )),
        }
      });
    return goalData;
  }

  Future<List<Goal>> _getPinnedGoal() async {
    final List<Goal> goalData = [];
    await FirebaseInstance.firestore
        .collection('goals')
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .orderBy('pinned', descending: true)
        .orderBy('targetDate', descending: false)
        .limit(1)
        .get()
        .then((goals) => {
              for (var goal in goals.docs)
                {
                  goalData.add(Goal(
                    goal.id,
                    goal['userID'],
                    goal['title'],
                    goal['amount'].toDouble(),
                    goal['saved'].toDouble(),
                    goal['targetDate'].toDate(),
                    goal['pinned'],
                  )),
                }
            });
    return goalData;
  }

  void updateGoals() {
    _goals = _getGoals();
    _pinned_goals = _getPinnedGoal();
    notifyListeners();
  }
}