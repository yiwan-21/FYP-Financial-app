import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/constant.dart';
import '../firebase_instance.dart';
import '../models/notifications.dart';
import '../services/bill_service.dart';
import '../services/goal_service.dart';
import '../services/notification_service.dart';

class NotificationMenu extends StatefulWidget {
  const NotificationMenu({super.key});

  @override
  State<NotificationMenu> createState() => _NotificationMenuState();
}

class _NotificationMenuState extends State<NotificationMenu> {
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    NotificationService.cronJobDeletion();
    GoalService.expiringGoalNotification();
    BillService.resetBill().then((_) {
      BillService.billDueNotification();
    });
  }

  Future<void> _markAllAsRead() async {
    await NotificationService.markAllAsRead();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: NotificationService.getNotificationStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle loading state
            },
          );
        } else if (snapshot.hasError) {
          return IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle error state
            },
          );
        } else {
          final List<QueryDocumentSnapshot> notifications =
              snapshot.data == null ? [] : snapshot.data!.docs;
          final String uid = FirebaseInstance.auth.currentUser!.uid;
          _unread = 0;
          for (final QueryDocumentSnapshot doc in notifications) {
            final int index = List<String>.from(doc['receiverID']).indexOf(uid);
            final bool read = List<bool>.from(doc['read'])[index];
            if (!read) {
              _unread++;
            }
          }
          return PopupMenuButton<NotificationModel>(
            position: PopupMenuPosition.under,
            offset: const Offset(30, 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 5,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              maxWidth: 300,
            ),
            icon: Icon(_unread > 0 ? Icons.notifications_active : Icons.notifications),
            itemBuilder: (context) {
              return [
                PopupMenuItem<NotificationModel>(
                  enabled: false,
                  child: ListTile(
                    contentPadding: const EdgeInsets.only(left: 10),
                    title: Text(
                      notifications.isNotEmpty
                          ? 'Notifications ${_unread > 0 ? '($_unread)' : ''}'
                          : 'No notification yet.',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        // fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: _unread > 0
                        ? TextButton(
                            onPressed: _markAllAsRead,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(0),
                              alignment: Alignment.centerRight,
                            ),
                            child: const Text(
                              'Mark all as read',
                              style: TextStyle(
                                color: Colors.pink,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                ...notifications.map((doc) {
                  final String title = doc['title'];
                  final String message = doc['message'];
                  final DateTime date = doc['createdAt'].toDate();
                  final int index = List<String>.from(doc['receiverID']).indexOf(uid);
                  final bool read = List<bool>.from(doc['read'])[index];
                  final String type = doc['type'];
                  final String? functionID = doc['functionID'];
                  final Function navigateTo = NotificationService.getNotificationFunction(type, functionID);

                  return PopupMenuItem<NotificationModel>(
                    onTap: () {
                      NotificationService.markAsRead(doc.id);
                      navigateTo();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      color: read ? Colors.white : Colors.grey[100],
                      child: ListTile(
                        title: Text(title),
                        titleTextStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: read ? FontWeight.normal : FontWeight.bold,
                        ),
                        subtitle: Text(
                          message,
                          textAlign: TextAlign.justify,
                        ),
                        subtitleTextStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${Constant.monthLabels[date.month - 1]} ${date.day}'),
                            const SizedBox(height: 5),
                            Text(date.toString().substring(11, 16)),
                          ],
                        ),
                        leadingAndTrailingTextStyle: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ];
            },
          );
        }
      },
    );
  }
}
