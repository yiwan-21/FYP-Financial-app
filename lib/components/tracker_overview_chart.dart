import 'package:financial_app/providers/goal_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../providers/transaction_provider.dart';

class TrackerOverviewData {
  TrackerOverviewData(this.month, this.expense, this.income, this.savingsGoal);

  final String month;
  double expense;
  double income;
  double savingsGoal;

  void addExpense(double expense) {
    this.expense += expense;
  }

  void addIncome(double income) {
    this.income += income;
  }

  void addSavingsGoal(double savingsGoal) {
    this.savingsGoal += savingsGoal;
  }
}

class TrackerOverviewGraph extends StatefulWidget {
  const TrackerOverviewGraph({super.key});

  @override
  State<TrackerOverviewGraph> createState() => _TrackerOverviewGraphState();
}

class _TrackerOverviewGraphState extends State<TrackerOverviewGraph> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, _) {
        return Consumer<TransactionProvider>(
          builder: (context, transactionProvider, _) {
            final List<TrackerOverviewData> trackerLineData = transactionProvider.getTrackerOverviewData();
            final List<TrackerOverviewData> goalLineData = goalProvider.getTrackerOverviewData();
            return SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              // Chart title
              title: ChartTitle(text: 'Monthly Expense, Income and Savings Goal'),
              // Enable legend
              legend: Legend(isVisible: true),
              // Enable tooltip
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries<TrackerOverviewData, String>>[
                LineSeries<TrackerOverviewData, String>(
                    dataSource: trackerLineData,
                    xValueMapper: (TrackerOverviewData record, _) => record.month,
                    yValueMapper: (TrackerOverviewData record, _) => record.expense,
                    name: 'Expense',
                    // Enable data label
                    dataLabelSettings: const DataLabelSettings(isVisible: true)),
                LineSeries<TrackerOverviewData, String>(
                    dataSource: trackerLineData,
                    xValueMapper: (TrackerOverviewData record, _) => record.month,
                    yValueMapper: (TrackerOverviewData record, _) => record.income,
                    name: 'Income',
                    // Enable data label
                    dataLabelSettings: const DataLabelSettings(isVisible: true)),
                LineSeries<TrackerOverviewData, String>(
                    dataSource: goalLineData,
                    xValueMapper: (TrackerOverviewData record, _) => record.month,
                    yValueMapper: (TrackerOverviewData record, _) => record.savingsGoal,
                    name: 'Savings Goal',
                    // Enable data label
                    dataLabelSettings: const DataLabelSettings(isVisible: true)),
              ],
            );
          },
        );
      }
    );
  }
}
