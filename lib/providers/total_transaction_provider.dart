import 'package:flutter/material.dart';
import '../components/transaction.dart';
import '../services/transaction_service.dart';

class TotalTransactionProvider extends ChangeNotifier {
  Future<List<TrackerTransaction>> _recentTransactions = Future.value([]);
  Future<List<TrackerTransaction>> _transactions = Future.value([]);
  Future<Map<String, double>> _pieChartData = Future.value({});

  TotalTransactionProvider() {
    _recentTransactions = TransactionService.getRecentTransactions();
    _transactions = TransactionService.getAllTransactions();
    _pieChartData = TransactionService.getPieChartData();
  }

  Future<List<TrackerTransaction>> get getRecentTransactions =>
      _recentTransactions;
  Future<List<TrackerTransaction>> get getTransactions => _transactions;
  Future<Map<String, double>> get getPieChartData => _pieChartData;

  void updateTransactions() {
    _recentTransactions = TransactionService.getRecentTransactions();
    _transactions = TransactionService.getAllTransactions();
    _pieChartData = TransactionService.getPieChartData();
    notifyListeners();
  }

  void reset() {
    _recentTransactions = Future.value([]);
    _transactions = Future.value([]);
    _pieChartData = Future.value({});
    notifyListeners();
  }
}
