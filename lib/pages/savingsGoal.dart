import 'package:financial_app/firebaseInstance.dart';
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
  final List<Goal> _goals = [];

  Future<List<Goal>> _getGoals() async {
    final List<Goal> goalData = [];
    await FirebaseInstance.firestore.collection('goals')
      .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
      .orderBy('targetDate', descending: false)
      .get()
      .then((goals) => {
        for (var goal in goals.docs) {
          goalData.add(Goal(
            goal.id,
            goal['userID'],
            goal['title'],
            goal['amount'].toDouble(),
            goal['saved'].toDouble(),
            goal['targetDate'].toDate(),
            goal['pinned'],
          )),
        }
      });
    return goalData;
  }

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
                FutureBuilder(
                  future: _getGoals(),
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
