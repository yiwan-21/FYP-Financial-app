import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../firebase_instance.dart';

const int MONTH_COUNT = 5;
const List<String> AUTONOMOUS = ['Food', 'Transportation', 'Rental', 'Bill'];

class Analytics extends StatelessWidget {
  const Analytics({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 24),
          const ExpenseIncomeGraph(),
          const SizedBox(height: 24),
          const AutoDisChart(),
          Container(
            constraints: const BoxConstraints(maxWidth: 768),
            child: const Center(
              child: Card(
                elevation: 5,
                color: Colors.white,
                child: Padding(
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

class IncomeExpenseData {
  IncomeExpenseData(this.month, this.expense, this.income);

  final String month;
  double expense;
  double income;

  void addExpense(double expense) {
    this.expense += expense;
  }

  void addIncome(double income) {
    this.income += income;
  }
}

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

class ExpenseIncomeGraph extends StatefulWidget {
  const ExpenseIncomeGraph({super.key});

  @override
  State<ExpenseIncomeGraph> createState() => _ExpenseIncomeGraphState();
}

class _ExpenseIncomeGraphState extends State<ExpenseIncomeGraph> {
  Future<List<IncomeExpenseData>> _lineData = Future.value([]);
  
  @override
  void initState() {
    super.initState();
    _lineData = _getLineData();
  }  

  Future<List<IncomeExpenseData>> _getLineData() async {
    final List<IncomeExpenseData> lineData = [];
    // fill lineData with IncomeExpenseData objects
    final month = DateTime.now().month;
    for (int i = month - (MONTH_COUNT - 1) - 1; i < month; i++) {
      lineData.add(IncomeExpenseData(Constants.monthLabels[i], 0, 0));
    }
    int monthIndex = 0;
    await FirebaseInstance.firestore.collection('transactions')
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .orderBy('date', descending: true)
        .get()
        .then((value) => {
          for (var transaction in value.docs) {
            monthIndex = DateTime.parse(transaction['date'].toDate().toString()).month - (DateTime.now().month - (MONTH_COUNT - 1)),
            if (monthIndex >= 0) {
              if (transaction['isExpense']) {
                lineData[monthIndex].addExpense(transaction['amount'].toDouble())
              } else {
                lineData[monthIndex].addIncome(transaction['amount'].toDouble())
              }
            }
          }
        });
    return lineData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _lineData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
          return SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  // Chart title
                  title: ChartTitle(text: 'Monthly Expense and Income'),
                  // Enable legend
                  legend: Legend(isVisible: true),
                  // Enable tooltip
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <ChartSeries<IncomeExpenseData, String>>[
                    LineSeries<IncomeExpenseData, String>(
                        dataSource: snapshot.data!,
                        xValueMapper: (IncomeExpenseData record, _) => record.month,
                        yValueMapper: (IncomeExpenseData record, _) => record.expense,
                        name: 'Expense',
                        // Enable data label
                        dataLabelSettings: const DataLabelSettings(isVisible: true)),
                    LineSeries<IncomeExpenseData, String>(
                        dataSource: snapshot.data!,
                        xValueMapper: (IncomeExpenseData record, _) => record.month,
                        yValueMapper: (IncomeExpenseData record, _) => record.income,
                        name: 'Income',
                        // Enable data label
                        dataLabelSettings: const DataLabelSettings(isVisible: true)),
                  ],
                );
        } else {
          return const Center(
            child: CircularProgressIndicator()
          );
        }
      }
    );
  }
}

class AutoDisChart extends StatefulWidget {
  const AutoDisChart({super.key});

  @override
  State<AutoDisChart> createState() => _AutoDisChartState();
}

class _AutoDisChartState extends State<AutoDisChart> {
  Future<List<AutoDisData>> _barData = Future.value([]);

  @override
  void initState() {
    super.initState();
    _barData = _getBarData();
  }

  Future<List<AutoDisData>> _getBarData() async {
    final List<AutoDisData> barData = [];
    // fill barData with AutoDisData objects
    final month = DateTime.now().month;
    for (int i = month - (MONTH_COUNT - 1) - 1; i < month; i++) {
      barData.add(AutoDisData(Constants.monthLabels[i], 0, 0));
    }
    int monthIndex = 0;
    await FirebaseInstance.firestore.collection('transactions')
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .orderBy('date', descending: true)
        .get()
        .then((value) => {
          for (var transaction in value.docs) {
             monthIndex = DateTime.parse(transaction['date'].toDate().toString()).month - (DateTime.now().month - (MONTH_COUNT - 1)),
            if (monthIndex >= 0 && transaction['isExpense']) {
              if (AUTONOMOUS.contains(transaction['category'])) {
                barData[monthIndex].addAutonomous(transaction['amount'].toDouble())
              } else {
                barData[monthIndex].addDiscretionary(transaction['amount'].toDouble())
              }
            }
          }
        });
    return barData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _barData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
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
                      yValueMapper: (AutoDisData record2, _) => record2.discretionary,
                      name: 'Discretionary',
                    ),
                  ],
                );
        } else {
          return const Center(
            child: CircularProgressIndicator()
          );
        }
      }
    );
  }
}