import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../services/transaction_service.dart';

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
  final Future<List<AutoDisData>> _barData = TransactionService.getBarData();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _barData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
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
                  dataSource: snapshot.data!,
                  xValueMapper: (AutoDisData record2, _) => record2.month,
                  yValueMapper: (AutoDisData record2, _) => record2.autonomous,
                  name: 'Autonomous',
                ),
                StackedColumnSeries(
                  dataSource: snapshot.data!,
                  xValueMapper: (AutoDisData record2, _) => record2.month,
                  yValueMapper: (AutoDisData record2, _) =>
                      record2.discretionary,
                  name: 'Discretionary',
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
