import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_instance.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? functionID;
  final DateTime createdAt;
  final bool read;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.functionID,
    required this.createdAt,
    required this.read,
  });

  NotificationItem.fromSnapshot(DocumentSnapshot snapshot)
      : id = snapshot.id,
        title = snapshot['title'],
        message = snapshot['message'],
        type = snapshot['type'],
        functionID = snapshot['functionID'],
        createdAt = snapshot['createdAt'].toDate(),
        read = List<bool>.from(snapshot['read'])[List<String>.from(snapshot['receiverID']).indexOf(FirebaseInstance.auth.currentUser!.uid)];
}