import 'package:financial_app/components/split_expense_card.dart';

import '../components/split_group_card.dart';
import '../models/split_group.dart';

class SplitMoneyService {
  static Future<SplitGroup> getGroupByID(String id) async {
    final SplitGroup group = SplitGroup(
      id: id,
      name: 'Group $id',
      owner: 'Owner',
      members: [
        'Member 1',
        'Member 2',
        'Member 3',
        'Member 4',
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
}
