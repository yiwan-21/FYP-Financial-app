import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/goal_provider.dart';
import '../providers/total_goal_provider.dart';
import '../services/goal_service.dart';

class Goal extends StatefulWidget {
  final String goalID;
  final String userID;
  final String title;
  final double amount;
  final double saved;
  final DateTime targetDate;
  final bool pinned;

  const Goal(
    {required this.goalID, 
    required this.userID, 
    required this.title, 
    required this.amount, 
    required this.saved,
    required this.targetDate, 
    required this.pinned,
    super.key});

  Goal.fromDocument(QueryDocumentSnapshot doc, {super.key})
      : goalID = doc.id,
        userID = doc['userID'],
        title = doc['title'],
        amount = doc['amount'].toDouble(),
        saved = doc['saved'].toDouble(),
        targetDate = doc['targetDate'].toDate(),
        pinned = doc['pinned'];

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

  bool _expired() {
    return widget.targetDate.isBefore(DateTime.now());
  }

  void _navigateToDetail() {
    final GoalProvider goalProvider = Provider.of<GoalProvider>(context, listen: false);
    goalProvider.setGoal(
      widget.goalID,
      widget.title,
      widget.amount,
      _saved,
      widget.targetDate,
      _pinned,
    );
    Navigator.pushNamed(context, '/goal/progress').then((_) async {
      if (mounted) {
        _saved = goalProvider.getSaved;
        setState(() {
          _progress = _saved / widget.amount;
        });

        _pinned = goalProvider.getPinned;
        final String id = goalProvider.getId;
        if (_pinned) {
          await GoalService.setPinned(id, true).then((_) {
            Provider.of<TotalGoalProvider>(context, listen: false).updateGoals();
          });
        } else {
          await GoalService.updateSinglePinned(id, false).then((_) {
            Provider.of<TotalGoalProvider>(context, listen: false).updateGoals();
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToDetail,
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

                  Row(
                    children: [
                      if (_pinned) 
                        const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.push_pin),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _expired()? Colors.red : Colors.black,
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
