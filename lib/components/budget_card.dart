import 'package:flutter/material.dart';

import '../components/custom_circular_progress.dart';
import '../constants/route_name.dart';

class BudgetCard extends StatefulWidget {
  final String category;
  final double amount;
  final double used;

  const BudgetCard(this.category, this.amount, this.used, {super.key});

  @override
  State<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<BudgetCard> {
  double _progress = 0;
  @override
  void initState() {
    super.initState();
    _progress = widget.used / widget.amount;
    if (_progress > 1) {
      _progress = 1;
    }
  }

  void _detail() {
    Navigator.pushNamed(context, RouteName.budgetDetail, arguments: {
      'category': widget.category,
    }).then((_) {
      setState(() {
        _progress = widget.used / widget.amount;
        if (_progress > 1) {
          _progress = 1;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _detail,
      child: Card(
        elevation: 2,
        color: Colors.white,
        margin: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 8,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 30, bottom: 25, right: 70, left: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'RM ${widget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              //circular progress here
              CustomPaint(
                painter: CustomCircularProgress(
                  value: _progress,
                  strokeWidth: 5,
                  radius: 60,
                  startAngle: 180,
                  sweepAngle: 180,
                  heightMultiply: 1.6,
                  widthMultiply: 2,
                  colors: _progress >= 1
                      ? <Color>[Colors.red,Colors.red]
                      : <Color>[ Colors.yellow, Colors.orange,Colors.red ],
                ),
                child: Text(
                  '${(_progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
