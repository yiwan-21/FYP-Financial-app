import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/components/budget_card.dart';
import 'package:flutter/material.dart';

import '../components/tracker_transaction.dart';
import '../firebase_instance.dart';
import '../services/transaction_service.dart';

class BudgetService {
  static CollectionReference budgetsCollection =
      FirebaseInstance.firestore.collection('budgets');

  static String documentID = '';
  static DateTime startingDate = DateTime.now();
    static DateTime resettingDate = DateTime.now();

  static Future<void> setDocumentID() async {
    final String uid = FirebaseInstance.auth.currentUser!.uid;
    await budgetsCollection
        .where('userID', isEqualTo: uid)
        .limit(1)
        .get()
        .then((snapshot) async {
      if (snapshot.docs.isEmpty || !snapshot.docs.first.exists) {
        startingDate = getOnlyDate(DateTime.now());
        resettingDate = getNextMonth(startingDate);
        DocumentReference budgetDoc = await budgetsCollection.add({
          'userID': uid,
          'startDate': startingDate,
          'resetDate': resettingDate,
        });
        documentID = budgetDoc.id;
      } else {
        documentID = snapshot.docs.first.id;
        startingDate = getOnlyDate(snapshot.docs.first['startDate'].toDate());
        resettingDate = getOnlyDate(snapshot.docs.first['resetDate'].toDate());
      }
    });
  }

  static void resetDocumentID() {
    documentID = '';
  }

  static Future<Stream<QuerySnapshot>> getBudgetingStream() async {
    if (FirebaseInstance.auth.currentUser == null || documentID == '') {
      await setDocumentID();
    }
    
    return budgetsCollection
        .doc(documentID)
        .collection('details')
        .snapshots();
  }

  static Stream<DocumentSnapshot> getSingleBudgetStream(String category) {
    return budgetsCollection
        .doc(documentID)
        .collection('details')
        .doc(category)
        .snapshots();
  }

  static Future<bool> isCategoryExist(String category) async {
    bool isExist = false;

    await budgetsCollection 
        .doc(documentID)
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
        .doc(documentID)
        .collection('details')
        .doc(budget.category)
        .set({
      'amount': budget.amount,
      'used': await TransactionService.getExpenseByCategory(budget.category, startingDate),
    });
  }

  static Future<void> updateTotalBudget(String category, double amount) async {
    await budgetsCollection
        .doc(documentID)
        .collection('details')
        .doc(category)
        .update({
          'amount': amount,
        });
  }
  
  static Future<void> updateDate(DateTime date) async {
    DateTime resetDate = getOnlyDate(date);
    resettingDate = resetDate;
    await budgetsCollection.doc(documentID).update({
      'resetDate': resetDate,
    });
  }

  //get from tracker for history
  static Future<void> getTotalAmount() async {
    // await budgetsCollection
    //     .doc(documentID)
    //     .collection('details')
    //     .get()
    //     .then((snapshot) {
    //       for (var category in snapshot.docs) {
    //         TransactionService.getExpenseByCategory(category.id, );
    //       }
    //     })
  }

  static Future<void> updateUsedAmount(
      String category, double amount, DateTime transactionDate) async {
    // check if date is within budgeting date range
    if (transactionDate.isAfter(startingDate) ||
        transactionDate.isAtSameMomentAs(startingDate)) {
      // check if category exists
      await budgetsCollection
          .doc(documentID)
          .collection('details')
          .doc(category)
          .get()
          .then((snapshot) async {
        if (snapshot.exists) {
          snapshot.reference.update({
            'used': FieldValue.increment(amount),
          });
        }
      });
    }
  }

  static Future<void> updateOnTransactionChanged(
    TrackerTransaction previous, TrackerTransaction current) async {
    if (documentID == '') {
      await setDocumentID();
    }
    // subtract amount in previous category
    bool toSubtractPrevious =
        previous.date.isAfter(startingDate) && previous.isExpense;
    // add amount in current category
    bool toAddCurrent =
        current.date.isAfter(startingDate) && current.isExpense;

    await budgetsCollection
        .doc(documentID)
        .collection('details')
        .get()
        .then((snapshot) {
          try {
            if (toSubtractPrevious) {
              snapshot.docs
                  .firstWhere((doc) => doc.id == previous.category)
                  .reference
                  .update({
                'used': FieldValue.increment(-previous.amount),
              });
            }
            if (toAddCurrent) {
              snapshot.docs
                  .firstWhere((doc) => doc.id == current.category)
                  .reference
                  .update({
                'used': FieldValue.increment(current.amount),
              });
            }
          } catch (e) {
            debugPrint('Error on updateOnTransactionChanged: $e');
          }
    });
  }

  static Future<void> deleteBudget(String category) async {
    await budgetsCollection
        .doc(documentID)
        .collection('details')
        .doc(category)
        .delete();
  }
 
  static Future<void> resetBudget() async {
    if (FirebaseInstance.auth.currentUser == null || documentID == '') {
      await setDocumentID();
    }
    
    await budgetsCollection
        .doc(documentID)
        .get()
        .then((snapshot) async {
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
 
 
  // utils
  static DateTime getOnlyDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime getNextMonth(DateTime date) {
    DateTime nextMonth = DateTime(date.year, date.month + 1, date.day);
    if (nextMonth.month - date.month > 1) {
      nextMonth = DateTime(date.year, date.month, 0);
    }
    return nextMonth;
  }
}
