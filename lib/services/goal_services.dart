import 'package:financial_app/firebaseInstance.dart';

class GoalService {
  static void removeAllPin() async {
    await FirebaseInstance.firestore
      .collection('goals')
      .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
      .where('pinned', isEqualTo: true)
      .get()
      .then((value) => {
        for (var goal in value.docs) {
          FirebaseInstance.firestore
              .collection('goals')
              .doc(goal.id)
              .update({'pinned': false}),
        }
      });
  }
}