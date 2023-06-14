import 'package:financial_app/providers/goalProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Goal extends StatefulWidget {
  final String goalId;
  final String userID;
  final String title;
  final double amount;
  final double saved;
  final DateTime targetDate;
  final bool pinned;

  const Goal(this.goalId, this.userID, this.title, this.amount, this.saved,
      this.targetDate, this.pinned,
      {super.key});

  @override
  State<Goal> createState() => _GoalState();

  Map<String, dynamic> toCollection() {
    return {
      'userID': userID,
      'title': title,
      'amount': amount,
      'saved': saved,
      'targetDate': targetDate,
      'pinned': pinned,
    };
  }
}

class _GoalState extends State<Goal> {
  double _saved = 0;
  bool _pinned = false;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _saved = widget.saved;
    _pinned = widget.pinned;
    _progress = widget.saved / widget.amount;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final GoalProvider goalProvider =
            Provider.of<GoalProvider>(context, listen: false);
        goalProvider.setGoal(
          widget.goalId,
          widget.title,
          widget.amount,
          _saved,
          widget.targetDate,
          _pinned,
        );
        Navigator.pushNamed(context, '/goal/progress').then((_) => {
              _saved = goalProvider.getSaved,
              _pinned = goalProvider.getPinned,
              setState(() {
                _progress = _saved / widget.amount;
              }),
            });
      },
      child: Card(
        elevation: 5,
        color: Colors.white,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          alignment: Alignment.centerLeft,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'RM ${widget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: Container(
                        margin: const EdgeInsets.only(top: 30, bottom: 10),
                        height: 5.2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                                _progress == 1
                                    ? Colors.green[400]!
                                    : const Color.fromRGBO(246, 214, 153, 1)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.targetDate.toString().substring(0, 10),
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
