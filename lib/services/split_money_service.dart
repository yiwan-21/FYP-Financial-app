import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/split_expense_card.dart';
import '../components/split_record_card.dart';
import '../components/split_group_card.dart';
import '../firebase_instance.dart';
import '../models/group_user.dart';
import '../models/split_group.dart';
import '../models/split_expense.dart';

class SplitMoneyService {
  static CollectionReference get groupsCollection =>
      FirebaseInstance.firestore.collection('groups');

  static Future<SplitGroup> getGroupByID(String id) async {
    SplitGroup group = SplitGroup();

    final groupDoc = await groupsCollection.doc(id).get();

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
      expenses: [],
    );

    return group;
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

  static Future<SplitExpense> getExpenseByID(String id) async {
    final SplitExpense expense = SplitExpense(
      id: id,
      title: 'Expense $id',
      amount: 300,
      paidBy: GroupUser(
          'UCcZi2WQOuWkxcg3aNGykJwxs7E2', 'Lee', 'leeyiwan0921@gmail.com'),
      sharedBy: [
        GroupUser('member1ID', 'Member 1', 'member1@email.com'),
        GroupUser('member2ID', 'Member 2', 'member2@email.com'),
        GroupUser('member3ID', 'Member 3', 'member3@email.com'),
      ],
      records: [
        SplitRecordCard('Member 1', 20, 20, DateTime.now()),
        SplitRecordCard('Member 2', 30, 30, DateTime.now()),
        SplitRecordCard('Member 3', 40, 20, DateTime.now()),
        SplitRecordCard('Member 4', 50, 20, DateTime.now()),
        SplitRecordCard('Member 5', 20, 20, DateTime.now()),
        SplitRecordCard('Member 6', 30, 30, DateTime.now()),
        SplitRecordCard('Member 7', 40, 20, DateTime.now()),
        SplitRecordCard('Member 8', 50, 20, DateTime.now()),
      ],
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

  static Future<GroupUser?> hasAccount(String _targetEmail) async {
    return await FirebaseInstance.firestore
        .collection('users')
        .where('email', isEqualTo: _targetEmail)
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

  static Future<dynamic> addExpense(SplitExpenseCard expense) async {
    return expense;
  }

  static Future<dynamic> addRecord(SplitRecordCard record) async {
    return record;
  }
}
