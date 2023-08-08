import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/total_goal_provider.dart';
import '../constants/style_constant.dart';

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
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.data != null) {
                        return Wrap(
                            children:
                                List.generate(snapshot.data!.length, (index) {
                          return snapshot.data![index];
                        }));
                      } else {
                        return Container();
                      }
                    }),
                  );
                }),
              ],
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            margin: const EdgeInsets.only(bottom: 20, right: 10),
            child: FloatingActionButton(
              backgroundColor: ColorConstant.lightBlue,
              onPressed: () {
                Navigator.pushNamed(context, '/goal/add');
              },
              child: const Icon(
                Icons.add,
                size: 27,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}