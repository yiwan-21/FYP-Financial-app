import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_instance.dart';

class BillService {
  static CollectionReference billsCollection =
      FirebaseInstance.firestore.collection('bills');

  static Stream<QuerySnapshot> getBillStream(){
    return billsCollection
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .snapshots();
  }

  static Future<void> addBill(String title, double amount, DateTime dueDate, bool fixed) async {
    await billsCollection.add({
      'userID': FirebaseInstance.auth.currentUser!.uid,
      'title': title,
      'amount': amount,
      'dueDate': dueDate,
      'fixed': fixed,
      'paid': false,
      'history': {},
    });
  }

  // scenario
  // not paid, edit bill amount
  // paid, edit bill amount
  static Future<void> editBill(String id, String title, double amount, DateTime dueDate, bool fixed) async {
    await billsCollection.doc(id).update({
      'title': title,
      'amount': amount,
      'dueDate': dueDate,
      'fixed': fixed,
    });
  }

  static Future<void> payBill(String id, double amount, bool fixed) async {
    await billsCollection
        .doc(id)
        .get()
        .then((snapshot) async {
          if (snapshot.exists) {
            // Map<Timestamp, double> history = Map<Timestamp, double>.from(snapshot['history']);
            // if (history.length == 2) {
            //   DateTime date1 = history.keys.first.toDate();
            //   DateTime date2 = history.keys.last.toDate();
            //   if (date1.isBefore(date2)) {
            //     history.remove(date1);
            //   } else {
            //     history.remove(date2);
            //   }
            // }
            // history[Timestamp.fromDate(DateTime.now())] = amount;
            await billsCollection.doc(id).update({
              'paid': true,
              // 'history': history,
              'amount': fixed ? snapshot['amount'] : amount,
            });
          }
        });
  }

  static Future<void> deleteBill(String id) async {
    await billsCollection.doc(id).delete();
  }
}
