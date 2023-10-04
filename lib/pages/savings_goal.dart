import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/add_goal.dart';
import '../components/goal.dart';
import '../constants/constant.dart';
import '../constants/route_name.dart';
import '../constants/style_constant.dart';
import '../providers/total_goal_provider.dart';

class SavingsGoal extends StatefulWidget {
  const SavingsGoal({super.key});
  @override
  State<SavingsGoal> createState() => _SavingsGoalState();
}

class _SavingsGoalState extends State<SavingsGoal> {
  _navigateToAddGoal() {
    if (Constant.isMobile(context) && !kIsWeb) {
      Navigator.pushNamed(context, RouteName.addGoal);
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AddGoal();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 768,
          ),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: Provider.of<TotalGoalProvider>(context, listen: false)
                    .getGoalsStream,
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
      ),
      floatingActionButton: Constant.isMobile(context)
          ? FloatingActionButton(
              backgroundColor: ColorConstant.lightBlue,
              onPressed: _navigateToAddGoal,
              child: const Icon(
                Icons.add,
                size: 27,
                color: Colors.black,
              ),
            )
          : Stack(
              children: [
                Positioned(
                  right: (MediaQuery.of(context).size.width - 768) / 2,
                  bottom: 5,
                  child: FloatingActionButton(
                    backgroundColor: ColorConstant.lightBlue,
                    onPressed: _navigateToAddGoal,
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
