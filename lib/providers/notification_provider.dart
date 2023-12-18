import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/notification_item.dart';
import '../services/chat_service.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  StreamSubscription? _notificationSubscription;
  final List<NotificationItem> _notifications = [];
  int _unread = 0;
  // true = has notification, false = no notification
  bool _chatNotification = false;

  List<NotificationItem> get notifications => _notifications;
  int get unread => _unread;
  bool get chatNotification => _chatNotification;

  NotificationProvider() {
    init();
  }

  void init() {
    _notificationSubscription = NotificationService.getNotificationStream().listen((event) {
      event.metadata.isFromCache
          ? print("Notification Stream: Data from local cache")
          : print("Notification Stream: Data from server");
      event.metadata.hasPendingWrites // pendingWrites ? "Local" : "Server";
          ? print("Notification Stream: There are pending writes")
          : print("Notification Stream: There are no pending writes");
      print("Notification Stream: Document changes: ${event.docChanges.length}");

      for (var change in event.docChanges) {
        if (change.type == DocumentChangeType.added) {
          // add the notification item
          NotificationItem notificationItem = NotificationItem.fromSnapshot(change.doc);
          if (!notificationItem.read) {
            _unread++;
          }
          _notifications.add(notificationItem);
          
        } else if (change.type == DocumentChangeType.modified) {
          // update the notification item
          int index = _notifications.indexWhere((element) => element.id == change.doc.id);
          NotificationItem notificationItem = NotificationItem.fromSnapshot(change.doc);
          if (!_notifications[index].read && notificationItem.read) {
            _unread--;
          }
          _notifications[index] = notificationItem;
        } else if (change.type == DocumentChangeType.removed) {
          // remove the notification item
          int index = _notifications.indexWhere((element) => element.id == change.doc.id);
          if (!_notifications[index].read) {
            _unread--;
          }
          _notifications.removeAt(index);
        }
      }
      notifyListeners();
    });
  }

  void reset() {
    _notificationSubscription?.cancel();
    _notifications.clear();
    _chatNotification = false;
  }

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
