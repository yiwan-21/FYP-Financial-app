import 'package:financial_app/firebaseInstance.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  User _user = FirebaseInstance.auth.currentUser!;
  Future<String?> _profileImage = Future.value('');
  String _name = '';
  String _email = '';

  UserProvider() {
    _name = _user.displayName!;
    _email = _user.email!;
    _profileImage = getProfileImage();
  }

  User get user => _user;
  String get name => _name;
  String get email => _email;
  Future<String?> get profileImage => _profileImage;

  void init() {
    _user = FirebaseInstance.auth.currentUser!;
    _name = _user.displayName!;
    _email = _user.email!;
    _profileImage = getProfileImage();
    notifyListeners();
  }

  Future<void> reload() async {
    await _user.reload();
    notifyListeners();
  }

  Future<void> updateName(String displayName) async {
    await _user.updateDisplayName(displayName);
    _name = displayName;
    await reload();
  }

  Future<void> updateEmail(String email) async {
    await _user.updateEmail(email);
    _email = email;
    await reload();
  }

  Future<String?> getProfileImage() async {
    final ref = FirebaseInstance.storage
        .ref("profile/${FirebaseInstance.auth.currentUser!.uid}");
    try {
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Failed to get profile image: $e');
      return null;
    }
  }

  void updateProfileImage() async {
    _profileImage = getProfileImage();
    await reload();
  }

  Future<void> signOut() async {
    await FirebaseInstance.auth.signOut();
    _name = '';
    _email = '';
    _profileImage = Future.value(null);
    notifyListeners();
  }
}
