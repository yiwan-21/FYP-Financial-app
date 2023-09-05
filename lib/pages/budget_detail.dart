import 'package:flutter/material.dart';

import '../components/budget_chart.dart';
import '../components/goal_history_card.dart';
import '../components/alert_confirm_action.dart';
import '../pages/edit_budget.dart';

class BudgetDetail extends StatefulWidget {
  const BudgetDetail({super.key});

  @override
  State<BudgetDetail> createState() => _BudgetDetailState();
}

class _BudgetDetailState extends State<BudgetDetail> {
  void deleteBudget() {}
  @override
  Widget build(BuildContext context) {
    List<HistoryCard> _history = [HistoryCard(20, DateTime.now())];
    return Scaffold(
      appBar: AppBar(
        //TODO: dynamic category name
        title: const Text('CategoryName'),

        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const EditBudget();
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertConfirmAction(
                    title: 'Delete Transaction',
                    content:
                        'Are you sure you want to delete this transaction?',
                    cancelText: 'Cancel',
                    confirmText: 'Delete',
                    confirmAction: deleteBudget,
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 24),
          const Text(
            'Daily Spending',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
          const BudgetGraph(),
          const SizedBox(height: 24),
          Wrap(
            children: List.generate(_history.length, (index) {
              return _history[index];
            }),
          ),
        ],
      ),
    );
  }
}
