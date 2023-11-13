import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../services/transaction_service.dart';

class TrackerOverviewData {
  TrackerOverviewData(this.month, this.expense, this.income);

  final String month;
  double expense;
  double income;

  void addExpense(double expense) {
    this.expense += expense;
  }

  void addIncome(double income) {
    this.income += income;
  }
}

class ExpenseIncomeGraph extends StatefulWidget {
  const ExpenseIncomeGraph({super.key});

  @override
  State<ExpenseIncomeGraph> createState() => _ExpenseIncomeGraphState();
}

class _ExpenseIncomeGraphState extends State<ExpenseIncomeGraph> {
  final Future<List<TrackerOverviewData>> _lineData = TransactionService.getLineData();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _lineData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              // Chart title
              title: ChartTitle(text: 'Monthly Expense and Income'),
              // Enable legend
              legend: Legend(isVisible: true),
              // Enable tooltip
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries<TrackerOverviewData, String>>[
                LineSeries<TrackerOverviewData, String>(
                    dataSource: snapshot.data!,
                    xValueMapper: (TrackerOverviewData record, _) => record.month,
                    yValueMapper: (TrackerOverviewData record, _) =>
                        record.expense,
                    name: 'Expense',
                    // Enable data label
                    dataLabelSettings:
                        const DataLabelSettings(isVisible: true)),
                LineSeries<TrackerOverviewData, String>(
                    dataSource: snapshot.data!,
                    xValueMapper: (TrackerOverviewData record, _) => record.month,
                    yValueMapper: (TrackerOverviewData record, _) =>
                        record.income,
                    name: 'Income',
                    // Enable data label
                    dataLabelSettings:
                        const DataLabelSettings(isVisible: true)),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
