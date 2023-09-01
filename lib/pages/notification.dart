import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/notifications.dart';
import '../services/notification_service.dart';

class NotificationMenu extends StatefulWidget {
  const NotificationMenu({super.key});

  @override
  State<NotificationMenu> createState() => _NotificationMenuState();
}

class _NotificationMenuState extends State<NotificationMenu> {
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
            icon: const Icon(Icons.notifications),
            itemBuilder: (context) {
              return [
                PopupMenuItem<NotificationModel>(
                  enabled: false,
                  child: ListTile(
                    title: Text(
                      notifications.isNotEmpty ? 'Notifications' : 'No notification yet.',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                
                ...notifications.map((doc) {
                  final String type = doc['type'];
                  final DateTime date = doc['createdAt'].toDate();
                  final bool read = doc['read'];
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
                      color: notification.read ? Colors.white : Colors.grey[100],
                      child: ListTile(
                        title: Text(notification.title),
                        subtitle: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                notification.message,
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              notification.date.toString().substring(11, 16),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
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

