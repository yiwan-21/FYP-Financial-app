import 'package:flutter/material.dart';
import '../firebase_instance.dart';

class UserService {
  static Future<void> updateName(String displayName) async {
    await FirebaseInstance.auth.currentUser!.updateDisplayName(displayName);
  }

  static Future<void> updateEmail(String email) async {
    await FirebaseInstance.auth.currentUser!.updateEmail(email);
  }

  static Future<String> getProfileImage() async {
    final ref = FirebaseInstance.storage
        .ref("profile/${FirebaseInstance.auth.currentUser!.uid}");
    try {
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Error on getting profile image: $e');
      return '';
    }
  }

  static Future<String> getNameByID(String id) async {
    try {
      return await FirebaseInstance.firestore.collection('users')
          .doc(id)
          .get()
          .then((doc) => doc['name']);
    } catch (e) {
      debugPrint('Error on getting name by ID: $e');
      return '';
    }
  }
}
