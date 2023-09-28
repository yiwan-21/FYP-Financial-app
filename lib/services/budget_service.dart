import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/components/budget_card.dart';
import 'package:flutter/material.dart';

import '../firebase_instance.dart';
import '../components/tracker_transaction.dart';
import '../constants/notification_type.dart';
import '../services/transaction_service.dart';
import '../services/notification_service.dart';
import '../utils/date_utils.dart';

class BudgetService {
  static CollectionReference budgetsCollection =
      FirebaseInstance.firestore.collection('budgets');

  static String _uid = FirebaseInstance.auth.currentUser!.uid;
  static DateTime startingDate = DateTime.now();
  static DateTime resettingDate = DateTime.now();

  static Future<void> setDocumentID() async {
    _uid = FirebaseInstance.auth.currentUser!.uid;
    await budgetsCollection.doc(_uid).get().then((snapshot) async {
      if (snapshot.exists) {
        startingDate = getOnlyDate(snapshot['startDate'].toDate());
        resettingDate = getOnlyDate(snapshot['resetDate'].toDate());
      } else {
        startingDate = getOnlyDate(DateTime.now());
        resettingDate = getNextMonth(startingDate);
        await budgetsCollection.doc(_uid).set({
          'startDate': startingDate,
          'resetDate': resettingDate,
        });
      }
    });
  }

  static void resetDocumentID() {
    _uid = '';
  }

  static Future<Stream<QuerySnapshot>> getBudgetingStream() async {
    if (FirebaseInstance.auth.currentUser == null || _uid == '') {
      await setDocumentID();
    }

    return budgetsCollection.doc(_uid).collection('details').snapshots();
  }

  static Stream<DocumentSnapshot> getSingleBudgetStream(String category) {
    if (category == '') {
      return const Stream.empty();
    }
    
    return budgetsCollection
        .doc(_uid)
        .collection('details')
        .doc(category)
        .snapshots();
  }

  static Future<List<String>> getBudgetCategories() async {
    if (FirebaseInstance.auth.currentUser == null || _uid == '') {
      await setDocumentID();
    }

    final List<String> categories = [];
    await budgetsCollection
        .doc(_uid)
        .collection('details')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        categories.add(doc.id);
      }
    });

    return categories;
  }

  static Future<bool> isCategoryExist(String category) async {
    bool isExist = false;

    await budgetsCollection
        .doc(_uid)
        .collection('details')
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        if (doc.id == category) {
          isExist = true;
          break;
        }
      }
    });

    return isExist;
  }

  static Future<void> addBudget(BudgetCard budget) async {
    await budgetsCollection
        .doc(_uid)
        .collection('details')
        .doc(budget.category)
        .set({
      'amount': budget.amount,
      'used': await TransactionService.getExpenseByCategory(
          budget.category, startingDate),
    });
  }

  static Future<void> updateTotalBudget(String category, double amount) async {
    await budgetsCollection
        .doc(_uid)
        .collection('details')
        .doc(category)
        .update({
      'amount': amount,
    });
  }

  static Future<void> updateDate(DateTime date) async {
    DateTime resetDate = getOnlyDate(date);
    resettingDate = resetDate;
    await budgetsCollection.doc(_uid).update({
      'resetDate': resetDate,
    });
  }

  static Future<void> updateUsedAmount(
      String category, double amount, DateTime transactionDate) async {
    // check if date is within budgeting date range
    if (transactionDate.isAfter(startingDate) ||
        transactionDate.isAtSameMomentAs(startingDate)) {
      // check if category exists
      await budgetsCollection
          .doc(_uid)
          .collection('details')
          .doc(category)
          .get()
          .then((snapshot) async {
        if (snapshot.exists) {
          await snapshot.reference.update({
            'used': FieldValue.increment(amount),
          }).then((_) async {
            double total = snapshot['amount'].toDouble();
            double used = snapshot['used'].toDouble();
            await notifyExceedingBudget(category, total, used);
          });
        }
      });
    }
  }

  static Future<void> updateOnTransactionChanged(
      TrackerTransaction previous, TrackerTransaction current) async {
    if (_uid == '') {
      await setDocumentID();
    }
    // subtract amount in previous category
    bool toSubtractPrevious =
        previous.date.isAfter(startingDate) && previous.isExpense;
    // add amount in current category
    bool toAddCurrent = current.date.isAfter(startingDate) && current.isExpense;

    await budgetsCollection
        .doc(_uid)
        .collection('details')
        .get()
        .then((snapshot) async {
      try {
        if (toSubtractPrevious) {
          await snapshot.docs
              .firstWhere((doc) => doc.id == previous.category)
              .reference
              .update({
            'used': FieldValue.increment(-previous.amount),
          });
        }
        if (toAddCurrent) {
          DocumentReference currentDoc = snapshot.docs
              .firstWhere((doc) => doc.id == current.category)
              .reference;
          await currentDoc.update({
            'used': FieldValue.increment(current.amount),
          });
          await currentDoc.get().then((snapshot) async {
            double total = snapshot['amount'].toDouble();
            double used = snapshot['used'].toDouble();
            await notifyExceedingBudget(current.category, total, used);
          });
        }
      } catch (e) {
        debugPrint('Error on updateOnTransactionChanged: $e');
      }
    });
  }

  static Future<void> deleteBudget(String category) async {
    await budgetsCollection
        .doc(_uid)
        .collection('details')
        .doc(category)
        .delete();
  }

  static Future<void> resetBudget() async {
    if (FirebaseInstance.auth.currentUser == null || _uid == '') {
      await setDocumentID();
    }

    await budgetsCollection.doc(_uid).get().then((snapshot) async {
      if (!snapshot.exists || snapshot['resetDate'] == null) {
        return;
      }

      DateTime resetDate = snapshot['resetDate'].toDate();

      if (getOnlyDate(DateTime.now()).isBefore(resetDate)) {
        return;
      }

      DateTime nextResetDate = getNextMonth(resetDate);
      startingDate = resetDate;
      resettingDate = nextResetDate;

      await snapshot.reference.update({
        'startDate': resetDate,
        'resetDate': nextResetDate,
      });

      await snapshot.reference
          .collection('details')
          .get()
          .then((snapshot) async {
        for (var doc in snapshot.docs) {
          await doc.reference.update({
            'used': 0,
          });
        }
      });
    });
  }

  // Send Notification
  static Future<void> notifyExceedingBudget(
      String category, double total, double used) async {
    if (used >= total) {
      // send exceeded budget notification
      const String type = NotificationType.EXCEED_BUDGET_NOTIFICATION;
      final List<String> receiverID = [FirebaseInstance.auth.currentUser!.uid];
      await NotificationService.sendNotification(type, receiverID,
          objName: category);
    } else if (used >= (total * 0.8)) {
      // send exceeding budget notification
      const String type = NotificationType.EXCEEDING_BUDGET_NOTIFICATION;
      final List<String> receiverID = [FirebaseInstance.auth.currentUser!.uid];
      await NotificationService.sendNotification(type, receiverID,
          objName: category);
    }
  }
}
