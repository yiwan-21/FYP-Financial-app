import 'package:flutter/material.dart';

import '../constants/constant.dart';
import '../components/tracker_overview_chart.dart';
import '../components/auto_dis_chart.dart';
import '../components/monitor_debt_chart.dart';
import '../components/monitor_goal_chart.dart';
import '../components/daily_surplus_chart.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  @override
  Widget build(BuildContext context) {
    bool isMobile = Constant.isMobile(context);
    const double verticalSpacing = 24.0;

    Widget buildCard() {
      return const Center(
        child: Card(
          elevation: 5,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Autonomous Expenditure: Food, Transportation, Rental, Bill\nDiscretionary Expenditure: Education, Personal Items, Other Expenses',
            ),
          ),
        ),
      );
    }

    Widget landscapeLayout() {
      return Column(
        children: [
          Row(
            children: [
              const Expanded(child: TrackerOverviewGraph()),
              Expanded(
                child: Column(
                  children: [
                    const AutoDisChart(),
                    buildCard(),
                  ],
                ),
              ),
            ],
          ),
          const Row(
            children: [
              Expanded(child: MonitorGoalChart()),
              Expanded(child: MonitorDebtChart()),
            ],
          ),
        ],
      );
    }

    Widget portraitLayout() {
      return Column(
        children: [
          const TrackerOverviewGraph(),
          const SizedBox(height: verticalSpacing),
          const AutoDisChart(),
          buildCard(),
          const SizedBox(height: verticalSpacing),
          const MonitorGoalChart(),
          const SizedBox(height: verticalSpacing),
          const MonitorDebtChart(),
        ],
      );
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            children: [
              const SizedBox(height: verticalSpacing),
              isMobile ? portraitLayout() : landscapeLayout(),
              const SizedBox(height: verticalSpacing),
              const DailySurplusChart(),
              const SizedBox(height: verticalSpacing),
            ],
          );
        },
      ),
    );
  }
}
