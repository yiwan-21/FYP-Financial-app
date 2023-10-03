import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_instance.dart';
import '../utils/date_utils.dart';
import '../constants/notification_type.dart';
import '../services/notification_service.dart';

class BillService {
  static CollectionReference billsCollection =
      FirebaseInstance.firestore.collection('bills');

  static Stream<QuerySnapshot> getBillStream(){
    return billsCollection
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .snapshots();
  }

  static Future<void> addBill(String title, double amount, DateTime dueDate, bool fixed) async {
    await billsCollection.add({
      'userID': FirebaseInstance.auth.currentUser!.uid,
      'title': title,
      'amount': amount,
      'dueDate': getOnlyDate(dueDate),
      'fixed': fixed,
      'paid': false,
      'history': [],
      'notified': false,
    });
  }

  // scenario
  // not paid, edit bill amount
  // paid, edit bill amount
  static Future<void> editBill(String id, String title, double amount, DateTime dueDate, bool fixed) async {
    await billsCollection.doc(id).update({
      'title': title,
      'amount': amount,
      'dueDate': getOnlyDate(dueDate),
      'fixed': fixed,
    });
  }

  static Future<void> payBill(String id, double amount, bool fixed) async {
    await billsCollection
        .doc(id)
        .get()
        .then((snapshot) async {
          if (snapshot.exists) {
            List<Map<String, dynamic>> history = List<Map<String, dynamic>>.from(snapshot['history']);
            if (history.length == 2) {
              DateTime date1 = history.first['date'].toDate();
              DateTime date2 = history.last['date'].toDate();
              if (date1.isBefore(date2)) {
                history.removeAt(0);
              } else {
                history.removeAt(1);
              }
            }
            history.add({
              'date': getOnlyDate(DateTime.now()),
              'amount': amount,
            });
            await billsCollection.doc(id).update({
              'paid': true,
              'history': history,
              'amount': fixed ? snapshot['amount'] : amount,
            });
          }
        });
  }

  static Future<void> deleteBill(String id) async {
    await billsCollection.doc(id).delete();
  }

  static Future<void> resetBill() async {
    await billsCollection
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .get()
        .then((snapshot) async {
          if (snapshot.docs.isNotEmpty) {
            final DateTime date = snapshot.docs.first['dueDate'].toDate();
            final DateTime now = DateTime.now();
            if (date.month != now.month) {
              for (var bill in snapshot.docs) {
                DateTime dueDate = bill['dueDate'].toDate();
                DateTime nextMonth = DateTime(now.year, now.month, dueDate.day);
                if (nextMonth.month != now.month) {
                  nextMonth = DateTime(now.year, now.month + 1, 0);
                }
                await bill.reference.update({
                  'paid': false,
                  'notified': false,
                  'dueDate': nextMonth,
                });
              }
            }
          }
        });
  }

  // Send Notification
  // Cron Job
  static Future<void> billDueNotification() async {
    final String uid = FirebaseInstance.auth.currentUser!.uid;
    bool isSentToday = false;
    final List<Map<String, int>> dueBills = [];

    // Send notification when bill is due in 3 days. 
    final DateTime now = DateTime.now();
    final DateTime futureThreshold = DateTime(now.year, now.month, now.day + 3);
    final DateTime todayThreshold = DateTime(now.year, now.month, now.day);

    await FirebaseInstance.firestore.collection('notifications')
        .where('receiverID', arrayContains: uid)
        .where('type', isEqualTo: NotificationType.BILL_DUE_NOTIFICATION)
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

    // get due bills
    String notificationMessage = '';
    await billsCollection
        .where('userID', isEqualTo: uid)
        .where('paid', isEqualTo: false)
        .where('notified', isEqualTo: false)
        .where('dueDate', isLessThan: futureThreshold)
        .get()
        .then((snapshot) {
          for (var bill in snapshot.docs) {
            final DateTime dueDate = bill['dueDate'].toDate();
            final int dueIn = dueDate.difference(todayThreshold).inDays;
            final String title = bill['title'];
            dueBills.add({
              title: dueIn,
            });
            
            if (dueIn < 0) {
              notificationMessage += '$title is overdue.\n';
              bill.reference.update({'notified': true});
            } else if (dueIn == 0) {
              notificationMessage += '$title is due today.\n';
            } else {
              notificationMessage += '$title is due in $dueIn ${dueIn > 1 ? 'days': 'day'}.\n';
            }
          }
        });

    // send notification
    if (dueBills.isNotEmpty) {
      const String type = NotificationType.BILL_DUE_NOTIFICATION;
      final List<String> receiverID = [uid];
      // remove last 'nextLine'
      notificationMessage = notificationMessage.substring(0, notificationMessage.length - 1);
      await NotificationService.sendNotification(type, receiverID, objName: notificationMessage);
    }
  }
}
