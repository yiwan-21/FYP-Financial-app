import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../services/debt_service.dart';

class MonitorDebtData {
  double paidAmount;
  double balance;
  final String debtName;

  MonitorDebtData(this.paidAmount, this.balance, this.debtName);

  void findPaid() {
    paidAmount = paidAmount - balance;
  }
}

class MonitorDebtChart extends StatefulWidget {
  const MonitorDebtChart({super.key});

  @override
  State<MonitorDebtChart> createState() => _MonitorDebtChartState();
}

class _MonitorDebtChartState extends State<MonitorDebtChart> {
  final Future<List<MonitorDebtData>> _barData = DebtService.getBarData();

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
              title: ChartTitle(text: 'Debt Progress'),
              // Enable legend
              legend: Legend(isVisible: true),
              // Enable tooltip
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries<MonitorDebtData, String>>[
                StackedBarSeries(
                  dataSource: snapshot.data!,
                  xValueMapper: (MonitorDebtData record, _) => record.debtName,
                  yValueMapper: (MonitorDebtData record, _) => record.paidAmount,
                  borderRadius: const BorderRadius.only( topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                  width: snapshot.data!.length == 1 ? 0.3 : 0.8,
                  name: 'Total Paid',
                ),
                StackedBarSeries(
                  dataSource: snapshot.data!,
                  xValueMapper: (MonitorDebtData record, _) => record.debtName,
                  yValueMapper: (MonitorDebtData record, _) => record.balance,
                  borderRadius: const BorderRadius.only( topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
                  pointColorMapper: (MonitorDebtData record, _) =>const Color.fromRGBO(198, 201, 207, 1),
                  color: const Color.fromRGBO(198, 201, 207, 1),
                  width: snapshot.data!.length == 1 ? 0.3 : 0.8,
                  name: 'Balance',
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
