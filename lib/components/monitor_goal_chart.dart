import 'package:financial_app/services/goal_service.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
  final Future<List<MonitorGoalData>> _lineData = GoalService.getlineData();

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
              title: ChartTitle(text: 'Number of Goals in Different Status'),
              // Enable legend
              legend: Legend(isVisible: true),
              // Enable tooltip
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries<MonitorGoalData, String>>[
                LineSeries(
                  dataSource: snapshot.data!,
                  xValueMapper: (MonitorGoalData record, _) => record.month,
                  yValueMapper: (MonitorGoalData record, _) => record.completed,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  name: 'Completed',
                ),
                LineSeries(
                  dataSource: snapshot.data!,
                  xValueMapper: (MonitorGoalData record, _) => record.month,
                  yValueMapper: (MonitorGoalData record, _) =>
                      record.inProgress,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  name: 'In Progress',
                ),
                LineSeries(
                  dataSource: snapshot.data!,
                  xValueMapper: (MonitorGoalData record, _) => record.month,
                  yValueMapper: (MonitorGoalData record, _) => record.toDo,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  name: 'To-Do',
                ),
                LineSeries(
                  dataSource: snapshot.data!,
                  xValueMapper: (MonitorGoalData record, _) => record.month,
                  yValueMapper: (MonitorGoalData record, _) => record.expired,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  name: 'Expired',
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
