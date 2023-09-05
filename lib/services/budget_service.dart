import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/components/budget_card.dart';

import '../firebase_instance.dart';

class BudgetService {
  static CollectionReference budgetsCollection =
      FirebaseInstance.firestore.collection('budgets');

  static Stream<QuerySnapshot> getBudgetingStream() {
    if (FirebaseInstance.auth.currentUser == null) {
      return const Stream.empty();
    }

    return budgetsCollection
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .orderBy('createdAt')
        .snapshots();
  }

  static Future<void> addBudget(BudgetCard budget) async {
    await budgetsCollection.add({
      'userID': FirebaseInstance.auth.currentUser!.uid,
      'category': budget.category,
      'amount': budget.amount,
      'usedAmount': budget.usedAmount,
    });
  }
  
  //get from tracker for history
  static Future<void> updateBudget() async{}

  static Future<void> deleteBudget() async{}
}
