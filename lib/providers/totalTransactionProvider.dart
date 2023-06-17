import 'package:financial_app/components/transaction.dart';
import 'package:financial_app/firebaseInstance.dart';
import 'package:flutter/material.dart';

class TotalTransactionProvider extends ChangeNotifier {
  Future<List<TrackerTransaction>> _recentTransactions = Future.value([]);
  Future<List<TrackerTransaction>> _transactions = Future.value([]);
  Future<Map<String, double>> _pieChartData = Future.value({});

  TotalTransactionProvider() {
    _recentTransactions = _getRecentTransactions();
    _transactions = _getTransactions();
    _pieChartData = _getPieChartData();
  }

  Future<List<TrackerTransaction>> get getRecentTransactions => _recentTransactions;
  Future<List<TrackerTransaction>> get getTransactions => _transactions;
  Future<Map<String, double>> get getPieChartData => _pieChartData;

  void updateTransactions() {
    _recentTransactions = _getRecentTransactions();
    _transactions = _getTransactions();
    _pieChartData = _getPieChartData();
    notifyListeners();
  }

  void reset() {
    _recentTransactions = Future.value([]);
    _transactions = Future.value([]);
    _pieChartData = Future.value({});
    notifyListeners();
  }

  Future<List<TrackerTransaction>> _getRecentTransactions() async {
    final List<TrackerTransaction> transactions = [];
    await FirebaseInstance.firestore
        .collection('transactions')
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .orderBy('date', descending: true)
        .limit(3)
        .get()
        .then((event) {
      for (var transaction in event.docs) {
        transactions.add(TrackerTransaction(
          transaction.id,
          transaction['userID'],
          transaction['title'],
          transaction['amount'].toDouble(),
          transaction['date'].toDate(),
          transaction['isExpense'],
          transaction['category'],
          notes: transaction['notes'],
        ));
      }
    });
    return transactions;
  }

  Future<List<TrackerTransaction>> _getTransactions() async {
    final List<TrackerTransaction> transactionData = [];
    await FirebaseInstance.firestore.collection('transactions')
      .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
      .orderBy('date', descending: false)
      .get()
      .then((event) {
        for (var transaction in event.docs) {
          transactionData.add(TrackerTransaction(
            transaction.id,
            transaction['userID'],
            transaction['title'],
            transaction['amount'].toDouble(),
            transaction['date'].toDate(),
            transaction['isExpense'],
            transaction['category'],
            notes: transaction['notes'],
          ));
        }
      });
    return transactionData;
  }

  Future<Map<String, double>> _getPieChartData() async {
    Map<String, double> data = {};
    await FirebaseInstance.firestore
        .collection('transactions')
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .where('isExpense', isEqualTo: true)
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
}