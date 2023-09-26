import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/components/split_expense_card.dart';
import 'package:flutter/material.dart';

import '../constants/notification_type.dart';
import '../firebase_instance.dart';
import '../components/split_group_card.dart';
import '../constants/constant.dart';
import '../models/group_user.dart';
import '../models/split_group.dart';
import '../models/split_expense.dart';
import '../models/split_record.dart';
import '../services/chat_service.dart';
import '../services/notification_service.dart';

class SplitMoneyService {
  // set once the user open a group page
  // and reset when the user leave the group page
  static String _groupID = '';

  static String get groupID => _groupID;

  static void setGroupID(String id) {
    _groupID = id;
  }

  static void resetGroupID() {
    _groupID = '';
  }

  static CollectionReference get groupsCollection =>
      FirebaseInstance.firestore.collection('groups');

  static Future<SplitGroup> getGroupByID(String groupID) async {
    setGroupID(groupID);
    SplitGroup group = SplitGroup();
    final groupDoc = await groupsCollection.doc(groupID).get();

    final membersReferences = (List<String>.from(groupDoc['members'])).map((member) {
      return FirebaseInstance.firestore.doc(member);
    }).toList();

    final membersData = await Future.wait(
      membersReferences.map((memberRef) async {
        final userData = await memberRef.get();
        return GroupUser(userData.id, userData['name'], userData['email']);
      }).toList(),
    );

    group = SplitGroup(
      id: groupDoc.id,
      name: groupDoc['name'],
      owner: groupDoc['owner'],
      members: membersData,
      expenses: await getExpenseCards(groupID),
    );

    return group;
  }

