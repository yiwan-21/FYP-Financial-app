import '../firebase_instance.dart';
import '../components/transaction.dart';

class TransactionService {
  Future<dynamic> addTransaction(newTransaction) async {
    return await FirebaseInstance.firestore
      .collection("transactions")
      .add(newTransaction.toCollection());
  }

  Future<void> updateTransaction(TrackerTransaction editedTransaction) async {
    return await FirebaseInstance.firestore
      .collection("transactions")
      .doc(editedTransaction.id)
      .update(editedTransaction.toCollection());
  }

  Future<void> deleteTransaction(transactionId) async {
    return await FirebaseInstance.firestore
      .collection("transactions")
      .doc(transactionId)
      .delete();
  }

  Future<List<TrackerTransaction>> getRecentTransactions() async {
    final List<TrackerTransaction> transactions = [];
    await FirebaseInstance.firestore
        .collection('transactions')
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .orderBy('date', descending: true)
        .limit(3)
        .get()
        .then((event) {
      for (var transaction in event.docs) {
        transactions.add(TrackerTransaction(
          transaction.id,
          transaction['userID'],
          transaction['title'],
          transaction['amount'].toDouble(),
          transaction['date'].toDate(),
          transaction['isExpense'],
          transaction['category'],
          notes: transaction['notes'],
        ));
      }
    });
    return transactions;
  }

  Future<List<TrackerTransaction>> getAllTransactions() async {
    final List<TrackerTransaction> transactionData = [];
    await FirebaseInstance.firestore
        .collection('transactions')
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .orderBy('date', descending: false)
        .get()
        .then((event) {
      for (var transaction in event.docs) {
        transactionData.add(TrackerTransaction(
          transaction.id,
          transaction['userID'],
          transaction['title'],
          transaction['amount'].toDouble(),
          transaction['date'].toDate(),
          transaction['isExpense'],
          transaction['category'],
          notes: transaction['notes'],
        ));
      }
    });
    return transactionData;
  }

  Future<Map<String, double>> getPieChartData() async {
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
}
