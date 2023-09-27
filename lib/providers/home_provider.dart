import 'package:flutter/material.dart';

import '../components/split_group_card.dart';
import '../constants/home_constant.dart';
import '../services/budget_service.dart';
import '../services/split_money_service.dart';

class HomeProvider extends ChangeNotifier{
  final List<String> _displayedItems = HomeConstant.homeItems.keys.toList();
  List<SplitGroupCard> _groupOptions = [];
  List<String> _budgetOptions = [];

  HomeProvider() {
    // fetch data from database
    updateOptions();
  }

  List<String> get displayedItems => _displayedItems;
  List<SplitGroupCard> get groupOptions => _groupOptions;
  List<String> get budgetOptions => _budgetOptions;

  Future<void> updateOptions() async {
    _groupOptions = await SplitMoneyService.getGroupCards();
    _budgetOptions = await BudgetService.getBudgetCategories();
    notifyListeners();
  }

  void updateDisplayedItems(List<String> newItems) {
    _displayedItems.clear();
    _displayedItems.addAll(newItems);
    notifyListeners();
  }

  void resetDisplayedItems() {
    _displayedItems.clear();
    notifyListeners();
  }
}