import '../components/split_expense_card.dart';
import '../components/split_record_card.dart';
import '../components/split_group_card.dart';
import '../models/group_user.dart';
import '../models/split_group.dart';
import '../models/split_expense.dart';

class SplitMoneyService {
  static Future<SplitGroup> getGroupByID(String id) async {
    final SplitGroup group = SplitGroup(
      id: id,
      name: 'Group $id',
      owner: 'UCcZi2WQOuWkxcg3aNGykJwxs7E2',
      members: [
        GroupUser('member1ID', 'Member 1'),
        GroupUser('member2ID', 'Member 2'),
        GroupUser('member3ID', 'Member 3'),
        GroupUser('member4ID', 'Member 4'),
        GroupUser('member5ID', 'Member 5'),
        GroupUser('member6ID', 'Member 6'),
        GroupUser('member7ID', 'Member 7'),
        GroupUser('member8ID', 'Member 8'),
        GroupUser('member9ID', 'Member 9'),
      ],
      expenses: [
        SplitExpenseCard('1', 'Food', 300, true, true, DateTime.now()),
        SplitExpenseCard('2', 'Food', 25, true, false, DateTime.now()),
        SplitExpenseCard('3', 'Food', 80, false, true, DateTime.now()),
        SplitExpenseCard('4', 'Food', 100, false, false, DateTime.now()),
        SplitExpenseCard('5', 'Food', 300, true, true, DateTime.now()),
        SplitExpenseCard('6', 'Food', 25, true, false, DateTime.now()),
        SplitExpenseCard('7', 'Food', 80, false, true, DateTime.now()),
        SplitExpenseCard('8', 'Food', 100, false, false, DateTime.now()),
      ],
    );

    return group;
  }

  static Future<List<SplitGroupCard>> getAllGroups() async {
    final List<SplitGroupCard> groups = [
      const SplitGroupCard('1', groupName: 'Group 1'),
      const SplitGroupCard('2', groupName: 'Group 2'),
      const SplitGroupCard('3', groupName: 'Group 3'),
      const SplitGroupCard('4', groupName: 'Group 4'),
    ];

    return groups;
  }

  static Future<SplitExpense> getExpenseByID(String id) async {
    final SplitExpense expense = SplitExpense(
      id: id,
      title: 'Expense $id',
      amount: 300,
      paidBy: GroupUser('UCcZi2WQOuWkxcg3aNGykJwxs7E2', 'Lee'),
      sharedBy: [
        GroupUser('member1ID', 'Member 1'),
        GroupUser('member2ID', 'Member 2'),
        GroupUser('member3ID', 'Member 3'),
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

  static Future<dynamic> addGroup(String groupName) async {
    return SplitGroupCard('1', groupName: groupName);
  }

  static Future<dynamic> addExpense(SplitExpenseCard expense) async {
    return expense;
  }

  static Future<dynamic> addRecord(SplitRecordCard record) async {
    return record;
  }

  static void updateGroupName(String id, String name) {
    return;
  }

  static Future<void> addMember(String id, GroupUser member) async {
    return;
  }
}
