import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../firebase_instance.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userServices = UserService();
  User _user = FirebaseInstance.auth.currentUser!;
  Future<String?> _profileImage = Future.value('');
  String _name = '';
  String _email = '';

  UserProvider() {
    _name = _user.displayName!;
    _email = _user.email!;
    _profileImage = _userServices.getProfileImage();
  }

  User get user => _user;
  String get name => _name;
  String get email => _email;
  Future<String?> get profileImage => _profileImage;

  void init() {
    _user = FirebaseInstance.auth.currentUser!;
    _name = _user.displayName!;
    _email = _user.email!;
    _profileImage = _userServices.getProfileImage();
    notifyListeners();
  }

  Future<void> reload() async {
    await _user.reload();
    notifyListeners();
  }

  Future<void> updateName(String displayName) async {
    await _userServices.updateName(displayName);
    _name = displayName;
    await reload();
  }

  Future<void> updateEmail(String email) async {
    await _userServices.updateEmail(email);
    _email = email;
    await reload();
  }

  void updateProfileImage() async {
    _profileImage = _userServices.getProfileImage();
    await reload();
  }

  void signOut() {
    _name = '';
    _email = '';
    _profileImage = Future.value(null);
    notifyListeners();
  }
}
