import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/transaction_service.dart';

class TotalTransactionProvider extends ChangeNotifier {
  late Stream<QuerySnapshot> _allTransactionsStream;
  late Stream<QuerySnapshot> _homeTransactionsStream;
  Map<String, double> _pieChartData = {};

  TotalTransactionProvider() {
    _allTransactionsStream = TransactionService.getAllTransactionStream();
    _homeTransactionsStream = TransactionService.getHomeTransactionStream();
    init();
  }

  Stream<QuerySnapshot> get getAllTransactionsStream => _allTransactionsStream;
  Stream<QuerySnapshot> get getHomeTransactionsStream => _homeTransactionsStream;
  Map<String, double> get getPieChartData => _pieChartData;

  Future<void> init() async {
    _pieChartData = await TransactionService.getPieChartData();
    notifyListeners();
  }

  Future<void> updateTransactions() async {
    _pieChartData = await TransactionService.getPieChartData();
    notifyListeners();
  }

  void reset() {
    _allTransactionsStream.listen((snapshot) {}).cancel();
    _allTransactionsStream = const Stream.empty();

    _homeTransactionsStream.listen((snapshot) {}).cancel();
    _homeTransactionsStream = const Stream.empty();

    _pieChartData = {};
    notifyListeners();
  }
}
