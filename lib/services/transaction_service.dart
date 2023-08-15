import '../firebase_instance.dart';
import '../constants/constant.dart';
import '../components/tracker_transaction.dart';
import '../components/expense_income_graph.dart';
import '../components/auto_dis_chart.dart';

class TransactionService {
  static Future<dynamic> addTransaction(newTransaction) async {
    return await FirebaseInstance.firestore
      .collection("transactions")
      .add(newTransaction.toCollection());
  }

  static Future<void> updateTransaction(TrackerTransaction editedTransaction) async {
    return await FirebaseInstance.firestore
      .collection("transactions")
      .doc(editedTransaction.id)
      .update(editedTransaction.toCollection());
  }

  static Future<void> deleteTransaction(transactionId) async {
    return await FirebaseInstance.firestore
      .collection("transactions")
      .doc(transactionId)
      .delete();
  }

  static Future<List<TrackerTransaction>> getAllTransactions() async {
    final List<TrackerTransaction> transactionData = [];
    await FirebaseInstance.firestore
        .collection('transactions')
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .orderBy('date', descending: false)
        .get().then((event) {
      for (var transaction in event.docs) {
        transactionData.add(TrackerTransaction(
          id: transaction.id,
          userID: transaction['userID'],
          title: transaction['title'],
          amount: transaction['amount'].toDouble(),
          date: transaction['date'].toDate(),
          isExpense: transaction['isExpense'],
          category: transaction['category'],
          notes: transaction['notes'],
        ));
      }
    });
    return transactionData;
  }

  static Future<Map<String, double>> getPieChartData() async {
    Map<String, double> data = {};
    await FirebaseInstance.firestore
        .collection('transactions')
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
    await FirebaseInstance.firestore.collection('transactions')
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .orderBy('date', descending: true)
        .get()
        .then((value) => {
          for (var transaction in value.docs) {
            monthIndex = DateTime.parse(transaction['date'].toDate().toString()).month - (DateTime.now().month - (monthCount - 1)),
            if (monthIndex >= 0) {
              if (transaction['isExpense']) {
                lineData[monthIndex].addExpense(transaction['amount'].toDouble())
              } else {
                lineData[monthIndex].addIncome(transaction['amount'].toDouble())
              }
            }
          }
        });
    return lineData;
  }


  static Future<List<AutoDisData>> getBarData() async {
    const int monthCount = 5;
    final List<String> autonomous = ['Food', 'Transportation', 'Rental', 'Bill'];
    final List<AutoDisData> barData = [];
    // fill barData with AutoDisData objects
    final month = DateTime.now().month;
    for (int i = month - (monthCount - 1) - 1; i < month; i++) {
      barData.add(AutoDisData(Constant.monthLabels[i], 0, 0));
    }
    int monthIndex = 0;
    await FirebaseInstance.firestore.collection('transactions')
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .orderBy('date', descending: true)
        .get()
        .then((value) => {
          for (var transaction in value.docs) {
             monthIndex = DateTime.parse(transaction['date'].toDate().toString()).month - (DateTime.now().month - (monthCount - 1)),
            if (monthIndex >= 0 && transaction['isExpense']) {
              if (autonomous.contains(transaction['category'])) {
                barData[monthIndex].addAutonomous(transaction['amount'].toDouble())
              } else {
                barData[monthIndex].addDiscretionary(transaction['amount'].toDouble())
              }
            }
          }
        });
    return barData;
  }
}
