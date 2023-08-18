import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_instance.dart';
import '../components/goal.dart';
import '../components/goal_history_card.dart';

class GoalService {
  static CollectionReference goalsCollection =
      FirebaseInstance.firestore.collection('goals');

  static Stream<QuerySnapshot> getAllGoalStream() {
    if (FirebaseInstance.auth.currentUser != null) {
      return goalsCollection
          .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
          .orderBy('pinned', descending: true)
          .orderBy('targetDate', descending: false)
          .snapshots();
    } else {
      return const Stream.empty();
    }
  }

  static Future<List<Goal>> getPinnedGoal() async {
    final List<Goal> goalData = [];
    await goalsCollection
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .orderBy('pinned', descending: true)
        .orderBy('targetDate', descending: false)
        .limit(1)
        .get()
        .then((goals) => {
              for (var doc in goals.docs)
                {
                  goalData.add(Goal.fromDocument(doc)),
                }
            });
    return goalData;
  }

  static Future<List<HistoryCard>> getHistory(goalId) async {
    final List<HistoryCard> history = [];
    await goalsCollection
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
    return goalsCollection.add(newGoal.toCollection());
  }

  static Future<dynamic> addHistory(goalId, amount) async {
    return await goalsCollection.doc(goalId).collection('history').add({
      'amount': amount,
      'date': DateTime.now(),
    });
  }

  static Future<void> updateGoalSavedAmount(goalId, amount) async {
    return await goalsCollection.doc(goalId).update({'saved': amount});
  }

  static Future<void> deleteGoal(goalId) async {
    return await goalsCollection.doc(goalId).delete();
  }

  static Future<void> setPinned(targetID, pinned) async {
    await goalsCollection
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .get()
        .then((goals) {
      for (var goal in goals.docs) {
        if (goal.id == targetID) {
          goalsCollection.doc(goal.id).update({'pinned': pinned});
        } else {
          goalsCollection.doc(goal.id).update({'pinned': false});
        }
      }
    });
  }

  static Future<void> updateSinglePinned(targetID, pinned) async {
    await goalsCollection.doc(targetID).update({'pinned': false});
  }
}
