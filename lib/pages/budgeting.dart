import 'package:flutter/material.dart';

import '../constants/style_constant.dart';
import '../components/budget_card.dart';
import '../pages/set_budget.dart';

class Budgeting extends StatefulWidget {
  const Budgeting({super.key});

  @override
  State<Budgeting> createState() => _BudgetingState();
}

class _BudgetingState extends State<Budgeting> {
  void setBudget() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const SetBudget();
        });
  }

  @override
  Widget build(BuildContext context) {
    List<BudgetCard> budget = const [
      BudgetCard('Food', 100, 50),
      BudgetCard('Transportation', 100, 70),
      BudgetCard('Food', 200, 200),
    ];
    return Scaffold(
      body: ListView(
        children: List.generate(
          budget.length,
          (index) {
            return budget[index];
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorConstant.lightBlue,
        onPressed: setBudget,
        child: const Icon(
          Icons.note_add_outlined,
          size: 27,
          color: Colors.black,
        ),
      ),
    );
  }
}
