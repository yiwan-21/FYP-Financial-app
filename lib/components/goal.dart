import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/route_name.dart';
import '../firebase_instance.dart';
import '../providers/goal_provider.dart';
import '../services/goal_service.dart';
import '../utils/date_utils.dart';

class Goal extends StatefulWidget {
  final String id;
  final String title;
  final double amount;
  final double saved;
  final DateTime targetDate;
  final bool pinned;
  final DateTime createdAt;

  const Goal(
    {required this.id, 
    required this.title, 
    required this.amount, 
    required this.saved,
    required this.targetDate, 
    required this.pinned,
    required this.createdAt,
    super.key});

  Goal.fromDocument(QueryDocumentSnapshot doc, {super.key})
      : id = doc.id,
        title = doc['title'],
        amount = doc['amount'].toDouble(),
        saved = doc['saved'].toDouble(),
        targetDate = doc['targetDate'].toDate(),
        pinned = doc['pinned'],
        createdAt = doc['created_at'].toDate();
  
  Goal.fromSnapshot(DocumentSnapshot doc, {super.key})
      : id = doc.id,
        title = doc['title'],
        amount = doc['amount'].toDouble(),
        saved = doc['saved'].toDouble(),
        targetDate = doc['targetDate'].toDate(),
        pinned = doc['pinned'],
        createdAt = doc['created_at'].toDate();

  @override
  State<Goal> createState() => _GoalState();

  Map<String, dynamic> toFirestoreDocument() {
    return {
      'userID': FirebaseInstance.auth.currentUser!.uid,
      'title': title,
      'amount': amount,
      'saved': saved,
      'targetDate': targetDate,
      'pinned': pinned,
      'created_at': createdAt
    };
  }
}

class _GoalState extends State<Goal> {
  bool get _expired {
    return widget.targetDate.isBefore(getOnlyDate(DateTime.now())) && widget.saved < widget.amount;
  }

  void _navigateToDetail() {
    final GoalProvider goalProvider = Provider.of<GoalProvider>(context, listen: false);
    goalProvider.setGoal(
      widget.id,
      widget.title,
      widget.amount,
      widget.saved,
      widget.targetDate,
      widget.pinned,
      widget.createdAt
    );
    Navigator.pushNamed(context, RouteName.goalProgress).then((_) async {
      if (goalProvider.isPinned != widget.pinned) {
       await GoalService.setPinned(widget.id, goalProvider.isPinned);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double progress = widget.saved / widget.amount;
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
                  Flexible(
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  

                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: widget.pinned ? const Icon(Icons.push_pin) : null,
                      ),
                      Text(
                        'RM ${widget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
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
                            value: progress,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                                progress == 1
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
                      color: _expired? Colors.red : Colors.black,
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
