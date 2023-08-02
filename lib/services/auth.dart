import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../constants/message_constant.dart';
import '../firebase_instance.dart';
import '../components/alert_confirm_action.dart';
import '../providers/total_goal_provider.dart';
import '../providers/total_split_money_provider.dart';
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
            Provider.of<TotalTransactionProvider>(context, listen: false).updateTransactions();
            Provider.of<TotalGoalProvider>(context, listen: false).updateGoals();
            Provider.of<TotalSplitMoneyProvider>(context, listen:false).updateGroups();
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          });
    } on FirebaseAuthException catch (e) {
      String msg = e.message!;
      if (e.code == AuthExceptionMessage.userNotFound.getCode) {
        msg = AuthExceptionMessage.userNotFound.getMessage;
      } else if (e.code == AuthExceptionMessage.wrongPassword.getCode) {
        msg = AuthExceptionMessage.wrongPassword.getMessage;
      } else if (e.code == AuthExceptionMessage.invalidEmail.getCode) {
        msg = AuthExceptionMessage.invalidEmail.getMessage;
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
            logToFirestore();
            await userCredential.user!.sendEmailVerification().whenComplete(() {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertConfirmAction(
                    title: 'Email Verification',
                    content: 'A verification email has been sent to your email address',
                    confirmText: 'OK',
                    confirmAction: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                    },
                  );
                },
              );
            });
          });
    } on FirebaseAuthException catch (e) {
      String msg = e.message!;
      if (e.code == AuthExceptionMessage.invalidEmail.getCode) {
        msg = AuthExceptionMessage.invalidEmail.getMessage;
      }
      SnackBar snackBar = SnackBar(content: Text(msg));
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

  static void logToFirestore() async {
    await FirebaseInstance.firestore
        .collection('users')
        .doc(FirebaseInstance.auth.currentUser!.uid)
        .set({
          'name': FirebaseInstance.auth.currentUser!.displayName,
          'email': FirebaseInstance.auth.currentUser!.email,
        });
  }
}