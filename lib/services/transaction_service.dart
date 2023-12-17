import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_instance.dart';
import '../constants/constant.dart';
import '../components/history_card.dart';
import '../components/tracker_transaction.dart';
import '../services/budget_service.dart';

class TransactionService {
  static CollectionReference transactionCollection =
      FirebaseInstance.firestore.collection('transactions');

  static Stream<QuerySnapshot> getAllTransactionStream() {
    if (FirebaseInstance.auth.currentUser != null) {
      return transactionCollection
          .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
          .orderBy('date', descending: false)
          .snapshots();
    } else {
      return const Stream.empty();
    }
  }

  static Stream<QuerySnapshot> getHomeTransactionStream() {
    if (FirebaseInstance.auth.currentUser != null) {
      return transactionCollection
          .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
          .orderBy('date', descending: true)
          .limit(3)
          .snapshots();
    } else {
      return const Stream.empty();
    }
  }

  static Future<void> addTransaction(TrackerTransaction newTransaction) async {
    await transactionCollection.add({
      ...newTransaction.toCollection(),
      'userID': FirebaseInstance.auth.currentUser!.uid
    });

    // update user's budgeting data
    if (newTransaction.isExpense) {
      await BudgetService.updateUsedAmount(
          newTransaction.category, newTransaction.amount, newTransaction.date);
    }
  }

  static Future<void> updateTransaction(TrackerTransaction editedTransaction,
      TrackerTransaction previousTransaction) async {
    await transactionCollection
        .doc(editedTransaction.id)
        .update(editedTransaction.toCollection());

    await BudgetService.updateOnTransactionChanged(
        previousTransaction, editedTransaction);
  }

  static Future<void> deleteTransaction(
      String transactionId, bool isExpense) async {
    // update user's budgeting data
    if (isExpense) {
      await transactionCollection
          .doc(transactionId)
          .get()
          .then((snapshot) async {
        final category = snapshot['category'];
        final amount = snapshot['amount'].toDouble();
        final date = snapshot['date'].toDate();
        await BudgetService.updateUsedAmount(category, -amount, date);
      });
    }

    await transactionCollection.doc(transactionId).delete();
  }

  static Future<Map<String, double>> getPieChartData() async {
    Map<String, double> data = {};
    if (FirebaseInstance.auth.currentUser == null) {
      return data;
    }
    await transactionCollection
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .where('isExpense', isEqualTo: true)
        .where('category', whereIn: Constant.expenseCategories)
        .orderBy('date', descending: false)
        .get()
        .then((value) {
      for (var transaction in value.docs) {
        final category = transaction['category'];
        final amount = transaction['amount'].toDouble();
        if (data.containsKey(category)) {
          data[category] = data[category]! + amount;
        } else {
          data[category] = amount;
        }
      }
    });
    return data;
  }

  // Budgeting
  static Future<double> getExpenseByCategory(
      String category, DateTime startingDate) async {
    double total = 0;

    await transactionCollection
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .where('category', isEqualTo: category)
        .where('date', isGreaterThanOrEqualTo: startingDate)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        for (var transaction in snapshot.docs) {
          total += transaction['amount'].toDouble();
        }
      }
    });

    return total;
  }

  static Future<List<HistoryCard>> getHistoryCards(
      String category, DateTime startingDate) async {
    final List<HistoryCard> historyCards = [];

    await transactionCollection
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .where('category', isEqualTo: category)
        .where('date', isGreaterThanOrEqualTo: startingDate)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        for (var transaction in snapshot.docs) {
          historyCards.add(HistoryCard(
            transaction['amount'].toDouble(),
            transaction['date'].toDate(),
          ));
        }
      }
    });

    return historyCards;
  }

  static Future<double> calSurplus() async {
    double income = 0;
    double expense = 0;
    final DateTime thisMonth =
        DateTime(DateTime.now().year, DateTime.now().month, 1);
    await transactionCollection
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .where('date', isGreaterThanOrEqualTo: thisMonth)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        for (var transaction in snapshot.docs) {
          if (transaction['isExpense']) {
            expense += transaction['amount'];
          } else {
            income += transaction['amount'];
          }
        }
      }
    });

    return income - expense;
  }

  // Cron Job Deletion
  static Future<void> resetTransactions() async {
    const String surplusTitle = 'Surplus from previous months';
    double surplus = 0;
    final DateTime now = DateTime.now();
    final DateTime lastFive = DateTime(now.year, now.month - 5, 1);
    await transactionCollection
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .where('date', isLessThan: lastFive)
        .get()
        .then((snapshot) async {
      if (snapshot.docs.length == 1 &&
          snapshot.docs.first['title'] == surplusTitle) {
        return;
      }
      if (snapshot.docs.isNotEmpty) {
        for (var transaction in snapshot.docs) {
          if (transaction['isExpense']) {
            surplus -= transaction['amount'];
          } else {
            surplus += transaction['amount'];
          }
          await transaction.reference.delete();
        }

        await transactionCollection.add({
          'amount': surplus.abs(),
          'category': surplus < 0 ? 'Other Expenses' : 'Savings',
          'date': lastFive.subtract(const Duration(days: 1)),
          'isExpense': surplus < 0,
          'notes': 'Auto Generated: Surplus from previous months',
          'title': surplusTitle,
          'userID': FirebaseInstance.auth.currentUser!.uid
        });
      }
    });
  }
}
