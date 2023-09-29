import 'package:flutter/material.dart';

import '../models/home_customization.dart';
import '../services/home_service.dart';

class HomeProvider extends ChangeNotifier{
  HomeCustomization _customization = HomeCustomization(
    items: [],
    groupID: '',
    budgetCategory: '',
  );

  HomeProvider() {
    init();
  }

  HomeCustomization get customization => _customization;

  Future<void> init() async {
    _customization = await HomeService.getHomeItems();
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