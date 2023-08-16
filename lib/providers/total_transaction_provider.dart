import 'package:flutter/material.dart';

import '../components/tracker_transaction.dart';
import '../constants/constant.dart';
import '../services/transaction_service.dart';

class TotalTransactionProvider extends ChangeNotifier {
  List<TrackerTransaction> _transactions = [];
  Map<String, double> _pieChartData = {};

  TotalTransactionProvider() {
    init();
  }

  List<TrackerTransaction> get getTransactions => _transactions;
  Map<String, double> get getPieChartData => _pieChartData;

  void init() async {
    _transactions = await TransactionService.getAllTransactions();
    _pieChartData = await TransactionService.getPieChartData();
    notifyListeners();
  }

  List<TrackerTransaction> getRecentTransactions() {
    if (_transactions.isEmpty) {
      return [];
    }
    if (_transactions.length < 3) {
      return _transactions;
    }
    return _transactions.reversed.toList().sublist(0, 3);
  }

  Future<void> updateTransactions() async {
    _transactions = await TransactionService.getAllTransactions();
    _pieChartData = await TransactionService.getPieChartData();
    notifyListeners();
  }

  List<TrackerTransaction> getFilteredTransactions(String category) {
    if (category == Constant.noFilter) {
      return _transactions;
    }
    return _transactions.where((transaction) => transaction.category == category).toList();
  }

  void reset() {
    _transactions = [];
    _pieChartData = {};
    notifyListeners();
  }
}
