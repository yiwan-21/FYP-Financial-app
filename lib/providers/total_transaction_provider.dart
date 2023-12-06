import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../components/tracker_transaction.dart';
import '../constants/constant.dart';
import '../services/transaction_service.dart';

class TotalTransactionProvider extends ChangeNotifier {
  StreamSubscription? _listener; 
  final List<TrackerTransaction> _transactions = [];
  final Map<String, double> _pieChartData = {};

  TotalTransactionProvider() {
    init();
  }

  List<TrackerTransaction> get getTransactions => _transactions;
  Map<String, double> get getPieChartData => _pieChartData;

  void init() {
    _listener = TransactionService.getAllTransactionStream().listen((event) {
      event.metadata.isFromCache
          ? print("Tracker Stream: Data from local cache")
          : print("Tracker Stream: Data from server");
      event.metadata.hasPendingWrites // pendingWrites ? "Local" : "Server";
          ? print("Tracker Stream: There are pending writes")
          : print("Tracker Stream: There are no pending writes");
      print("Tracker Stream: Document changes: ${event.docChanges.length}");

      for (var change in event.docChanges) {
        String category = change.doc['category'];
        double amount = change.doc['amount'].toDouble();
        if (change.type == DocumentChangeType.added) {
          _transactions.insert(0, TrackerTransaction.fromSnapshot(change.doc));
          if (Constant.expenseCategories.contains(category)) {
            if (_pieChartData.containsKey(category)) {
              _pieChartData[category] = _pieChartData[category]! + amount;
            } else {
              _pieChartData[category] = amount;
            }
          }
        } else if (change.type == DocumentChangeType.modified) {
          int index = _transactions.indexWhere((element) => element.id == change.doc.id);
          double prevAmount = _transactions[index].amount;
          _transactions[index] = TrackerTransaction.fromSnapshot(change.doc);
          _pieChartData[category] = _pieChartData[category]! - prevAmount + amount;
        } else if (change.type == DocumentChangeType.removed) {
          _transactions.removeWhere((element) => element.id == change.doc.id);
          if (Constant.expenseCategories.contains(category)) {
            _pieChartData[category] = _pieChartData[category]! - amount;
          }
        }
      }
      notifyListeners();
    });
  }

  void reset() {
    _listener?.cancel();
    _transactions.clear();
    _pieChartData.clear();
    notifyListeners();
  }
}
