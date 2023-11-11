import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../constants/constant.dart';
import '../services/transaction_service.dart';

class DailySurplusData {
  final DateTime date;
  double surplus;

  void addSurplus(double surplus) {
    this.surplus += surplus;
  }

  DailySurplusData(this.date, this.surplus);
}

class DailySurplusChart extends StatefulWidget {
  const DailySurplusChart({super.key});

  @override
  State<DailySurplusChart> createState() => _DailySurplusChartState();
}

class _DailySurplusChartState extends State<DailySurplusChart> {
  final Future<List<DailySurplusData>> _splineData = TransactionService.getSplineData();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _splineData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              // Chart title
              title: ChartTitle(text: 'Daily Surplus or Deficit'),
              // Enable legend
              legend: Legend(isVisible: true),
              // Enable tooltip
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries<DailySurplusData, String>>[
                SplineSeries(
                  dataSource: snapshot.data!,
                  xValueMapper: (DailySurplusData record, _) => '${Constant.monthLabels[record.date.month - 1]} ${record.date.day}',
                  yValueMapper: (DailySurplusData record, _) => record.surplus,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  dataLabelMapper: (DailySurplusData record, _) => record.surplus > 0 ? 'Surplus' : 'Deficit',
                  markerSettings: const MarkerSettings(isVisible: true),
                  name: 'Surplus/\nDeficit',
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
