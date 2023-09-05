import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_instance.dart';
import '../constants/constant.dart';
import '../components/tracker_transaction.dart';
import '../components/expense_income_graph.dart';
import '../components/auto_dis_chart.dart';

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

  static Future<DocumentReference> addTransaction(newTransaction) async {
    return await transactionCollection.add(newTransaction.toCollection());
  }

  static Future<void> updateTransaction(
      TrackerTransaction editedTransaction) async {
    return await transactionCollection
        .doc(editedTransaction.id)
        .update(editedTransaction.toCollection());
  }

  static Future<void> deleteTransaction(transactionId) async {
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
    
    if (FirebaseInstance.auth.currentUser == null) { return lineData; }
    
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
}
