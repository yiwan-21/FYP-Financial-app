import 'package:financial_app/providers/totalGoalProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/goal.dart';

class SavingsGoal extends StatefulWidget {
  const SavingsGoal({super.key});
  @override
  State<SavingsGoal> createState() => _SavingsGoalState();
}

class _SavingsGoalState extends State<SavingsGoal> {
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
                Consumer<TotalGoalProvider>(
                  builder: (context, totalGoalProvider, _) {
                    return FutureBuilder(
                      future: totalGoalProvider.getGoals,
                      builder: ((context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                          return Wrap(
                            children: List.generate(
                              snapshot.data!.length,
                              (index) {
                                return snapshot.data![index];
                              }
                            )
                          );
                        } else {
                          return Container();
                        }
                      }),
                    );
                  }
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
                      // Provider.of<TotalGoalProvider>(context, listen: false).updateGoals();
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
