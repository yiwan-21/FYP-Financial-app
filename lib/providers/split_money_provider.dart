import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../components/split_expense_card.dart';
import '../components/split_group_card.dart';
import '../models/group_user.dart';
import '../models/split_group.dart';
import '../services/split_money_service.dart';

class SplitMoneyProvider extends ChangeNotifier {
  StreamSubscription? _listener;
  final List<SplitGroupCard> _groups = [];
  SplitGroup _splitGroup = SplitGroup();

  SplitMoneyProvider() {
    init();
  }

  List<SplitGroupCard> get groups => _groups;
  SplitGroup get splitGroup => _splitGroup;
  String? get id => splitGroup.id;
  String? get name => _splitGroup.name;
  String? get image => _splitGroup.image;
  String? get ownerId => _splitGroup.owner;
  List<GroupUser>? get members => _splitGroup.members;
  List<SplitExpenseCard>? get expenses => _splitGroup.expenses;

  void init() {
    if (_listener != null) {
      _listener?.cancel();
    }
    _listener = SplitMoneyService.getGroupStream().listen((event) {
      event.metadata.isFromCache
          ? debugPrint("Split Money Stream: Data from local cache")
          : debugPrint("Split Money Stream: Data from server");
      event.metadata.hasPendingWrites // pendingWrites ? "Local" : "Server";
          ? debugPrint("Split Money Stream: There are pending writes")
          : debugPrint("Split Money Stream: There are no pending writes");
      debugPrint("Split Money Stream: Document changes: ${event.docChanges.length}");

      for (var change in event.docChanges) {
        int index = _groups.indexWhere((element) => element.groupID == change.doc.id);
        if (change.type == DocumentChangeType.added) {
          // add the group
          _groups.add(SplitGroupCard.fromSnapshot(change.doc));
        } else if (change.type == DocumentChangeType.modified) {
          // update the group
          _groups[index] = SplitGroupCard.fromSnapshot(change.doc);
        } else if (change.type == DocumentChangeType.removed) {
          // remove the group
          _groups.removeAt(index);
        }
      }
      notifyListeners();
    });
  }

  void reset() {
    _listener?.cancel();
    _groups.clear();
    _splitGroup = SplitGroup();
  }

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
}
