import 'package:flutter/material.dart';
import '../constants.dart';
import '../components/growingTree.dart';
import '../components/goal.dart';

class SavingsGoal extends StatefulWidget {
  const SavingsGoal({super.key});
  @override
  State<SavingsGoal> createState() => _SavingsGoalState();
}

class _SavingsGoalState extends State<SavingsGoal> {
  // List<double> _progressList = [1];
  final List<Goal> _goals = [
    Goal('G1', 'Buy Food', 49.99, 30.00, DateTime.now()),
    Goal('G2', 'Trip', 2000.00, 500.00, DateTime.now()),
    Goal('G3', 'Sleep', 69.98, 10.00, DateTime.now()),
  ];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 768,
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                const SizedBox(height: 12),
                Wrap(
                  children: List.generate(
                    _goals.length,
                    (index) {
                      return _goals[index];
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              backgroundColor: Colors.grey,
              onPressed: () {
                Navigator.pushNamed(context, '/goal/add')
                  .then((goal) {
                    if (goal != null && goal is Goal) {
                      setState(() {
                        _goals.add(goal);
                      });
                    }
                  });
              },
              child: const Icon(Icons.add, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}
