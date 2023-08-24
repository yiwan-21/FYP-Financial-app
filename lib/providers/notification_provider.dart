import 'package:financial_app/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'navigation_provider.dart';
import '../models/noti.dart';
import '../constants/route_name.dart';
import '../services/chat_service.dart';

class NotificationProvider extends ChangeNotifier {
  // true = has notification, false = no notification
  bool _chatNotification = false;
  final List<NotificationModel> _notifications = [
      NotificationModel(
        'New Expense',
        'You have a new expense.',
        DateTime.now(),
        false,
        () {
          // TODO: need to get and pass Expense ID in the arguments
          navigatorKey.currentState!.pushNamed(RouteName.splitMoneyExpense, arguments: {'id': 'id'});
        },
      ),
      NotificationModel(
        'Goal Progress',
        'Your goal is 50% completed.',
        DateTime.now(),
        false,
        () {
          // TODO: need to get and set GoalProvider information
          navigatorKey.currentState!.pushNamed(RouteName.goalProgress);
        },
      ),
      NotificationModel(
        'Notification 3',
        'This is the third notification. This is the third notification. This is the third notification. This is the third notification. This is the third notification.',
        DateTime.now(),
        false,
        () {},
      ),
      NotificationModel(
        'New Group',
        'You have been added to a new group.',
        DateTime.now(),
        false,
        () {
          Provider.of<NavigationProvider>(navigatorKey.currentContext!, listen: false).setCurrentIndex(3);
        },
      ),
      NotificationModel(
        'Home',
        'Go to home page.',
        DateTime.now(),
        false,
        () {
          // TODO: can set constant for index
          // TODO: stream builder will stuck in loading
          Provider.of<NavigationProvider>(navigatorKey.currentContext!, listen: false).setCurrentIndex(0);
          navigatorKey.currentState!.pushNamed(RouteName.home);
        },
      ),
    ];

  bool get chatNotification => _chatNotification;
  List<NotificationModel> get notifications => _notifications;

  void setChatNotification(bool value, NotificationModel? noti) {
    _chatNotification = value;
    if (value && noti != null) {
      _notifications.add(noti);
    }
    notifyListeners();
  }

  Future<void> getCurrentChatNotification() async {
    // get from database
    await ChatService.hasRead().then((value) {
      // hasRead (true) = no chatNotification (false)
      _chatNotification = !value;
    });
    notifyListeners();
  }

  void clearChatNotification() {
    _chatNotification = false;
    _notifications.clear();
    notifyListeners();
  }
}
