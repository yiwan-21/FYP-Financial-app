import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/goal.dart';
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
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 12),
                StreamBuilder<QuerySnapshot>(
                  stream: Provider.of<TotalGoalProvider>(context, listen: false).getGoalsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No goal yet"));
                    }

                    List<Goal> goals = snapshot.data!.docs
                        .map((doc) => Goal.fromDocument(doc))
                        .toList();
                        
                    return Wrap(
                      children: List.generate(goals.length, (index) {
                        return goals[index];
                      }),
                    );
                  },
                ),
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
