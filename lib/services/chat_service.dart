import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/notification_type.dart';
import '../firebase_instance.dart';
import 'split_money_service.dart';

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
    // prevent sending notification every time a message is sent
    //// idea: renew the notification creation time?
    // can try check receiverID and read status to see if the notification is read
    // if not read, then don't send notification, renew the notification creation time
    // if read, then send notification
    final List<String> receiverID = await SplitMoneyService.getGroupMemberID();
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
