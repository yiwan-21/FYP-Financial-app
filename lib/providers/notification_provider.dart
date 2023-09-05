import 'package:flutter/material.dart';

import '../services/chat_service.dart';

class NotificationProvider extends ChangeNotifier {
  // true = has notification, false = no notification
  bool _chatNotification = false;

  bool get chatNotification => _chatNotification;

  void setChatNotification(bool value) {
    _chatNotification = value;
    notifyListeners();
  }

  Future<void> getCurrentChatNotification() async {
    // get from database
    await ChatService.hasRead().then((value) {
      _chatNotification = !value;
    });
    notifyListeners();
  }

  void clearChatNotification() {
    _chatNotification = false;
    notifyListeners();
  }
}
