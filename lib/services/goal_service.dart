import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/components/history_card.dart';

import '../constants/notification_type.dart';
import '../firebase_instance.dart';
import '../components/goal.dart';
import '../utils/date_utils.dart';
import '../services/notification_service.dart';

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

  static Stream<QuerySnapshot> getHistoryStream(goalID) {
    return goalsCollection
        .doc(goalID)
        .collection('history')
        .orderBy('date', descending: true)
        .snapshots();
  }

  static Future<List<HistoryCard>> getHistoryCards(String id) async {
    List<HistoryCard> historyCards = [];
    await goalsCollection
        .doc(id)
        .collection('history')
        .get()
        .then((snapshot) {
          for (var doc in snapshot.docs) {
            historyCards.add(HistoryCard.fromDocument(doc));
          }
        });

    return historyCards;
  }

  static Future<dynamic> addGoal(Goal newGoal) async {
    return goalsCollection.add(newGoal.toFirestoreDocument());
  }

  static Future<void> addHistory(goalId, amount) async {
    await goalsCollection.doc(goalId).collection('history').add({
      'amount': amount,
      'date': DateTime.now(),
    });
  }

  static Future<void> updateGoalSavedAmount(goalId, amount) async {
    await goalsCollection.doc(goalId).update({'saved': amount});
  }

  static Future<void> deleteGoal(goalId) async {
    await goalsCollection.doc(goalId)
        .collection('history')
        .get()
        .then((snapshot) async {
          for (var doc in snapshot.docs) {
            await doc.reference.delete();
          }
        });

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


  // Send Notification
  // Cron Job
  static Future<void> expiringGoalNotification() async {
    // Get Expiring Goal
    final String uid = FirebaseInstance.auth.currentUser!.uid;
    bool isSentToday = false;
    final List<String> expiringGoals = [];
    final List<String> expiredGoals = [];
    // Before 3 days, on that day -expired. get Expired Goal notification(only sent once)
    final DateTime now = DateTime.now();
    final DateTime futureThreshold = getOnlyDate(DateTime(now.year, now.month, now.day + 3));
    final DateTime todayThreshold = getOnlyDate(DateTime(now.year, now.month, now.day));

    await FirebaseInstance.firestore.collection('notifications')
        .where('receiverID', arrayContains: uid)
        .where('type', whereIn: [NotificationType.EXPIRING_GOAL_NOTIFICATION, NotificationType.EXPIRED_GOAL_NOTIFICATION])
        .orderBy('createdAt', descending: true)
        .get()
        .then((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final DateTime lastNotificationDate = getOnlyDate(snapshot.docs.first['createdAt'].toDate());
            if (lastNotificationDate.isAtSameMomentAs(todayThreshold)) {
              isSentToday = true;
            }
          }
        });

    if (isSentToday) return;

    await goalsCollection
        .where('userID', isEqualTo: uid)
        // the goal is expiring (red date color)
        .where('targetDate', isLessThan: futureThreshold)
        .get()
        .then((goals) {
          for (var goal in goals.docs) {
            // if the goal is not achieved
            if (goal['saved'] < goal['amount']) {
              final DateTime targetDate = getOnlyDate(goal['targetDate'].toDate());
              if (targetDate.isAtSameMomentAs(todayThreshold) || targetDate.isAfter(todayThreshold)) {
                expiringGoals.add(goal['title']);
              }
              if (targetDate.isBefore(todayThreshold)) {
                expiredGoals.add(goal['title']);
              }
            }
          }
        });

    // Send Notification
    final List<String> receiverID = [uid];
    if (expiringGoals.isNotEmpty) {
      String goalNames = '';
      for (var goalName in expiringGoals) {
        goalNames += '$goalName, ';
      }
      goalNames = goalNames.substring(0, goalNames.length - 2);
      if (expiringGoals.length == 1) {
        goalNames += ' is';
      } else {
        goalNames += ' are';
      }
      const type = NotificationType.EXPIRING_GOAL_NOTIFICATION;
      await NotificationService.sendNotification(type, receiverID, objName: goalNames);
    }
    
    if (expiredGoals.isNotEmpty) {
      String goalNames = '';
      for (var goalName in expiredGoals) {
        goalNames += '$goalName, ';
      }
      goalNames = goalNames.substring(0, goalNames.length - 2);
      if (expiredGoals.length == 1) {
        goalNames += ' is';
      } else {
        goalNames += ' are';
      }
      const type = NotificationType.EXPIRED_GOAL_NOTIFICATION;
      await NotificationService.sendNotification(type, receiverID, objName: goalNames);
    }
  }
}
