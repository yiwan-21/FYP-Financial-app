import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/notification_type.dart';
import '../firebase_instance.dart';
import '../models/notifications.dart';

class NotificationService {
  static CollectionReference get notificationCollection =>
      FirebaseInstance.firestore.collection('notifications');

  static Future<void> sendNotification(String type, List<String> receiverID, String? id) async {
    NotificationModel? newNotification = getNotificationModel(type, id: id);

    if (newNotification != null) {
      await notificationCollection.add({
        'receiverID': receiverID,
        'title': newNotification.title,
        'message': newNotification.message,
        'type': type,
        'functionID': id,
        'read': false,
        'createdAt': DateTime.now(),
      });
    }
  }

  static NotificationModel? getNotificationModel(String type, {String? id}) {
    NotificationModel? notificationModel;
    switch (type) {
      case NotificationType.NEW_EXPENSE_NOTIFICATION:
        if (id == null) return null;
        notificationModel = NewExpenseNotification(id);
        break;
      case NotificationType.EXPENSE_REMINDER_NOTIFICATION:
        if (id == null) return null;
        notificationModel = ExpenseReminderNotification(id);
        break;
      case NotificationType.NEW_GROUP_NOTIFICATION:
        notificationModel = NewGroupNotification();
        break;
      case NotificationType.NEW_CHAT_NOTIFICATION:
        if (id == null) return null;
        notificationModel = NewChatNotification(id);
        break;
      case NotificationType.EXPIRING_GOAL_NOTIFICATION:
        notificationModel = ExpiringGoalNotification();
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
