import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/notification_type.dart';
import '../firebase_instance.dart';
import '../models/notifications.dart';
import 'split_money_service.dart';

class NotificationService {
  static CollectionReference get notificationCollection =>
      FirebaseInstance.firestore.collection('notifications');

  static Future<void> sendNotification(String type, List<String> receiverID, {String? functionID}) async {
    debugPrint('Sending Notification: $type, $receiverID, $functionID');
    NotificationModel? newNotification = await getNotificationModel(type, functionID: functionID);
    debugPrint('notification: ${newNotification?.message}');
    if (newNotification != null) {
      await notificationCollection.add({
        'receiverID': receiverID,
        'title': newNotification.title,
        'message': newNotification.message,
        'type': type,
        'functionID': functionID,
        'read': List<bool>.filled(receiverID.length, false),
        'createdAt': DateTime.now(),
      });
    }
  }

  static Future<NotificationModel?> getNotificationModel(String type, {String? functionID}) async {
    NotificationModel? notificationModel;
    switch (type) {
      case NotificationType.NEW_EXPENSE_NOTIFICATION:
        if (functionID == null) return null;
        final String groupID = functionID;
        final groupName = await SplitMoneyService.getGroupName(groupID);
        notificationModel = NewExpenseNotification(groupName, groupID);
        break;
      case NotificationType.EXPENSE_REMINDER_NOTIFICATION:
        if (functionID == null) return null;
        final expenseID = functionID;
        final expenseName = await SplitMoneyService.getExpenseName(expenseID);
        notificationModel = ExpenseReminderNotification(expenseName, expenseID);
        break;
      case NotificationType.NEW_GROUP_NOTIFICATION:
        if (functionID == null) return null;
        final groupName = await SplitMoneyService.getGroupName(functionID);
        notificationModel = NewGroupNotification(groupName);
        break;
      case NotificationType.NEW_CHAT_NOTIFICATION:
        if (functionID == null) return null;
        final expenseID = functionID;
        final expenseName = await SplitMoneyService.getExpenseName(expenseID);
        notificationModel = NewChatNotification(expenseName, expenseID);
        break;
      case NotificationType.EXPIRING_GOAL_NOTIFICATION:
        notificationModel = ExpiringGoalNotification();
        break;
      case NotificationType.EXPIRED_GOAL_NOTIFICATION:
        notificationModel = ExpiredGoalNotification();
        break;
      case NotificationType.REMOVE_FROM_GROUP_NOTIFICATION:
        if (functionID == null) return null;
        final groupName = await SplitMoneyService.getGroupName(functionID);
        notificationModel = RemoveFromGroupNotification(groupName);
        break;
    }
    return notificationModel;
  }

  static Function getNotificationFunction(String type, String? functionID) {
    NotificationModel? notificationModel;
    switch (type) {
      case NotificationType.NEW_EXPENSE_NOTIFICATION:
        if (functionID == null) break;
        final String groupID = functionID;
        notificationModel = NewExpenseNotification('', groupID);
        break;
      case NotificationType.EXPENSE_REMINDER_NOTIFICATION:
        if (functionID == null) break;
        final expenseID = functionID;
        notificationModel = ExpenseReminderNotification('', expenseID);
        break;
      case NotificationType.NEW_GROUP_NOTIFICATION:
        notificationModel = NewGroupNotification('');
        break;
      case NotificationType.NEW_CHAT_NOTIFICATION:
        if (functionID == null) break;
        final expenseID = functionID;
        notificationModel = NewChatNotification('', expenseID);
        break;
      case NotificationType.EXPIRING_GOAL_NOTIFICATION:
        notificationModel = ExpiringGoalNotification();
        break;
      case NotificationType.EXPIRED_GOAL_NOTIFICATION:
        notificationModel = ExpiredGoalNotification();
        break;
      case NotificationType.REMOVE_FROM_GROUP_NOTIFICATION:
        notificationModel = RemoveFromGroupNotification('');
        break;
    }
    if (notificationModel == null) {
      return () {};
    }
    debugPrint('notificationModel: ${notificationModel.navigateFunction()}');
    return notificationModel.navigateFunction();
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
    final String uid = FirebaseInstance.auth.currentUser!.uid;
    await notificationCollection
        .doc(notificationID)
        .get()
        .then((notification) async {
          int index = List<String>.from(notification['receiverID']).indexOf(uid);
          List<bool> read = List<bool>.from(notification['read']);
          
          if (index == -1 || read[index]) {
            return;
          }

          read[index] = true;
          await notification.reference.update({'read': read});
        });
  }

  static Future<void> cronJobDeletion() async {
    DateTime now = DateTime.now();
    DateTime lastWeek = now.subtract(const Duration(days: 7));
    await notificationCollection
        .where('createdAt', isLessThan: lastWeek)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }
}
