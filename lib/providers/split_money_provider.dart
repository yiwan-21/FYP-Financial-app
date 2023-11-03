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

  SplitGroup get splitGroup => _splitGroup;
  String? get id => splitGroup.id;
  String? get name => _splitGroup.name;
  String? get image => _splitGroup.image;
  String? get ownerId => _splitGroup.owner;
  List<GroupUser>? get members => _splitGroup.members;
  List<SplitExpenseCard>? get expenses => _splitGroup.expenses;

  Future<SplitGroup> setNewSplitGroup(String id) async {
    _splitGroup = await SplitMoneyService.getGroupByID(id);
    _splitGroup.image = await SplitMoneyService.getGroupImage(id);
    notifyListeners();
    return _splitGroup;
  }

  Future<void> updateSplitGroup() async {
    _splitGroup = await SplitMoneyService.getGroupByID(_splitGroup.id!);
    notifyListeners();
  }

  Future<void> updateExpenses() async {
    _splitGroup.expenses = await SplitMoneyService.getExpenseCards(_splitGroup.id!);
    notifyListeners();
  }

  // no need wait for response so no async (?)
  void updateName(String name) {
    SplitMoneyService.updateGroupName(name);
    _splitGroup.name = name;
    notifyListeners();
  }

  void setImage(String url) {
    _splitGroup.image = url;
    notifyListeners();
  }

  // no need wait for response so no async (?)
  void addMember(GroupUser member) {
    SplitMoneyService.addMember(member);
    _splitGroup.members!.add(member);
    notifyListeners();
  }

  Future<void> removeMember(GroupUser member) async {
    await SplitMoneyService.deleteMember(member.id).then((_) {
      _splitGroup.members!.remove(member);
    });
    notifyListeners();
  }

  void reset() {
    _splitGroup = SplitGroup();
    notifyListeners();
  }
}
