import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../firebase_instance.dart';
import '../providers/total_goal_provider.dart';
import '../providers/total_transaction_provider.dart';
import '../providers/user_provider.dart';

class Auth {
  static void login(email, password, BuildContext context) async {
    try {
      await FirebaseInstance.auth
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((_) {
        Provider.of<UserProvider>(context, listen: false).init();
        Provider.of<TotalTransactionProvider>(context, listen: false)
            .updateTransactions();
        Provider.of<TotalGoalProvider>(context, listen: false).updateGoals();
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      });
    } on FirebaseAuthException catch (e) {
      String msg = e.message!;
      if (e.code == 'user-not-found') {
        msg = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        msg = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        msg = 'Invalid email address.';
      }
      SnackBar snackBar = SnackBar(content: Text(msg));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  static void signup(email, password, name, BuildContext context) async {
    try {
      await FirebaseInstance.auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((userCredential) async {
        userCredential.user!.updateDisplayName(name);
        await userCredential.user!.sendEmailVerification().whenComplete(() {
          AlertDialog alert = AlertDialog(
            title: const Text("Email Verification"),
            content: const Text(
                "A verification email has been sent to your email address."),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/home', (route) => false);
                },
              ),
            ],
          );
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        });
      });
    } on FirebaseAuthException catch (e) {
      String msg = e.message!;
      if (e.code == 'invalid-email') {
        msg = 'Invalid email address.';
      }
      SnackBar snackBar = SnackBar(content: Text('${e.code}: $msg'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  static void signout(BuildContext context) async {
    await FirebaseInstance.auth.signOut().then((_) {
      Provider.of<UserProvider>(context, listen: false).signOut();
      Provider.of<TotalTransactionProvider>(context, listen: false).reset();
      Provider.of<TotalGoalProvider>(context, listen: false).reset();
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    });
  }

  static Future<void> resetPassword(email) async {
    return await FirebaseInstance.auth.sendPasswordResetEmail(email: email);
  }
}
