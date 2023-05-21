import 'package:flutter/material.dart';
import '../components/monthlySpendingChart.dart';

class Analytics extends StatelessWidget {
  const Analytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        children: const [
          SizedBox(height: 24),
          Text(
            "Monthly Spending",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          MonthlySpendingChart(),
        ],
      ),
    );
  }
}
