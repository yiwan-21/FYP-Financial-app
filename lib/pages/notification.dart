import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constant.dart';
import '../models/notification_item.dart';
import '../models/notifications.dart';
import '../providers/notification_provider.dart';
import '../services/bill_service.dart';
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
    BillService.resetBill().then((_) {
      BillService.billDueNotification();
    });
  }

  Future<void> _markAllAsRead() async {
    await NotificationService.markAllAsRead();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, _) {
        final List<NotificationItem> notifications = notificationProvider.notifications;
        final int unread = notificationProvider.unread;
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
          icon: Icon(
            unread > 0 ? Icons.notifications_active : Icons.notifications,
            size: Constant.isMobile(context) ? 25 : 30,
          ),
          itemBuilder: (context) {
            return [
              PopupMenuItem<NotificationModel>(
                enabled: false,
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 10),
                  title: Text(
                    notifications.isNotEmpty
                        ? 'Notifications ${unread > 0 ? '($unread)' : ''}'
                        : 'No notification yet.',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: unread > 0
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
              ...notifications.map((notification) {
                final String title = notification.title;
                final String message = notification.message;
                final DateTime date = notification.createdAt;
                final bool read = notification.read;
                final String type = notification.type;
                final String? functionID = notification.functionID;
                final Function navigateTo = NotificationService.getNotificationFunction(type, functionID);

                return PopupMenuItem<NotificationModel>(
                  onTap: () {
                    NotificationService.markAsRead(notification.id);
                    navigateTo();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    color: read ? Colors.white : Colors.grey[100],
                    child: ListTile(
                      isThreeLine: true,
                      title: Text(title),
                      titleTextStyle: TextStyle(
                        color: Colors.black,
                        fontWeight:
                            read ? FontWeight.normal : FontWeight.bold,
                      ),
                      subtitle: Text(
                        message,
                        textAlign: TextAlign.justify,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitleTextStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              '${Constant.monthLabels[date.month - 1]} ${date.day}'),
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
      },
    );
  }
}
