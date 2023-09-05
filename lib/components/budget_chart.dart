import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../constants/style_constant.dart';

class BudgetChartData {
  final DateTime day;
  double amount;

  BudgetChartData(this.day, this.amount);
}

class BudgetGraph extends StatefulWidget {
  const BudgetGraph({super.key});

  @override
  State<BudgetGraph> createState() => _BudgetGraphState();
}

class _BudgetGraphState extends State<BudgetGraph> {
  final List<BudgetChartData> _budgetData = [
    BudgetChartData(DateTime.now().subtract(const Duration(days: 14)), 60),
    BudgetChartData(DateTime.now().subtract(const Duration(days: 13)), 70),
    BudgetChartData(DateTime.now().subtract(const Duration(days: 12)), 35),
    BudgetChartData(DateTime.now().subtract(const Duration(days: 11)), 26),
    BudgetChartData(DateTime.now().subtract(const Duration(days: 10)), 70),
    BudgetChartData(DateTime.now().subtract(const Duration(days: 9)), 30),
    BudgetChartData(DateTime.now().subtract(const Duration(days: 8)), 55),
    BudgetChartData(DateTime.now().subtract(const Duration(days: 7)), 66),
    BudgetChartData(DateTime.now().subtract(const Duration(days: 6)), 77),
    BudgetChartData(DateTime.now().subtract(const Duration(days: 5)), 31),
    BudgetChartData(DateTime.now().subtract(const Duration(days: 4)), 30),
    BudgetChartData(DateTime.now().subtract(const Duration(days: 3)), 22),
    BudgetChartData(DateTime.now().subtract(const Duration(days: 2)), 111),
    BudgetChartData(DateTime.now().subtract(const Duration(days: 1)), 80),
    BudgetChartData(DateTime.now(), 100),
  ];

  final DateFormat formatter = DateFormat('MMMd');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: _budgetData.length * 80,
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(
            majorGridLines: const MajorGridLines(color: Colors.transparent),
            majorTickLines: const MajorTickLines(color: Colors.transparent),
          ),
          primaryYAxis: NumericAxis(isVisible: false),
          // Enable tooltip
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <ChartSeries<BudgetChartData, String>>[
            ColumnSeries<BudgetChartData, String>(
              color: purple,
                width: 0.2,
                borderRadius: BorderRadius.circular(8),
                dataSource: _budgetData,
                xValueMapper: (BudgetChartData record, _) =>
                    formatter.format(record.day).toString(),
                yValueMapper: (BudgetChartData record, _) => record.amount,
                name: 'Daily Spending',
                // Enable data label
                dataLabelSettings: const DataLabelSettings(isVisible: true)),
          ],
        ),
      ),
    );
  }
}
