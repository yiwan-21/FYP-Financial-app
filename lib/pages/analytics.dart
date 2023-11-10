import 'package:flutter/material.dart';

import '../components/expense_income_graph.dart';
import '../components/auto_dis_chart.dart';
import '../components/monitor_debt_chart.dart';
import '../components/monitor_goal_chart.dart';

class Analytics extends StatelessWidget {
  const Analytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 24),
          const ExpenseIncomeGraph(),
          const SizedBox(height: 24),
          const AutoDisChart(),
          Container(
            constraints: const BoxConstraints(maxWidth: 768),
            child: const Center(
              child: Card(
                elevation: 5,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Autonommous Expenditure: Food, Transportation, Rental, Bill\nDiscretionary Expenditure: Education, Personal Items, Other Expenses',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const MonitorDebtChart(),
          const SizedBox(height: 24),
          const MonitorGoalChart(),
        ],
      ),
    );
  }
}
