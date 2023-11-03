import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../firebase_instance.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  User _user = FirebaseInstance.auth.currentUser!;
  String _profileImage = '';
  String _name = '';
  String _email = '';

  UserProvider() {
    init();
  }

  User get user => _user;
  String get name => _name;
  String get email => _email;
  String get profileImage => _profileImage;

  Future<void> init() async {
    _user = FirebaseInstance.auth.currentUser!;
    _name = _user.displayName!;
    _email = _user.email!;
    _profileImage = await UserService.getProfileImage();
    notifyListeners();
  }

  Future<void> reload() async {
    await _user.reload();
    notifyListeners();
  }

  Future<void> updateName(String displayName) async {
    await UserService.updateName(displayName);
    _name = displayName;
    await reload();
  }

  Future<void> updateEmail(String email) async {
    await UserService.updateEmail(email);
    _email = email;
    await reload();
  }

  Future<void> updateProfileImage(String url) async {
    _profileImage = url;
    await reload();
  }

  void signOut() {
    _name = '';
    _email = '';
    _profileImage = '';
    notifyListeners();
  }
}
