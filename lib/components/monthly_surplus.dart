import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../providers/transaction_provider.dart';
import '../components/tracker_overview_chart.dart';

class MonthlySurplusGraph extends StatefulWidget {
  const MonthlySurplusGraph({super.key});

  @override
  State<MonthlySurplusGraph> createState() => _MonthlySurplusGraphState();
}

class _MonthlySurplusGraphState extends State<MonthlySurplusGraph> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, _) {
       final List<TrackerOverviewData> lineData = transactionProvider.getTrackerOverviewData();

        return SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          // Chart title
          title: ChartTitle(text: 'Monthly Surplus or Deficit'),
          // Enable tooltip
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <ChartSeries<TrackerOverviewData, String>>[
            LineSeries<TrackerOverviewData, String>(
                dataSource: lineData,
                xValueMapper: (TrackerOverviewData record, _) => record.month,
                yValueMapper: (TrackerOverviewData record, _) => record.income - record.expense,
                name: '',
            ),
          ],
        );
      },
    );
  }
}
