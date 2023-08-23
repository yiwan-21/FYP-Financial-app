import 'package:flutter/material.dart';

import '../models/noti.dart';

class NotificationMenu extends StatefulWidget {
  const NotificationMenu({super.key});

  @override
  State<NotificationMenu> createState() => _NotificationMenuState();
}

class _NotificationMenuState extends State<NotificationMenu> {
  void _showNotificationMenu(BuildContext context) async {
    final notifications = [
      NotificationModel(
        'Notification 1',
        'This is the first notification.',
        DateTime.now(),
        false,
      ),
      NotificationModel(
        'Notification 2',
        'This is the second notification.',
        DateTime.now(),
        false,
      ),
      NotificationModel(
        'Notification 3',
        'This is the third notification. This is the third notification. This is the third notification. This is the third notification. This is the third notification.',
        DateTime.now(),
        true,
      ),
      NotificationModel(
        'Notification 4',
        'This is the forth notification.',
        DateTime.now(),
        true,
      ),
      NotificationModel(
        'Notification 5',
        'This is the fifth notification.',
        DateTime.now(),
        true,
      ),
    ];

    final selected = await showMenu<NotificationModel>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width, // Right aligned
        kToolbarHeight * 1.2, // Top aligned
        0,
        0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      elevation: 5,
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width * 0.7,
        maxWidth: MediaQuery.of(context).size.width * 0.7,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      items: [
        const PopupMenuItem<NotificationModel>(
          enabled: false, // Disable selecting the main title
          child: ListTile(
            title: Text(
              'Notifications',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ...notifications.map((notification) {
          return PopupMenuItem<NotificationModel>(
            value: notification,
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
                      notification.time.toString().substring(11, 16),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );

    if (selected != null) {
      // Handle the selected notification
      debugPrint('Selected: ${selected.title}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications),
      onPressed: () {
        _showNotificationMenu(context);
      },
    );
  }
}
