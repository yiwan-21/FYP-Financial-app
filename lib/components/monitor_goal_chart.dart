import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../providers/total_goal_provider.dart';

class MonitorGoalData {
  final String month;
  num completed;
  num inProgress;
  num toDo;
  num expired;

  void addComplete(num completed) {
    this.completed += completed;
  }

  void addInProgress(num inProgress) {
    this.inProgress += inProgress;
  }

  void addToDo(num toDo) {
    this.toDo += toDo;
  }

  void addExpired(num expired) {
    this.expired += expired;
  }

  MonitorGoalData(
      this.month, this.completed, this.inProgress, this.toDo, this.expired);
}

class MonitorGoalChart extends StatefulWidget {
  const MonitorGoalChart({super.key});

  @override
  State<MonitorGoalChart> createState() => _MonitorGoalChartState();
}

class _MonitorGoalChartState extends State<MonitorGoalChart> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TotalGoalProvider>(
      builder: (context, totalGoalProvider, _) {
        final List<MonitorGoalData> lineData = totalGoalProvider.getMonitorGoalData();
        return SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          // Chart title
          title: ChartTitle(text: 'Number of Goals in Different Status'),
          // Enable legend
          legend: Legend(isVisible: true),
          // Enable tooltip
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <ChartSeries<MonitorGoalData, String>>[
            LineSeries(
              dataSource: lineData,
              xValueMapper: (MonitorGoalData record, _) => record.month,
              yValueMapper: (MonitorGoalData record, _) => record.completed,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              name: 'Completed',
            ),
            LineSeries(
              dataSource: lineData,
              xValueMapper: (MonitorGoalData record, _) => record.month,
              yValueMapper: (MonitorGoalData record, _) =>
                  record.inProgress,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              name: 'In Progress',
            ),
            LineSeries(
              dataSource: lineData,
              xValueMapper: (MonitorGoalData record, _) => record.month,
              yValueMapper: (MonitorGoalData record, _) => record.toDo,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              name: 'To-Do',
            ),
            LineSeries(
              dataSource: lineData,
              xValueMapper: (MonitorGoalData record, _) => record.month,
              yValueMapper: (MonitorGoalData record, _) => record.expired,
              dataLabelSettings: const DataLabelSettings(isVisible: true),
              name: 'Expired',
            ),
          ],
        );
      },
    );
  }
}
