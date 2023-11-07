import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_instance.dart';
import '../utils/date_utils.dart';

class DebtService {
  static CollectionReference debtsCollection =
      FirebaseInstance.firestore.collection('debts');

  static Stream<QuerySnapshot> getDebtStream() {
    return debtsCollection
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .snapshots();
  }

  static Future<void> addDebt(
      String title, int duration, double amount, double interests) async {
    await debtsCollection.add({
      'userID': FirebaseInstance.auth.currentUser!.uid,
      'title': title,
      'duration': duration,
      'amount': amount,
      'interest': interests,
      'history': [],
      'created_date': DateTime.now(),
    });
  }

  static Future<void> editDebt(String id, String title, int duration,
      double amount, double interests) async {
    await debtsCollection.doc(id).update({
      'title': title,
      'duration': duration,
      'amount': amount,
      'interest': interests,
    });
  }

  static Future<void> deleteDebt(String id) async {
    await debtsCollection.doc(id).delete();
  }

  static Future<void> payDebt(String id, double savedAmount) async {
    final snapshot = await debtsCollection.doc(id).get();

    if (snapshot.exists) {
      final history = List<Map<String, dynamic>>.from(snapshot['history']);
      double balance = 0;
      double principal = savedAmount;
      double interestAmount = 0;
      final interestRate = snapshot['interest'].toDouble() ?? 0.0;
      final totalAmount = snapshot['amount'].toDouble() ?? 0.0;

      if (history.length == 6) {
        history.removeAt(0);
      }


      if (history.isNotEmpty) {
        final previousBalance = history.last['balance']?.toDouble() ?? 0;
        interestAmount = interestRate > 0? previousBalance * ((interestRate / 100) / 12) : 0;
        principal = savedAmount - interestAmount;
        balance = previousBalance - principal;
      } else {
        interestAmount = interestRate > 0? totalAmount * (interestRate / 100 / 12):0;
        principal = savedAmount - interestAmount;
        balance = totalAmount - principal;
      }


      final paymentRecord = {
        'date': getOnlyDate(DateTime.now()),
        'saved': savedAmount,
        'principal': principal.toDouble(),
        'interest': interestAmount.toDouble(),
        'balance': balance.toDouble(),
      };

      history.add(paymentRecord);

      await debtsCollection.doc(id).update({
        'history': history,
      });
    }
  }
}
