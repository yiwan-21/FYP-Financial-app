import 'package:flutter/material.dart';

import '../components/split_group_card.dart';
import '../models/home_customization.dart';
import '../services/budget_service.dart';
import '../services/home_service.dart';
import '../services/split_money_service.dart';

class HomeProvider extends ChangeNotifier{
  HomeCustomization _customization = HomeCustomization(
    items: [],
    groupID: '',
    budgetCategory: '',
  );
  List<SplitGroupCard> _groupOptions = [];
  List<String> _budgetOptions = [];

  HomeProvider() {
    init();
  }

  HomeCustomization get customization => _customization;
  List<SplitGroupCard> get groupOptions => _groupOptions;
  List<String> get budgetOptions => _budgetOptions;

  Future<void> init() async {
    _customization = await HomeService.getHomeItems();
    _groupOptions = await SplitMoneyService.getGroupCards();
    _budgetOptions = await BudgetService.getBudgetCategories();
    notifyListeners();
  }

  void updateDisplayedItems(List<String> newItems, String newGroupID, String newBudgetCategory) {
    _customization = HomeCustomization(
      items: newItems,
      groupID: newGroupID,
      budgetCategory: newBudgetCategory,
    );
    notifyListeners();
  }

  void reset() {
    _customization = HomeCustomization(
      items: [],
      groupID: '',
      budgetCategory: '',
    );
    notifyListeners();
  }
}