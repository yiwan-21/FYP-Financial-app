import 'package:cloud_firestore/cloud_firestore.dart';

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
      'readStatus': [],
      'date': DateTime.now(),
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

  static Future<bool> readStatus() async {
    return true;
  }

  static Future<void> updateReadStatus() async {
    return;
  }
}
