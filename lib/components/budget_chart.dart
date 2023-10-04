import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../constants/constant.dart';

class BudgetChart extends StatefulWidget {
  final List<BudgetChartData> budgetData;

  const BudgetChart(this.budgetData, {super.key});

  @override
  State<BudgetChart> createState() => _BudgetGraphState();
}

class _BudgetGraphState extends State<BudgetChart> {
  bool get _noScroll => !(Constant.isMobile(context) || Constant.isTablet(context)) && kIsWeb;

  @override
  Widget build(BuildContext context) {
    return 
    SingleChildScrollView(
      scrollDirection: _noScroll ? Axis.vertical : Axis.horizontal,
      reverse: true,
      child: Container(
        margin: _noScroll ? const EdgeInsets.symmetric(horizontal: 12) :const EdgeInsets.only(left: 12, right: 150),
        width: widget.budgetData.length * 80,
        child: SfCartesianChart(
          plotAreaBorderWidth: 0,
          primaryXAxis: CategoryAxis(
            majorGridLines: const MajorGridLines(color: Colors.transparent),
            majorTickLines: const MajorTickLines(color: Colors.transparent),
            interval: _noScroll ? 2 : 1,
          ),
          primaryYAxis: NumericAxis(isVisible: false),
          // Enable tooltip
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <ChartSeries<BudgetChartData, String>>[
            ColumnSeries<BudgetChartData, String>(
              color: const Color.fromRGBO(174, 74, 174, 1),
              width: 0.3,
              borderRadius: BorderRadius.circular(8),
              dataSource: widget.budgetData,
              xValueMapper: (BudgetChartData record, _) => '${Constant.monthLabels[record.date.month - 1]} ${record.date.day}',
              yValueMapper: (BudgetChartData record, _) => record.amount,
              name: 'Daily Spending',
              // Enable data label
              dataLabelSettings: const DataLabelSettings(isVisible: true),
            ),
          ],
        ),
      ),
    );
  }
}

class BudgetChartData {
  double amount;
  final DateTime date;

  BudgetChartData(this.amount, this.date);

  void addAmount(double amount) {
    this.amount += amount;
  }
}