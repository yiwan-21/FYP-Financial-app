// ignore_for_file: unused_field

import '../components/bill_card.dart';
import '../components/budget_card.dart';
import '../components/debt_card.dart';
import '../components/goal.dart';
import '../components/split_group_card.dart';
import '../components/tracker_transaction.dart';
import '../utils/date_utils.dart';

class TourExample {
  static final TrackerTransaction expenseTransaction = TrackerTransaction(
    id: 'example',
    title: 'Example Expense Record',
    amount: 100,
    date: DateTime.now(),
    isExpense: true,
    category: 'Example Expense',
    notes: 'Example Notes',
  );

  static final TrackerTransaction incomeTransaction = TrackerTransaction(
    id: 'example',
    title: 'Example Income Record',
    amount: 500,
    date: DateTime.now(),
    isExpense: false,
    category: 'Example Income',
    notes: 'Example Notes',
  );

  static final Goal goal = Goal(
    id: 'example',
    title: 'Example Goal',
    amount: 3000,
    saved: 0,
    targetDate: getNextMonth(DateTime.now()),
    pinned: false,
    createdAt: DateTime.now(),
  );

  static SplitGroupCard group = const SplitGroupCard(
    'example',
    groupName: 'Example Group',
  );

  static BudgetCard budget = const BudgetCard('Example - Food', 1000, 0);

  static final BillCard bill = BillCard(
    id: 'example',
    title: 'Example Bill',
    amount: 100,
    paid: false,
    dueDate: getNextMonth(DateTime.now()),
    fixed: false,
    history: const [],
  );

  static DebtCard debt = const DebtCard(
    id: 'example',
    title: 'Example Debt',
    duration: 24,
    amount: 10000,
    interests: 0.1,
    history: [],
    remainingDuration: 24,
    paid: false,
  );
}
