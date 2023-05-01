import 'package:flutter/material.dart';
import '../constants.dart';

class Goal extends StatefulWidget {
  final String goalId;
  final String goalTitle;
  final double amount;
  final DateTime date;

  const Goal(this.goalId, this.goalTitle, this.amount, this.date, {super.key});

  @override
  State<Goal> createState() => _GoalState();
}

class _GoalState extends State<Goal> {
  final double _progress = 0.5;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: Colors.white,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.goalTitle,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: 15,
                  width: Constants.isMobile(context) ? 200 : 400,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: Colors.grey[200],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                )
              ],
            ),
            Text(
              widget.amount.toStringAsFixed(2),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
