import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/home_constant.dart';
import '../firebase_instance.dart';
import '../models/home_customization.dart';

class HomeService {
  static CollectionReference get homeCollection =>
      FirebaseInstance.firestore.collection('homes');

  static Future<HomeCustomization> getHomeItems() async {
    return await homeCollection
        .doc(FirebaseInstance.auth.currentUser!.uid)
        .get()
        .then((snapshot) async {
          if (snapshot.exists) {
            return HomeCustomization.fromDocument(snapshot);
          } else {
            return await initHomeItems().then((items) {
              return HomeCustomization(
                items: items,
                groupID: '',
                budgetCategory: '',
              );
            });
          }
        });
  }

  static Future<List<String>> initHomeItems() async {
    List<String> defaultItems = HomeConstant.homeItems.take(2).toList();
    await homeCollection
        .doc(FirebaseInstance.auth.currentUser!.uid)
        .set({'items': defaultItems});
    return defaultItems;
  }

  static Future<void> updateHomeItems(List<String> items, String groupID, String budgetCategory) async {
    await homeCollection
        .doc(FirebaseInstance.auth.currentUser!.uid)
        .update({
          'items': items,
          'groupID': groupID,
          'budgetCategory': budgetCategory,
        });
  }
}
