import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../firebase_instance.dart';

class UserService {
  static CollectionReference get userCollection => FirebaseInstance.firestore.collection('users');

  static Future<void> updateName(String displayName) async {
    await FirebaseInstance.auth.currentUser!.updateDisplayName(displayName);
    await FirebaseInstance.firestore
        .collection('users')
        .doc(FirebaseInstance.auth.currentUser!.uid)
        .update({
          'name': displayName,
    });
  }

  static Future<void> updateEmail(String email) async {
    await FirebaseInstance.auth.currentUser!.updateEmail(email);
    await FirebaseInstance.firestore
        .collection('users')
        .doc(FirebaseInstance.auth.currentUser!.uid)
        .update({
          'email': email,
    });
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
      return await FirebaseInstance.firestore
          .collection('users')
          .doc(id)
          .get()
          .then((doc) => doc['name']);
    } catch (e) {
      debugPrint('Error on getting name by ID: $e');
      return '';
    }
  }

static Future<Map<String, dynamic>> getUserData(String uid) async {
  try {
    final userDoc = await FirebaseInstance.firestore
        .collection('users')
        .doc(uid)
        .get();

    if (userDoc.exists) {
      return userDoc.data() as Map<String, dynamic>;
    }
  } catch (e) {
    debugPrint('Error on getting user data: $e');
  }
  return {}; // Return an empty map if data is not found or error occurs
}


  static Future<String> setProfileImage(pickedImage) async {
    try {
      final storageRef = FirebaseInstance.storage
          .ref('profile/${FirebaseInstance.auth.currentUser!.uid}');
      TaskSnapshot task = kIsWeb
          ? await storageRef.putData(pickedImage)
          : await storageRef.putFile(pickedImage);
      return await task.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Error in setProfileImage: $e");
      return '';
    }
  }
}
