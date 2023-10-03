import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/constant.dart';

class HistoryCard extends StatelessWidget {
  final double amount;
  final DateTime date;

  const HistoryCard(this.amount, this.date, {super.key});

  HistoryCard.fromDocument(QueryDocumentSnapshot doc, {super.key})
      : amount = doc['amount'].toDouble(),
        date = doc['date'].toDate();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: Constant.isMobile(context)
          ? const EdgeInsets.only(left: 12, right: 12, bottom: 12)
          : const EdgeInsets.only(left: 12, right: 12, bottom: 20),
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date.toString().substring(0, 10),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '+ ${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            )
          ],
        ),
      ),
    );
  }
}