  static Future<List<SplitExpenseCard>> getExpenseCards(String groupID) async {
    List<SplitExpenseCard> expenses = [];
    await groupsCollection
        .doc(groupID)
        .collection('expenses')
        .orderBy('date', descending: true)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          expenses.add(SplitExpenseCard.fromDocument(doc));
        }
      }
    });

    return expenses;
  }

  static Stream<QuerySnapshot> getExpenseStream(String groupID) {
    return groupsCollection
        .doc(groupID)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots();
  }

  static Future<List<SplitGroupCard>> getGroupCards() async {
    final List<SplitGroupCard> groups = [];
    await groupsCollection
        .where('members',
            arrayContains: 'users/${FirebaseInstance.auth.currentUser!.uid}')
        .get()
        .then((snapshot) => {
              for (var group in snapshot.docs)
                {groups.add(SplitGroupCard(group.id, groupName: group['name']))}
            });

    return groups;
  }

  static Future<void> setGroupIDbyExpenseID(String expenseID) async {
    await FirebaseInstance.firestore
        .collectionGroup('expenses')
        .where('id', isEqualTo: expenseID)
        .limit(1)
        .get()
        .then((value) {
      setGroupID(value.docs.first.reference.parent.parent!.id);
    });
  }

  static Future<SplitExpense> getExpenseByID(String expenseID) async {
    String title = '';
    double amount = 0;
    double paidAmount = 0;
    String splitMethod = '';
    GroupUser paidBy = GroupUser('', '', '');
    List<SplitRecord> records = [];
    DateTime createdAt = DateTime.now();

    DocumentReference expenseDoc =
        groupsCollection.doc(_groupID).collection('expenses').doc(expenseID);

    await expenseDoc.get().then((snapshot) async => {
          if (snapshot.exists)
            {
              title = snapshot['title'],
              amount = snapshot['amount'],
              paidAmount = snapshot['paidAmount'],
              splitMethod = snapshot['splitMethod'],
              await FirebaseInstance.firestore
                  .doc(snapshot['paidBy'])
                  .get()
                  .then((userData) => {
                        paidBy = GroupUser(
                            userData.id, userData['name'], userData['email'])
                      }),
              createdAt = snapshot['date'].toDate(),
            }
        });

    await expenseDoc.collection('records').get().then((snapshot) => {
          if (snapshot.docs.isNotEmpty)
            {
              // ignore: avoid_function_literals_in_foreach_calls
              snapshot.docs.forEach((record) {
                records.add(SplitRecord(
                  id: record.id,
                  name: record['name'],
                  amount: record['amount'].toDouble(),
                  paidAmount: record['paid'].toDouble(),
                  date: record['date'].toDate(),
                ));
              }),
            }
        });

    final SplitExpense expense = SplitExpense(
      id: expenseID,
      title: title,
      amount: amount,
      paidAmount: paidAmount,
      splitMethod: splitMethod,
      paidBy: paidBy,
      sharedRecords: records,
      createdAt: createdAt,
    );

    return expense;
  }

  static Future<List<String>> getExpenseMemberID(String expenseID) async {
    List<String> memberID = [];
    await groupsCollection
        .doc(_groupID)
        .collection('expenses')
        .doc(expenseID)
        .get()
        .then((expense) {
      for (var member in List<String>.from(expense['sharedBy'])) {
        memberID.add(member.split('/')[1]);
      }
      String paidBy = expense['paidBy'].split('/')[1];
      if (!memberID.contains(paidBy)) {
        memberID.add(paidBy);
      }
    });
    return memberID;
  }

  static Future<void> addGroup(String groupName) async {
    await groupsCollection.add({
      'name': groupName,
      'owner': 'users/${FirebaseInstance.auth.currentUser!.uid}',
      'members': ['users/${FirebaseInstance.auth.currentUser!.uid}'],
    });
  }

  static Future<GroupUser?> hasAccount(String targetEmail) async {
    return await FirebaseInstance.firestore
        .collection('users')
        .where('email', isEqualTo: targetEmail)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first;
        return GroupUser(
          userData.id,
          userData['name'],
          userData['email'],
        );
      } else {
        return null;
      }
    });
  }

  static Future<void> addMember(GroupUser member) async {
    await groupsCollection.doc(_groupID).update({
      'members': FieldValue.arrayUnion(['users/${member.id}'])
    });

    // Send Notification
    const type = NotificationType.NEW_GROUP_NOTIFICATION;
    final receiverID = [member.id];
    await NotificationService.sendNotification(type, receiverID, functionID: _groupID);
  }

  static Future<void> deleteMember(String memberID) async {
    String memberRef = "users/$memberID";

    List<dynamic>? members = (await FirebaseInstance.firestore
            .collection("groups")
            .doc(_groupID)
            .get())
        .data()?['members'];

    members?.remove(memberRef);

    await FirebaseInstance.firestore
        .collection("groups")
        .doc(_groupID)
        .update({'members': members});

    // Send Notification
    const type = NotificationType.REMOVE_FROM_GROUP_NOTIFICATION;
    final receiverID = [memberID];
    final functionID = _groupID;
    await NotificationService.sendNotification(type, receiverID, functionID: functionID);
  }

  static Future<void> deleteGroup() async {
    await groupsCollection
        .doc(_groupID)
        .collection('expenses')
        .get()
        .then((snapshot) async {
      for (var expense in snapshot.docs) {
        await deleteExpense(expense.id);
      }
    });
    await groupsCollection.doc(_groupID).delete();
  }

  static Future<void> updateGroupName(String name) async {
    await groupsCollection.doc(_groupID).update({'name': name});
  }

  static Future<dynamic> addExpense(SplitExpense expense) async {
    // add new 'expense' document
    DocumentReference newExpense =
        await groupsCollection.doc(_groupID).collection('expenses').add({
          'title': expense.title,
          'amount': expense.amount,
          'paidAmount': expense.paidAmount,
          'splitMethod': expense.splitMethod,
          'paidBy': 'users/${expense.paidBy.id}',
          'sharedBy':
              expense.sharedRecords.map((record) => 'users/${record.id}').toList(),
          'date': DateTime.now(),
        });
    await newExpense.update({'id': newExpense.id});

    // add new 'records' documents
    for (var record in expense.sharedRecords) {
      double amount = 0;
      switch (expense.splitMethod) {
        case Constant.splitEqually:
          amount = expense.amount / expense.sharedRecords.length;
          break;
        case Constant.splitUnequally:
          break;
        default:
      }
      newExpense.collection('records').doc(record.id).set({
        'name': record.name,
        'amount': amount,
        'paid': record.paidAmount,
        'date': DateTime.now(),
      });
    }

    // Send Notification
    const type = NotificationType.NEW_EXPENSE_NOTIFICATION;
    final receiverID = expense.sharedRecords.map((record) => record.id).toList();
    receiverID.remove(FirebaseInstance.auth.currentUser!.uid);
    final functionID = _groupID;
    await NotificationService.sendNotification(type, receiverID, functionID: functionID);

    return expense;
  }

  static Future<void> deleteExpense(String expenseID) async {
    WriteBatch batch = FirebaseInstance.firestore.batch();
    DocumentReference expenseRef = groupsCollection.doc(_groupID).collection('expenses').doc(expenseID);

    // delete records
    await expenseRef.collection('records').get().then((snapshot) {
      for (var record in snapshot.docs) {
        batch.delete(record.reference);
      }
    });
    await batch.commit();

    // delete chats
    ChatService.setExpenseID(expenseID);
    await ChatService.deleteChat();

    // delete expense
    await expenseRef.delete();
  }

  static Future<void> settleUp(String expenseID, double amount) async {
    DocumentReference expenseRef =
        groupsCollection.doc(_groupID).collection('expenses').doc(expenseID);

    await expenseRef.update({'paidAmount': FieldValue.increment(amount)});

    await expenseRef
        .collection('records')
        .doc(FirebaseInstance.auth.currentUser!.uid)
        .update({'paid': FieldValue.increment(amount)});
  }

  static Future<String> getGroupName(String groupID) async {
    String groupName = '';
    try {
      await groupsCollection.doc(groupID).get().then((snapshot) {
        groupName = snapshot['name'];
      });
    } catch (e) {
      debugPrint("Error on getting group name: $e");
    }
    return groupName;
  }

  static Future<String> getExpenseName(String expenseID) async {
    String expenseName = '';
    try {
      await FirebaseInstance.firestore
          .collectionGroup('expenses')
          .where('id', isEqualTo: expenseID)
          .get()
          .then((snapshot) {
        expenseName = snapshot.docs.first['title'];
      });
    } catch (e) {
      debugPrint("Error on getting expense name: $e");
    }
    return expenseName;
  }

}
