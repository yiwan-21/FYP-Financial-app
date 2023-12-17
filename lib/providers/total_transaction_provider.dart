import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/components/daily_surplus_chart.dart';
import 'package:financial_app/utils/date_utils.dart';
import 'package:flutter/material.dart';

import '../components/tracker_overview_chart.dart';
import '../components/tracker_transaction.dart';
import '../constants/constant.dart';
import '../services/transaction_service.dart';

class TotalTransactionProvider extends ChangeNotifier {
  StreamSubscription? _listener;
  final List<TrackerTransaction> _transactions = [];
  final Map<String, double> _pieChartData = {};
  final List<DailySurplusData> _dailySurplusData = [];

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
        int index = _transactions.indexWhere((element) => element.id == change.doc.id);
        String category = change.doc['category'];
        double amount = change.doc['amount'].toDouble();
        DateTime transactionDate = getOnlyDate(change.doc['date'].toDate());
        bool isExpense = change.doc['isExpense'];
        if (change.type == DocumentChangeType.added) {
          //// add the transaction
          _transactions.insert(0, TrackerTransaction.fromSnapshot(change.doc));
          //// update the pie chart data
          if (Constant.expenseCategories.contains(category)) {
            if (_pieChartData.containsKey(category)) {
              _pieChartData[category] = _pieChartData[category]! + amount;
            } else {
              _pieChartData[category] = amount;
            }
          }
          //// update the daily surplus data
          if (_dailySurplusData.isNotEmpty) {
            for (DailySurplusData data in _dailySurplusData) {
              if (!transactionDate.isAfter(data.date)) {
                // adding new data, expense = subtract, income = add
                data.addSurplus(isExpense ? -amount : amount);
              }
            }
          }
        } else if (change.type == DocumentChangeType.modified) {
          double prevAmount = _transactions[index].amount;
          DateTime prevDate = getOnlyDate(_transactions[index].date);
          bool prevIsExpense = _transactions[index].isExpense;
          //// update the transaction
          _transactions[index] = TrackerTransaction.fromSnapshot(change.doc);
          //// update the pie chart data
          _pieChartData[category] = _pieChartData[category]! - prevAmount + amount;
          //// update the daily surplus data
          for (DailySurplusData data in _dailySurplusData) {
            // process the previous date
            if (!prevDate.isAfter(data.date)) {
              // removing old data, expense = add, income = subtract
              data.addSurplus(prevIsExpense ? prevAmount : -prevAmount);
            }
            // process the modified date
            if (!transactionDate.isAfter(data.date)) {
              // adding new data, expense = subtract, income = add
              data.addSurplus(prevIsExpense ? -amount : amount);
            }
          }
        } else if (change.type == DocumentChangeType.removed) {
          bool prevIsExpense = _transactions[index].isExpense;
          //// remove the transaction
          _transactions.removeWhere((element) => element.id == change.doc.id);
          //// update the pie chart data
          if (Constant.expenseCategories.contains(category)) {
            _pieChartData[category] = _pieChartData[category]! - amount;
          }
          //// update the daily surplus data
          for (DailySurplusData data in _dailySurplusData) {
            if (!transactionDate.isAfter(data.date)) {
              // removing old data, expense = add, income = subtract
              data.addSurplus(prevIsExpense ? amount : -amount);
            }
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
    _dailySurplusData.clear();
    notifyListeners();
  }

  // find the existing data in _dailySurplusData
  // if data is not available, calculate the data
  // return the _dailySurplusData between startDate and endDate
  List<DailySurplusData> getDailySurplusData(DateTime startDate, DateTime endDate) {
    startDate = getOnlyDate(startDate);
    endDate = getOnlyDate(endDate);
    int days = endDate.difference(startDate).inDays;
    List<DailySurplusData> dataToBeCalculated = List.generate(
      days + 1,
      (index) => DailySurplusData(startDate.add(Duration(days: index)), 0),
    );

    //// check for existing data
    if (_dailySurplusData.isNotEmpty) {
      List<DailySurplusData> matches = _dailySurplusData.where((element) =>
          element.date.isAtSameMomentAs(startDate) ||
          element.date.isAtSameMomentAs(endDate) ||
          (element.date.isAfter(startDate) && element.date.isBefore(endDate)))
      .toList();

      if (matches.length == dataToBeCalculated.length) {
        // if all data is available, return the data
        return matches;
      }

      for (DailySurplusData data in matches) {
        // remove existing data from calculation
        dataToBeCalculated.removeWhere((element) => element.date.isAtSameMomentAs(data.date));
      }
    }

    //// calculate the data
    _transactions
        // where transaction date is before or same as endDate
        .where((element) => !(getOnlyDate(element.date).isAfter(endDate)))
        .forEach((element) {
          DateTime transactionDate = getOnlyDate(element.date);
          double amount = element.isExpense ? -element.amount : element.amount;
          for (DailySurplusData data in dataToBeCalculated) {
            if (transactionDate.isAfter(endDate)) {
              // if transaction date is after endDate, break
              break;
            } else if (!transactionDate.isAfter(data.date)) {
              // if transaction date is before or same as data date
              data.addSurplus(amount);
            }
          }
        });
    
    //// add calculated data to _dailySurplusData
    for (DailySurplusData data in dataToBeCalculated) {
      _dailySurplusData.add(data);
    }
    _dailySurplusData.sort((a, b) => a.date.compareTo(b.date));
    int index = _dailySurplusData.indexWhere((element) => element.date.isAtSameMomentAs(startDate));

    return _dailySurplusData.sublist(index, index + days + 1);
  }

  List<TrackerOverviewData> getTrackerOverviewData({int monthCount = 5}) {
    List<TrackerOverviewData> lineData = [];
    final month = DateTime.now().month;
    for (int i = month - (monthCount - 1) - 1; i < month; i++) {
      lineData.add(TrackerOverviewData(Constant.monthLabels[i], 0, 0, 0));
    }
    int monthIndex = 0;

    for (TrackerTransaction transaction in _transactions) {
      monthIndex = transaction.date.month - (month - (monthCount - 1));
      if (monthIndex >= 0) {
        if (Constant.analyticsCategories.contains(transaction.category)) {
          if (transaction.isExpense) {
            lineData[monthIndex].addExpense(transaction.amount);
          } else {
            lineData[monthIndex].addIncome(transaction.amount);
          }
        } else if (transaction.category == "Savings Goal") {
          lineData[monthIndex].addSavingsGoal(transaction.amount);
        }
      }
    }

    return lineData;
  }
}
