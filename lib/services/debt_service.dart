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

  //TODO: Add date to addDebt and editDebt
  static Future<void> addDebt(
      String title, int duration, double amount, double interests) async {
    await debtsCollection.add({
      'userID': FirebaseInstance.auth.currentUser!.uid,
      'title': title,
      'duration': duration,
      'amount': amount,
      'interest': interests,
      'history': [],
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
    //TODO: Move to loan amortization logic
    await debtsCollection.doc(id).get().then((snapshot) async {
      if (snapshot.exists) {
        List<Map<String, dynamic>> history =
            List<Map<String, dynamic>>.from(snapshot['history']);
        double balance;
        if (history.length == 6) {
          history.removeAt(0);
        }
        if (history.isEmpty) {
          balance = snapshot['amount'].toDouble() - savedAmount;
        } else {
          balance = history.last['balance'].toDouble() - savedAmount;
        }
        history.add({
          'date': getOnlyDate(DateTime.now()),
          'saved': savedAmount,
          'balance': balance,
        });

        await debtsCollection.doc(id).update({
          'history': history,
        });
      }
    });
  }
}
