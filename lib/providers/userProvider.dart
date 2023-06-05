import 'package:financial_app/firebaseInstance.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final User _user = FirebaseInstance.auth.currentUser!;
  String _name = '';
  String _email = '';

  UserProvider() {
    _name = _user.displayName!;
    _email = _user.email!;
  }

  User get user => _user;
  String get name => _name;
  String get email => _email;

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
  
  Future<void> signOut() async {
    await FirebaseInstance.auth.signOut();
    notifyListeners();
  }
}