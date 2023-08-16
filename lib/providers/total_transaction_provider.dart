import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/transaction_service.dart';

class TotalTransactionProvider extends ChangeNotifier {
  Map<String, double> _pieChartData = {};
  Stream<QuerySnapshot>? _transactionStream;

  TotalTransactionProvider() {
    init();
  }

  Map<String, double> get getPieChartData => _pieChartData;
  
  Stream<QuerySnapshot> get stream {
    _transactionStream = TransactionService.getTransactionStream();
    return _transactionStream!;
  }

  Future<void> init() async {
    _pieChartData = await TransactionService.getPieChartData();
    notifyListeners();
  }

  Future<void> updateTransactions() async {
    _pieChartData = await TransactionService.getPieChartData();
    notifyListeners();
  }

  void reset() {
    _pieChartData = {};
    _transactionStream?.listen((snapshot) {}).cancel();
    _transactionStream = null;
    notifyListeners();
  }
}
