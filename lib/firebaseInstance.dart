import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class FirebaseInstance {
  static final firebase_auth.FirebaseAuth auth = firebase_auth.FirebaseAuth.instance;

}