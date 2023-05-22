import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Analytics extends StatelessWidget {
  const Analytics({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ChartData> data = [
      ChartData('Jan', 35, 11),
      ChartData('Feb', 28, 22),
      ChartData('Mar', 34, 30),
      ChartData('Apr', 32, 70),
      ChartData('May', 40, 60)
    ];

    final List<ChartData2> data2 = [
      ChartData2('Jan', 50, 55),
      ChartData2('Feb', 80, 75),
      ChartData2('Mar', 35, 45),
      ChartData2('Apr', 65, 50),
    ];

    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 24),
          SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            // Chart title
            title: ChartTitle(text: 'Monthly Expense and Income'),
            // Enable legend
            legend: Legend(isVisible: true),
            // Enable tooltip
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <ChartSeries<ChartData, String>>[
              LineSeries<ChartData, String>(
                  dataSource: data,
                  xValueMapper: (ChartData record, _) => record.month,
                  yValueMapper: (ChartData record, _) => record.expense,
                  name: 'Expense',
                  // Enable data label
                  dataLabelSettings: const DataLabelSettings(isVisible: true)),
              LineSeries<ChartData, String>(
                  dataSource: data,
                  xValueMapper: (ChartData record, _) => record.month,
                  yValueMapper: (ChartData record, _) => record.income,
                  name: 'Income',
                  // Enable data label
                  dataLabelSettings: const DataLabelSettings(isVisible: true)),
            ],
          ),
          const SizedBox(height: 24),
          SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            // Chart title
            title: ChartTitle(
                text: 'Ratio of Autonomous to Discretionary Expenses'),
            // Enable legend
            legend: Legend(isVisible: true),
            // Enable tooltip
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <ChartSeries<ChartData2, String>>[
              StackedColumnSeries(
                dataSource: data2,
                xValueMapper: (ChartData2 record2, _) => record2.month,
                yValueMapper: (ChartData2 record2, _) => record2.autonomous,
                name: 'Autonomous',
              ),
              StackedColumnSeries(
                dataSource: data2,
                xValueMapper: (ChartData2 record2, _) => record2.month,
                yValueMapper: (ChartData2 record2, _) => record2.discretionary,
                name: 'Discretionary',
              ),
            ],
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 768),
            child: const Center(
              child: Card(
                elevation: 5,
                color: Colors.white,
                child: 
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Autonommous Expenditure: Food, Transportation, Rental, Bill\nDiscretionary Expenditure: Education, Personal Items, Other Expenses',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.month, this.expense, this.income);

  final String month;
  final double expense;
  final double income;
}

class ChartData2 {
  ChartData2(this.month, this.autonomous, this.discretionary);
  final String month;
  final num autonomous;
  final num discretionary;
}
