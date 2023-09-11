import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/history_card.dart';
import '../firebase_instance.dart';
import '../constants/constant.dart';
import '../components/tracker_transaction.dart';
import '../components/expense_income_graph.dart';
import '../components/auto_dis_chart.dart';
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
    await transactionCollection.add(
      {...newTransaction.toCollection(), 'userID': FirebaseInstance.auth.currentUser!.uid}
        );

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
    await transactionCollection
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

  static Future<List<IncomeExpenseData>> getLineData() async {
    const int monthCount = 5;
    final List<IncomeExpenseData> lineData = [];
    // fill lineData with IncomeExpenseData objects
    final month = DateTime.now().month;
    for (int i = month - (monthCount - 1) - 1; i < month; i++) {
      lineData.add(IncomeExpenseData(Constant.monthLabels[i], 0, 0));
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
              for (var transaction in value.docs)
                {
                  monthIndex =
                      DateTime.parse(transaction['date'].toDate().toString())
                              .month -
                          (DateTime.now().month - (monthCount - 1)),
                  if (monthIndex >= 0)
                    {
                      if (transaction['isExpense'])
                        {
                          lineData[monthIndex]
                              .addExpense(transaction['amount'].toDouble())
                        }
                      else
                        {
                          lineData[monthIndex]
                              .addIncome(transaction['amount'].toDouble())
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
    await transactionCollection
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .orderBy('date', descending: true)
        .get()
        .then((value) => {
              for (var transaction in value.docs)
                {
                  monthIndex =
                      DateTime.parse(transaction['date'].toDate().toString())
                              .month -
                          (DateTime.now().month - (monthCount - 1)),
                  if (monthIndex >= 0 && transaction['isExpense'])
                    {
                      if (autonomous.contains(transaction['category']))
                        {
                          barData[monthIndex]
                              .addAutonomous(transaction['amount'].toDouble())
                        }
                      else
                        {
                          barData[monthIndex].addDiscretionary(
                              transaction['amount'].toDouble())
                        }
                    }
                }
            });
    return barData;
  }

  // Budgeting
  static Future<double> getExpenseByCategory(String category, DateTime startingDate) async {
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
  
  static Future<List<HistoryCard>> getHistoryCards(String category, DateTime startingDate) async {
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
}
