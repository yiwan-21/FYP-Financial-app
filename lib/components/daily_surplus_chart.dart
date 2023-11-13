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
              primaryXAxis: CategoryAxis(title: AxisTitle(text: 'Date')),
              // Chart title
              title: ChartTitle(text: 'Daily Surplus or Deficit'),
              // Enable legend
              // legend: Legend(isVisible: true),
              // Enable tooltip
              tooltipBehavior: TooltipBehavior(enable: true),
              onTooltipRender: (TooltipArgs tooltipArgs) {
                if (tooltipArgs.dataPoints != null && tooltipArgs.dataPoints!.isNotEmpty) {
                  int index = tooltipArgs.pointIndex!.toInt();
                  CartesianChartPoint<dynamic> point = tooltipArgs.dataPoints![index];
                  num surplus = point.y;
                  // Setting the tooltip header
                  tooltipArgs.header = surplus >= 0 ? 'Surplus' : 'Deficit';
                  // Setting the tooltip text
                  tooltipArgs.text = '${point.x}: ${surplus.toStringAsFixed(2)}';
                }
              },
              series: <ChartSeries<DailySurplusData, String>>[
                SplineSeries(
                  dataSource: snapshot.data!,
                  xValueMapper: (DailySurplusData record, _) => '${Constant.monthLabels[record.date.month - 1]} ${record.date.day}',
                  yValueMapper: (DailySurplusData record, _) => record.surplus,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelAlignment: ChartDataLabelAlignment.top,
                  ),
                  dataLabelMapper: (DailySurplusData record, _) => record.surplus.toStringAsFixed(2),
                  splineType: SplineType.cardinal,
                  markerSettings: const MarkerSettings(isVisible: true),
                  name: 'Daily Surplus or Deficit',
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
