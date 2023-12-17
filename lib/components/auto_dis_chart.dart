import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../providers/total_transaction_provider.dart';

class AutoDisData {
  AutoDisData(this.month, this.autonomous, this.discretionary);
  final String month;
  num autonomous;
  num discretionary;

  void addAutonomous(num autonomous) {
    this.autonomous += autonomous;
  }

  void addDiscretionary(num discretionary) {
    this.discretionary += discretionary;
  }
}

class AutoDisChart extends StatefulWidget {
  const AutoDisChart({super.key});

  @override
  State<AutoDisChart> createState() => _AutoDisChartState();
}

class _AutoDisChartState extends State<AutoDisChart> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TotalTransactionProvider>(
      builder: (context, totalTransactionProvider, _) {
        final List<AutoDisData> barData = totalTransactionProvider.getAutoDisData();
        return SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          // Chart title
          title: ChartTitle(
              text: 'Ratio of Autonomous to Discretionary Expenses'),
          // Enable legend
          legend: Legend(isVisible: true),
          // Enable tooltip
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <ChartSeries<AutoDisData, String>>[
            StackedColumnSeries(
              dataSource: barData,
              xValueMapper: (AutoDisData record2, _) => record2.month,
              yValueMapper: (AutoDisData record2, _) => record2.autonomous,
              name: 'Autonomous',
            ),
            StackedColumnSeries(
              dataSource: barData,
              xValueMapper: (AutoDisData record2, _) => record2.month,
              yValueMapper: (AutoDisData record2, _) =>
                  record2.discretionary,
              name: 'Discretionary',
            ),
          ],
        );
      },
    );
  }
}
