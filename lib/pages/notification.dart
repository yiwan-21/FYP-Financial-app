import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/constant.dart';
import '../firebase_instance.dart';
import '../models/notifications.dart';
import '../services/goal_service.dart';
import '../services/notification_service.dart';

class NotificationMenu extends StatefulWidget {
  const NotificationMenu({super.key});

  @override
  State<NotificationMenu> createState() => _NotificationMenuState();
}

class _NotificationMenuState extends State<NotificationMenu> {
  @override
  void initState() {
    super.initState();
    NotificationService.cronJobDeletion();
    GoalService.expiringGoalNotification();
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
          final List<QueryDocumentSnapshot> notifications = snapshot.data == null ? [] : snapshot.data!.docs;
          return PopupMenuButton<NotificationModel>(
            position: PopupMenuPosition.under,
            offset: const Offset(30, 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            elevation: 5,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
              maxWidth: 300,
            ),
            icon: const Icon(Icons.notifications),
            itemBuilder: (context) {
              return [
                PopupMenuItem<NotificationModel>(
                  enabled: false,
                  child: ListTile(
                    title: Text(
                      notifications.isNotEmpty ? 'Notifications' : 'No notification yet.',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                ...notifications.map((doc) {
                  final String type = doc['type'];
                  final DateTime date = doc['createdAt'].toDate();
                  final int index = List<String>.from(doc['receiverID']).indexOf(FirebaseInstance.auth.currentUser!.uid);
                  final bool read = List<bool>.from(doc['read'])[index];
                  final String? functionID = doc['functionID'];
                  final notification = NotificationService.getNotificationModel(type, date, read, functionID: functionID);
                  
                  if (notification == null) {
                    return PopupMenuItem<NotificationModel>(
                      value: null,
                      child: Container(),
                    );
                  }

                  return PopupMenuItem<NotificationModel>(
                    onTap: () {
                      NotificationService.markAsRead(doc.id);
                      notification.navigateTo();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      color: notification.read ? Colors.white : Colors.grey[100],
                      child: ListTile(
                        title: Text(notification.title),
                        titleTextStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                        ),
                        subtitle: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                notification.message,
                                textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
                        subtitleTextStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${Constant.monthLabels[notification.date.month - 1]} ${notification.date.day}'),
                            const SizedBox(height: 5),
                            Text(notification.date.toString().substring(11, 16)),
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

