import 'package:flutter/material.dart';

import '../pages/home.dart';

class HomeConstant {
  static const String transaction = 'Recent Transaction';
  static const String goal = 'Recent Goal';
  static const String groupExpense = 'Recent Group Expenses';
  static const String budget = 'Budget';
  static const String bills = 'Unpaid Bills';

  static const Map<String, Widget> homeItems = {
    transaction: RecentTransactions(),
    goal: RecentGoal(),
    groupExpense: RecentGroupExpense(),
    budget: RecentBudget(),
    bills: UnpaidBills(),
  };
}