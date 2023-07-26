import 'package:flutter/material.dart';

import '../components/split_expense_card.dart';
import '../models/group_user.dart';
import '../models/split_group.dart';
import '../services/split_money_service.dart';

class SplitMoneyProvider extends ChangeNotifier {
  SplitGroup _splitGroup = SplitGroup();

  SplitMoneyProvider() {
    _splitGroup = SplitGroup();
  }

  String get name => _splitGroup.name!;
  String get ownerId => _splitGroup.owner!;
  List<GroupUser> get members => _splitGroup.members!;
  List<SplitExpenseCard> get expenses => _splitGroup.expenses!;

  Future<void> setNewSplitGroup(String id) async {
    _splitGroup = await SplitMoneyService.getGroupByID(id);
    notifyListeners();
  }

  Future<void> updateSplitGroup() async {
    _splitGroup = await SplitMoneyService.getGroupByID(_splitGroup.id!);
    notifyListeners();
  }

  // no need wait for response so no async (?)
  void updateName(String name) {
    SplitMoneyService.updateGroupName(_splitGroup.id!, name);
    _splitGroup.name = name;
    notifyListeners();
  }

  // no need wait for response so no async (?)
  void addMember(GroupUser member) {
    SplitMoneyService.addMember(_splitGroup.id!, member);
    _splitGroup.members!.add(member);
    notifyListeners();
  }

  void reset() {
    _splitGroup = SplitGroup();
    notifyListeners();
  }
}