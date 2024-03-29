import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../constants/message_constant.dart';
import '../firebase_instance.dart';
import '../components/alert_confirm_action.dart';
import '../constants/route_name.dart';
import '../services/budget_service.dart';
import '../providers/goal_provider.dart';
import '../providers/home_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/user_provider.dart';
import '../providers/split_money_provider.dart';

class Auth {
  static void _navigateToHome(BuildContext context) {
    Provider.of<UserProvider>(context, listen: false).init();
    Provider.of<TransactionProvider>(context, listen: false).init();
    Provider.of<GoalProvider>(context, listen: false).init();
    Provider.of<SplitMoneyProvider>(context, listen: false).init();
    Provider.of<HomeProvider>(context, listen: false).init();
    Provider.of<NotificationProvider>(context, listen: false).init();
    Navigator.pushNamedAndRemoveUntil(context, RouteName.home, (route) => false);
  }

  static Future<void> login(email, password, BuildContext context) async {
    try {
      await FirebaseInstance.auth
          .signInWithEmailAndPassword(
            email: email,
            password: password,
          )
          .then((_) => _navigateToHome(context));
    } on FirebaseAuthException catch (e) {
      String msg = e.message!;
      if (e.code == AuthExceptionMessage.userNotFound.getCode) {
        msg = AuthExceptionMessage.userNotFound.getMessage;
      } else if (e.code == AuthExceptionMessage.wrongPassword.getCode) {
        msg = AuthExceptionMessage.wrongPassword.getMessage;
      } else if (e.code == AuthExceptionMessage.invalidEmail.getCode) {
        msg = AuthExceptionMessage.invalidEmail.getMessage;
      }
      if (context.mounted) {
        SnackBar snackBar = SnackBar(content: Text(msg));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  static Future<void> signup(email, password, name, BuildContext context) async {
    try {
      await FirebaseInstance.auth
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          )
          .then((userCredential) async {
            await userCredential.user!.updateDisplayName(name);
            await logToFirestore();
            await userCredential.user!.sendEmailVerification().then((_) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertConfirmAction(
                    title: 'Email Verification',
                    content: 'A verification email has been sent to your email address',
                    confirmText: 'OK',
                    confirmAction: () => _navigateToHome(context),
                  );
                },
              ).then((_) => _navigateToHome(context));
            });
          });
    } on FirebaseAuthException catch (e) {
      String msg = e.message!;
      if (e.code == AuthExceptionMessage.invalidEmail.getCode) {
        msg = AuthExceptionMessage.invalidEmail.getMessage;
      }
      if (context.mounted) {
        SnackBar snackBar = SnackBar(content: Text(msg));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  static Future<void> signout(BuildContext context) async {
    // await removeFcmToken();
    await BudgetService.resetDocumentID();
    await FirebaseInstance.auth.signOut().then((_) {
      Provider.of<NavigationProvider>(context, listen: false).reset();
      Provider.of<UserProvider>(context, listen: false).signOut();
      Provider.of<TransactionProvider>(context, listen: false).reset();
      Provider.of<GoalProvider>(context, listen: false).reset();
      Provider.of<SplitMoneyProvider>(context, listen: false).reset();
      Provider.of<HomeProvider>(context, listen: false).reset();
      Provider.of<NotificationProvider>(context, listen: false).reset();
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    });
  }

  static Future<void> resetPassword(email) async {
    return await FirebaseInstance.auth.sendPasswordResetEmail(email: email);
  }

  static Future<void> logToFirestore() async {
    await FirebaseInstance.firestore
        .collection('users')
        .doc(FirebaseInstance.auth.currentUser!.uid)
        .set({
          'name': FirebaseInstance.auth.currentUser!.displayName,
          'email': FirebaseInstance.auth.currentUser!.email,
        });
  }

  static Future<void> logFcmToken() async {
    try {
      // get device fcm token
      String? fcmToken;
      await FirebaseInstance.messaging.requestPermission();
      if (kIsWeb) {
        String vapidKey = "BHlmM1MpyxeVW5_m40XsPiHhytcP9HBaQvkQv1B2f8kLDSezt4eKCkSZFsyDqgDCz3WU8P_G_7Vw3yv58dYNgkM";
        fcmToken = await FirebaseInstance.messaging.getToken(vapidKey: vapidKey);
      } else {
        fcmToken = await FirebaseInstance.messaging.getToken();
      }
      if (fcmToken == null) {
        throw Exception('Failed to get token');
      }

      // add into firestore
      String uid = FirebaseInstance.auth.currentUser!.uid;
      await FirebaseInstance.firestore
          .collection('users')
          .doc(uid)
          .get()
          .then((doc) async {
            if (doc.exists) {
              List<dynamic>? tokens = doc.data()!['fcmTokens'];
              if (tokens == null) {
                await FirebaseInstance.firestore
                    .collection('users')
                    .doc(uid)
                    .update({'fcmTokens': [fcmToken]});
              } else if (!tokens.contains(fcmToken)) {
                tokens.add(fcmToken!);
                await FirebaseInstance.firestore
                    .collection('users')
                    .doc(uid)
                    .update({'fcmTokens': tokens});
              }
            }
          });
    } catch (e) {
      debugPrint("Error on logFcmToken: $e");
    }
  }

  static Future<void> removeFcmToken() async {
    try {
      // get device fcm token
      await FirebaseInstance.messaging.requestPermission();
      String? fcmToken;
      if (kIsWeb) {
        fcmToken = await FirebaseInstance.messaging.getToken(vapidKey: "BHlmM1MpyxeVW5_m40XsPiHhytcP9HBaQvkQv1B2f8kLDSezt4eKCkSZFsyDqgDCz3WU8P_G_7Vw3yv58dYNgkM");
      } else {
        fcmToken = await FirebaseInstance.messaging.getToken();
      }
      if (fcmToken == null) {
        throw Exception('Failed to get token');
      }

      // remove from firestore
      String uid = FirebaseInstance.auth.currentUser!.uid;
      await FirebaseInstance.firestore
          .collection('users')
          .doc(uid)
          .get()
          .then((doc) async {
            if (doc.exists) {
              List<dynamic>? tokens = doc.data()!['fcmTokens'];
              if (tokens != null && tokens.contains(fcmToken)) {
                tokens.remove(fcmToken);
                await FirebaseInstance.firestore
                    .collection('users')
                    .doc(uid)
                    .update({'fcmTokens': tokens});
              }
            }
          });
    } catch (e) {
      debugPrint("Error on removeFcmToken: $e");
    }
  }
}