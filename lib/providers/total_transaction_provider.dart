import 'package:flutter/material.dart';

import '../components/tracker_transaction.dart';
import '../constants/constant.dart';
import '../services/transaction_service.dart';

class TotalTransactionProvider extends ChangeNotifier {
  List<TrackerTransaction> _recentTransactions = [];
  List<TrackerTransaction> _transactions = [];
  Map<String, double> _pieChartData = {};

  TotalTransactionProvider() {
    init();
  }

  List<TrackerTransaction> get getRecentTransactions =>_recentTransactions;
  List<TrackerTransaction> get getTransactions => _transactions;
  Map<String, double> get getPieChartData => _pieChartData;

  void init() async {
    _transactions = await TransactionService.getAllTransactions().then((transactions) {
      _recentTransactions = transactions.reversed.toList().sublist(0, 3);
      return transactions;
    });
    _pieChartData = await TransactionService.getPieChartData();
    notifyListeners();
  }

  void updateTransactions() async {
    _transactions = await TransactionService.getAllTransactions().then((transactions) {
      _recentTransactions = transactions.reversed.toList().sublist(0, 3);
      return transactions;
    });
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
    _recentTransactions = [];
    _transactions = [];
    _pieChartData = {};
    notifyListeners();
  }
}
