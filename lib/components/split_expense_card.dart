import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/style_constant.dart';
import '../providers/split_money_provider.dart';

class SplitExpenseCard extends StatefulWidget {
  final String id;
  final String title;
  final double totalAmount;
  final bool isSettle;
  final bool isLent;
  final DateTime date;

  const SplitExpenseCard({required this.id, required this.title, required this.totalAmount, required this.isSettle, required this.isLent, required this.date, super.key});

  @override
  State<SplitExpenseCard> createState() => _SplitExpenseCardState();
}

class _SplitExpenseCardState extends State<SplitExpenseCard> {
  void _navigateToExpense() {
    Navigator.of(context).pushNamed('/group/expense', arguments: {'id': widget.id})
      .then((mssg) {
        if (mssg != null) {
          Provider.of<SplitMoneyProvider>(context, listen: false).updateExpenses();
        }
      });
  }

  Text _getIsLentText() {
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
        'You lent',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.green,
        ),
      );
    } else {
      return const Text(
        "You owe",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.red,
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
          margin: const EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 20),
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
                  _getIsLentText(),
                  Text(
                    'RM ${widget.totalAmount.toStringAsFixed(2)}',
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
        ),
      ),
    );
  }
}
