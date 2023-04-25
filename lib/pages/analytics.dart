import 'package:flutter/material.dart';
import '../components/monthlySpendingChart.dart';

class Analytics extends StatelessWidget {
  const Analytics({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      margin: const EdgeInsets.only(top: 24),
      child: Column(
        children: const [
          Text(
            "Monthly Spending",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          MonthlySpendingChart(),
        ],
      ),
    );
  }
}
