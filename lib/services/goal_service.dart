import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/notification_type.dart';
import '../firebase_instance.dart';
import '../components/goal.dart';
import '../components/history_card.dart';
import 'notification_service.dart';

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
    final DateTime futureThreshold = DateTime(now.year, now.month, now.day + 3);
    final DateTime todayThreshold = DateTime(now.year, now.month, now.day);

    await FirebaseInstance.firestore.collection('notifications')
        .where('receiverID', arrayContains: uid)
        .where('type', whereIn: [NotificationType.EXPIRING_GOAL_NOTIFICATION, NotificationType.EXPIRED_GOAL_NOTIFICATION])
        .orderBy('createdAt', descending: true)
        .get()
        .then((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final DateTime lastNotificationDate = snapshot.docs.first['createdAt'].toDate();
            final DateTime onlyDate = DateTime(lastNotificationDate.year, lastNotificationDate.month, lastNotificationDate.day);
            if (onlyDate.isAtSameMomentAs(todayThreshold)) {
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
              final DateTime targetDate = goal['targetDate'].toDate();
              final DateTime onlyDate = DateTime(targetDate.year, targetDate.month, targetDate.day);
              if (onlyDate.isAtSameMomentAs(todayThreshold) || onlyDate.isAfter(todayThreshold)) {
                expiringGoals.add(goal['title']);
              }
              if (onlyDate.isBefore(todayThreshold)) {
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
