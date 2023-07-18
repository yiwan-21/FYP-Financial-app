import 'package:flutter/material.dart';
import '../components/transaction.dart';
import '../services/transaction_service.dart';

class TotalTransactionProvider extends ChangeNotifier {
  final TransactionService _transactionService = TransactionService();
  Future<List<TrackerTransaction>> _recentTransactions = Future.value([]);
  Future<List<TrackerTransaction>> _transactions = Future.value([]);
  Future<Map<String, double>> _pieChartData = Future.value({});

  TotalTransactionProvider() {
    _recentTransactions = _transactionService.getRecentTransactions();
    _transactions = _transactionService.getAllTransactions();
    _pieChartData = _transactionService.getPieChartData();
  }

  Future<List<TrackerTransaction>> get getRecentTransactions => _recentTransactions;
  Future<List<TrackerTransaction>> get getTransactions => _transactions;
  Future<Map<String, double>> get getPieChartData => _pieChartData;

  void updateTransactions() {
    _recentTransactions = _transactionService.getRecentTransactions();
    _transactions = _transactionService.getAllTransactions();
    _pieChartData = _transactionService.getPieChartData();
    notifyListeners();
  }

  void reset() {
    _recentTransactions = Future.value([]);
    _transactions = Future.value([]);
    _pieChartData = Future.value({});
    notifyListeners();
  }
}