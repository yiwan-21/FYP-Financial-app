import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_instance.dart';
import '../utils/date_utils.dart';
import '../constants/constant.dart';
import '../components/history_card.dart';
import '../components/tracker_transaction.dart';
import '../components/tracker_overview_chart.dart';
import '../components/auto_dis_chart.dart';
import '../components/daily_surplus_chart.dart';
import '../services/budget_service.dart';

class TransactionService {
  static CollectionReference transactionCollection =
      FirebaseInstance.firestore.collection('transactions');

  static Stream<QuerySnapshot> getAllTransactionStream() {
    if (FirebaseInstance.auth.currentUser != null) {
      return transactionCollection
          .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
          .orderBy('date', descending: true)
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

  static Future<List<TrackerOverviewData>> getLineData() async {
    const int monthCount = 5;
    final List<TrackerOverviewData> lineData = [];
    // fill lineData with TrackerOverviewData objects
    final month = DateTime.now().month;
    for (int i = month - (monthCount - 1) - 1; i < month; i++) {
      lineData.add(TrackerOverviewData(Constant.monthLabels[i], 0, 0, 0));
    }
    int monthIndex = 0;

    if (FirebaseInstance.auth.currentUser == null) {
      return lineData;
    }
    
    await transactionCollection
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .orderBy('date', descending: true)
        .get()
        .then((value) => {
      for (var transaction in value.docs) {
        monthIndex = DateTime.parse(transaction['date'].toDate().toString()).month - (DateTime.now().month - (monthCount - 1)),
        if (monthIndex >= 0) {
          if(transaction['category'] == "Savings Goal")
          {
              lineData[monthIndex].addSavingsGoal(transaction['amount'].toDouble())
          }
          else
          {
            if (transaction['isExpense']) {
              lineData[monthIndex].addExpense(transaction['amount'].toDouble())
            } else {
              lineData[monthIndex].addIncome(transaction['amount'].toDouble())
            }
          }
        }
      }
    });
    return lineData;
  }

  static Future<List<AutoDisData>> getBarData() async {
    const int monthCount = 5;
    final List<String> autonomous = [
      'Food',
      'Transportation',
      'Rental',
      'Bill'
    ];
    final List<AutoDisData> barData = [];
    // fill barData with AutoDisData objects
    final month = DateTime.now().month;
    for (int i = month - (monthCount - 1) - 1; i < month; i++) {
      barData.add(AutoDisData(Constant.monthLabels[i], 0, 0));
    }
    int monthIndex = 0;

    List<String> categories = Constant.analyticsCategories;
    await transactionCollection
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .where('category', whereIn: categories)
        .orderBy('date', descending: true)
        .get()
        .then((value) => {
      for (var transaction in value.docs) {
        monthIndex = DateTime.parse(transaction['date'].toDate().toString()).month -
            (DateTime.now().month - (monthCount - 1)),
        if (monthIndex >= 0 && transaction['isExpense']) {
          if (autonomous.contains(transaction['category'])) {
            barData[monthIndex]
                .addAutonomous(transaction['amount'].toDouble())
          } else {
            barData[monthIndex].addDiscretionary(
                transaction['amount'].toDouble())
          }
        }
      }
    });
    return barData;
  }

static Future<List<DailySurplusData>> getSplineData() async {
  final List<DailySurplusData> splineData = [];

  final DateTime displayDays = DateTime.now().subtract(const Duration(days: 6));
  final DateTime startOfDay = DateTime(displayDays.year, displayDays.month, displayDays.day);

  // fill SplineData with DailySurplusData objects
  for (int i = 0; i < 7; i++) {
    splineData.add(DailySurplusData(displayDays.add(Duration(days: i)), 0));
  }

  await transactionCollection
      .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
      .where('date', isGreaterThanOrEqualTo: startOfDay)
      .get()
      .then((snapshot) {
    if (snapshot.docs.isNotEmpty) {
      for (var transaction in snapshot.docs) {
        final DateTime transactionDate = transaction['date'].toDate();
        final double surplus = transaction['isExpense']
            ? -transaction['amount'].toDouble()
            : transaction['amount'].toDouble();

        int existingIndex = splineData.indexWhere((data) => getOnlyDate(data.date).isAtSameMomentAs(getOnlyDate(transactionDate)));

        if (existingIndex != -1) {
          splineData[existingIndex].addSurplus(surplus);
        }
      }
    }
  });

  return splineData;
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
          'amount': surplus,
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
