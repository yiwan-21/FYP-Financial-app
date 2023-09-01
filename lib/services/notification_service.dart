import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/notification_type.dart';
import '../firebase_instance.dart';
import '../models/notifications.dart';

class NotificationService {
  static CollectionReference get notificationCollection =>
      FirebaseInstance.firestore.collection('notifications');

  static Future<void> sendNotification(String type, List<String> receiverID, {String? functionID}) async {
    debugPrint('Sending Notification: $type, $receiverID, $functionID');
    NotificationModel? newNotification = getNotificationModel(type, DateTime.now(), false, functionID: functionID);

    if (newNotification != null) {
      await notificationCollection.add({
        'receiverID': receiverID,
        'title': newNotification.title,
        'message': newNotification.message,
        'type': type,
        'functionID': functionID,
        'read': newNotification.read,
        'createdAt': newNotification.date,
      });
    }
  }

  static NotificationModel? getNotificationModel(String type, DateTime date, bool read, {String? functionID}) {
    NotificationModel? notificationModel;
    switch (type) {
      case NotificationType.NEW_EXPENSE_NOTIFICATION:
        if (functionID == null) return null;
        notificationModel = NewExpenseNotification(functionID, date, read);
        break;
      case NotificationType.EXPENSE_REMINDER_NOTIFICATION:
        if (functionID == null) return null;
        notificationModel = ExpenseReminderNotification(functionID, date, read);
        break;
      case NotificationType.NEW_GROUP_NOTIFICATION:
        notificationModel = NewGroupNotification(date, read);
        break;
      case NotificationType.NEW_CHAT_NOTIFICATION:
        if (functionID == null) return null;
        notificationModel = NewChatNotification(functionID, date, read);
        break;
      case NotificationType.EXPIRING_GOAL_NOTIFICATION:
        notificationModel = ExpiringGoalNotification(date, read);
        break;
      case NotificationType.REMOVE_FROM_GROUP_NOTIFICATION:
        if (functionID == null) return null;
        notificationModel = RemoveFromGroupNotification(functionID, date, read);
        break;
    }
    return notificationModel;
  }

  static Stream<QuerySnapshot> getNotificationStream() {
    if (FirebaseInstance.auth.currentUser == null) {
      return const Stream.empty();
    }

    final String uid = FirebaseInstance.auth.currentUser!.uid;
    return notificationCollection
        .where('receiverID', arrayContains: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<void> markAsRead(String notificationID) async {
    await notificationCollection.doc(notificationID).update({'read': true});
  }

  static Future<void> cronJobDeletion() async {
    DateTime now = DateTime.now();
    DateTime lastMonth = now.subtract(const Duration(days: 30));
    await notificationCollection
        .where('createdAt', isLessThan: lastMonth)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }
}
