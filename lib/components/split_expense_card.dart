import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/route_name.dart';
import '../constants/style_constant.dart';
import '../firebase_instance.dart';
import '../providers/split_money_provider.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';

class SplitExpenseCard extends StatefulWidget {
  final String id;
  final String title;
  final double totalAmount;
  final bool isSettle;
  final bool isLent;
  final String paidBy;
  final DateTime date;

  const SplitExpenseCard({
      required this.id,
      required this.title,
      required this.totalAmount,
      required this.isSettle,
      required this.isLent,
      required this.paidBy,
      required this.date,
      super.key,
    });

  SplitExpenseCard.fromDocument(QueryDocumentSnapshot doc, {super.key})
      : id = doc.id,
        title = doc['title'],
        totalAmount = doc['amount'].toDouble(),
        isSettle = doc['paidAmount'] >= doc['amount'],
        isLent = doc['paidBy'] == 'users/${FirebaseInstance.auth.currentUser!.uid}',
        paidBy = doc['paidBy'].toString().split('/')[1],
        date = doc['date'].toDate();

  @override
  State<SplitExpenseCard> createState() => _SplitExpenseCardState();
}

class _SplitExpenseCardState extends State<SplitExpenseCard> {
  void _navigateToExpense() {
    Navigator.pushNamed(context, RouteName.splitMoneyExpense, arguments: {'id': widget.id, 'tabIndex': 0})
      .then((mssg) {
        if (mssg != null && mounted) {
          Provider.of<SplitMoneyProvider>(context, listen: false).updateExpenses();
        }
        // reset expense ID in chat service
        ChatService.resetExpenseID();
      });
  }

  Future<Text> _getIsLentText() async {
    if (widget.isSettle) {
      return const Text(
        "Settled",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    } else if (widget.isLent) {
      return const Text(
        'You paid',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.red,
        ),
      );
    } else {
      String name = await UserService.getNameByID(widget.paidBy);
      return Text(
        "$name paid",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.green[600],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToExpense,
      child: Card(
        elevation: 4,
        color: widget.isSettle ? Colors.greenAccent[100] : Colors.white,
        child: Container(
          margin:
              const EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: StyleConstant.getPaidIcon(widget.isLent),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.date.toString().substring(0, 10),
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FutureBuilder(
                    future: _getIsLentText(), 
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return snapshot.data!;
                      } else {
                        return const Text(
                          'Total',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        );
                      }
                    },
                  ),
                  if (!widget.isSettle)
                    const SizedBox(height: 5),
                  Text(
                    'RM ${widget.totalAmount.toStringAsFixed(2)}',
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
        ),
      ),
    );
  }
}
