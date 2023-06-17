import 'package:financial_app/firebaseInstance.dart';

class GoalService {
  static void setPinned(targetID, pinned) async {
    await FirebaseInstance.firestore
      .collection('goals')
      .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
      .get()
      .then((goals) {
        for (var goal in goals.docs) {
          if (goal.id == targetID) {
            FirebaseInstance.firestore
              .collection('goals')
              .doc(goal.id)
              .update({'pinned': pinned});
          } else {
            FirebaseInstance.firestore
              .collection('goals')
              .doc(goal.id)
              .update({'pinned': false});
          }
        }
      });
  }
}