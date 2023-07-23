import 'package:flutter/material.dart';
import '../components/split_group_card.dart';
import '../services/split_money_service.dart';

class TotalSplitMoneyProvider extends ChangeNotifier {
  Future <List<SplitGroupCard>> _groups = Future.value([]);

  TotalSplitMoneyProvider() {
    _groups = SplitMoneyService.getAllGroups();
  }

  Future<List<SplitGroupCard>> get getGroups => _groups;

  void updateGroups() {
    _groups = SplitMoneyService.getAllGroups();
    notifyListeners();
  }
}