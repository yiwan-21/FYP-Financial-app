import '../firebase_instance.dart';
import '../components/goal.dart';
import '../components/goal_history_card.dart';

class GoalService {
  static Future<List<Goal>> getAllGoals() async {
    final List<Goal> goalData = [];
    await FirebaseInstance.firestore
        .collection('goals')
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .orderBy('pinned', descending: true)
        .orderBy('targetDate', descending: false)
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

  static Future<List<Goal>> getPinnedGoal() async {
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

  static Future<List<HistoryCard>> getHistory(goalId) async {
    final List<HistoryCard> history = [];
    await FirebaseInstance.firestore
        .collection('goals')
        .doc(goalId)
        .collection('history')
        .orderBy('date', descending: true)
        .get()
        .then((value) => {
              for (var historyData in value.docs)
                {
                  history.add(
                    HistoryCard(
                      historyData['amount'].toDouble(),
                      historyData['date'].toDate(),
                    ),
                  ),
                }
            });
    return history;
  }

  static Future<dynamic> addGoal(newGoal) async {
    return await FirebaseInstance.firestore
        .collection('goals')
        .add(newGoal.toCollection());
  }

  static Future<dynamic> addHistory(goalId, amount) async {
    return await FirebaseInstance.firestore
        .collection('goals')
        .doc(goalId)
        .collection('history')
        .add({
      'amount': amount,
      'date': DateTime.now(),
    });
  }

  static Future<void> updateGoalSavedAmount(goalId, amount) async {
    return await FirebaseInstance.firestore
        .collection('goals')
        .doc(goalId)
        .update({'saved': amount});
  }

  static Future<void> deleteGoal(goalId) async {
    return await FirebaseInstance.firestore
        .collection("goals")
        .doc(goalId)
        .delete();
  }

  static Future<void> setPinned(targetID, pinned) async {
    await FirebaseInstance.firestore
        .collection('goals')
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .get()
        .then((goals) {
      for (var goal in goals.docs) {
        if (goal.id == targetID) {
          FirebaseInstance.firestore
              .collection('goals')
              .doc(goal.id)
              .update({'pinned': pinned});
        } else {
          FirebaseInstance.firestore
              .collection('goals')
              .doc(goal.id)
              .update({'pinned': false});
        }
      }
    });
  }
}
