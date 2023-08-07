import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/components/split_expense_card.dart';

import '../firebase_instance.dart';
import '../components/split_group_card.dart';
import '../constants/constant.dart';
import '../models/group_user.dart';
import '../models/split_group.dart';
import '../models/split_expense.dart';
import '../models/split_record.dart';

class SplitMoneyService {
  static CollectionReference get groupsCollection => FirebaseInstance.firestore.collection('groups');

  static Future<SplitGroup> getGroupByID(String groupID) async {
    SplitGroup group = SplitGroup();
    final groupDoc = await groupsCollection.doc(groupID).get();

    final membersReferences = (groupDoc['members'] as List).map((member) {
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
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        for (var expense in snapshot.docs) {
          expenses.add(SplitExpenseCard(
            id: expense.id,
            title: expense['title'],
            totalAmount: expense['amount'],
            isSettle: expense['paidAmount'] >= expense['amount'],
            isLent: expense['paidBy'] ==
                'users/${FirebaseInstance.auth.currentUser!.uid}',
            date: expense['date'].toDate(),
          ));
        }
      }
    });

    return expenses;
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

  static Future<SplitExpense> getExpenseByID(String groupID, String expenseID) async {
    String title = '';
    double amount = 0;
    double paidAmount = 0;
    String splitMethod = '';
    GroupUser paidBy = GroupUser('', '', '');
    List<SplitRecord> records = [];
    DateTime createdAt = DateTime.now();

    DocumentReference expenseDoc = groupsCollection.doc(groupID).collection('expenses').doc(expenseID);

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

  static Future<void> addMember(String groupID, GroupUser member) async {
    await groupsCollection.doc(groupID).update({
      'members': FieldValue.arrayUnion(['users/${member.id}'])
    });
  }

  static Future<void> deleteMember(String groupID, String memberID) async {
    String memberRef = "users/$memberID";

    List<dynamic>? members = (await FirebaseInstance.firestore
            .collection("groups")
            .doc(groupID)
            .get())
        .data()?['members'];

    members?.remove(memberRef);

    return await FirebaseInstance.firestore
        .collection("groups")
        .doc(groupID)
        .update({'members': members});
  }

  static Future<void> deleteGroup(String? groupID) async {
    return await groupsCollection.doc(groupID).delete();
  }

  static Future<void> updateGroupName(String groupID, String name) async {
    await groupsCollection.doc(groupID).update({'name': name});
  }

  static Future<dynamic> addExpense(String groupID, SplitExpense expense) async {
    // add new 'expense' document
    DocumentReference newExpense =
        await groupsCollection.doc(groupID).collection('expenses').add({
      'title': expense.title,
      'amount': expense.amount,
      'paidAmount': expense.paidAmount,
      'splitMethod': expense.splitMethod,
      'paidBy': 'users/${expense.paidBy.id}',
      'sharedBy': expense.sharedRecords.map((record) => 'users/${record.id}').toList(),
      'date': DateTime.now(),
    });

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

    return expense;
  }
  
  static Future<void> deleteExpense(String groupID, String expenseID ) async {
    await groupsCollection.doc(groupID).collection('expenses').doc(expenseID).delete();
  }
  
  static Future<void> settleUp(String groupID, String expenseID, double amount) async {
    DocumentReference expenseRef = groupsCollection.doc(groupID).collection('expenses').doc(expenseID);

    await expenseRef.update({'paidAmount': FieldValue.increment(amount)});

    await expenseRef
        .collection('records')
        .doc(FirebaseInstance.auth.currentUser!.uid)
        .update({'paid': FieldValue.increment(amount)});
  }
}
