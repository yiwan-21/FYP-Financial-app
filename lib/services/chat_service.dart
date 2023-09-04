import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/notification_type.dart';
import '../firebase_instance.dart';
import '../services/split_money_service.dart';
import '../services/notification_service.dart';

class ChatService {
  static String _expenseID = '';

  static setExpenseID(String expenseID) {
    _expenseID = expenseID;
  }

  static resetExpenseID() {
    _expenseID = '';
  }

  static CollectionReference get chatsCollection => FirebaseInstance.firestore
      .collection('groups')
      .doc(SplitMoneyService.groupID)
      .collection('expenses')
      .doc(_expenseID)
      .collection('chats');

  static Stream<QuerySnapshot> getChatStream() {
    return chatsCollection.orderBy('date', descending: false)
        .snapshots(includeMetadataChanges: true);
  }

  static Future<List<Map<String, dynamic>>> getChatMessage() async {
    List<Map<String, dynamic>> messages = [];

    await chatsCollection
    .orderBy('date', descending: false)
    .get()
    .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        for (var message in snapshot.docs) {
          messages.add({
            'message': message['message'],
            'senderID': message['senderID'],
            'sender': message['sender'],
            'date': message['date'].toDate(),
            'read': message['readStatus'],
          });
        }
      }
    });
    return messages;
  }

  static Future<void> sendMessage(String message, String senderID) async {
    String senderRef = 'users/$senderID';
    String name = '';
    await FirebaseInstance.firestore.doc(senderRef).get().then((userData) {
      name = userData['name'];
    });

    await chatsCollection.add({
      'message': message,
      'senderID': senderID,
      'sender': name,
      'readStatus': [senderID],
      'date': DateTime.now(),
    });

    // Send Notification
    const String type = NotificationType.NEW_CHAT_NOTIFICATION;
    final List<String> receiverID = await SplitMoneyService.getExpenseMemberID(_expenseID);
    receiverID.remove(senderID);
    // prevent sending notification every time a message is sent
    await FirebaseInstance.firestore.collection('notifications')
        .where('type', isEqualTo: type)
        .where('functionID', isEqualTo: _expenseID)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get()
        .then((snapshot) async {
          // if notification found, remove the unread receivers and send new notification
          if (snapshot.docs.isNotEmpty) {
            final notification = snapshot.docs.first;
            List<String> receivers = List<String>.from(notification['receiverID']);
            List<bool> readStatus = List<bool>.from(notification['read']);

            //// Scenario 1 //// 
            // A-sender B C = send Notification1 to B, C
            // B read, C unread
            // B-sender = remove C from Notification1, send new notification to A, C
            
            for (int i = 0; i < readStatus.length; i++) {
              // if is sender, mark notification as read
              if (receivers[i] == senderID) {
                readStatus[i] = true;
                continue;
              }
              // if not read, remove the receiver
              while (readStatus.isNotEmpty && !readStatus[i]) {
                receivers.removeAt(i);
                readStatus.removeAt(i);
              }
            }
            await notification.reference.update({
              'receiverID': receivers,
              'read': readStatus,
            });
          }
          // send new notification 
          await NotificationService.sendNotification(type, receiverID, functionID: _expenseID);
        });
        

  }

  static Future<void> deleteChat() async {
    WriteBatch batch = FirebaseInstance.firestore.batch();
    QuerySnapshot snapshots = await chatsCollection.get();
    for (QueryDocumentSnapshot snapshot in snapshots.docs) {
      batch.delete(snapshot.reference);
    }
    await batch.commit();
    resetExpenseID();
  }

  static Future<void> updateReadStatus() async {
    // only update the latest message
    String userID = FirebaseInstance.auth.currentUser!.uid;
    QuerySnapshot snapshots = await chatsCollection.orderBy('date', descending: true).limit(1).get();
    if (snapshots.docs.isNotEmpty) {
      List<dynamic> readStatus = snapshots.docs.first['readStatus'];
      if (!readStatus.contains(userID)) {
        readStatus.add(userID);
        await snapshots.docs.first.reference.update({
          'readStatus': readStatus,
        });
      }
    }
  }

  static Future<bool> hasRead() async{
    bool hasRead = true;
    String userID = FirebaseInstance.auth.currentUser!.uid;
    await chatsCollection.orderBy('date', descending: true).limit(1).get().then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        List<dynamic> readStatus = snapshot.docs.first['readStatus'];
        hasRead = readStatus.contains(userID);
      }
    });

    return hasRead;
  } 
}
