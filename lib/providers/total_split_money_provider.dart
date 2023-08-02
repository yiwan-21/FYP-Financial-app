import 'package:flutter/material.dart';
import '../components/split_group_card.dart';
import '../services/split_money_service.dart';

class TotalSplitMoneyProvider extends ChangeNotifier {
  Future <List<SplitGroupCard>> _groups = Future.value([]);

  TotalSplitMoneyProvider() {
    _groups = SplitMoneyService.getGroupCards();
  }

  Future<List<SplitGroupCard>> get groupCards => _groups;

  void updateGroups() {
    _groups = SplitMoneyService.getGroupCards();
    notifyListeners();
  }
}