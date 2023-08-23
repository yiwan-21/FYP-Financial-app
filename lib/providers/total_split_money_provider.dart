import 'package:flutter/material.dart';
import '../components/split_group_card.dart';
import '../services/split_money_service.dart';

class TotalSplitMoneyProvider extends ChangeNotifier {
  List<SplitGroupCard> _groups = [];

  TotalSplitMoneyProvider() {
    updateGroups();
  }

  List<SplitGroupCard> get groupCards => _groups;

  Future<void> updateGroups() async {
    _groups = await SplitMoneyService.getGroupCards();
    notifyListeners();
  }
}