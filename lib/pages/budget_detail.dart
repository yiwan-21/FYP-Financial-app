import 'package:flutter/material.dart';

import '../constants/style_constant.dart';
import '../components/budget_chart.dart';
import '../components/history_card.dart';
import '../components/alert_confirm_action.dart';
import '../pages/edit_budget.dart';

class BudgetDetail extends StatefulWidget {
  const BudgetDetail({super.key});

  @override
  State<BudgetDetail> createState() => _BudgetDetailState();
}

class _BudgetDetailState extends State<BudgetDetail> {
  double _amount = 100;
  double _usedAmount = 95;
  double _amountLeft = 0;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _amountLeft = _amount - _usedAmount;
    _progress = _usedAmount / _amount;
  }

  void _deleteBudget() {}

  @override
  Widget build(BuildContext context) {
    List<HistoryCard> _history = [HistoryCard(20, DateTime.now())];
    return Scaffold(
      appBar: AppBar(
        //TODO: dynamic category name
        title: const Text('CategoryName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const EditBudget();
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertConfirmAction(
                    title: 'Delete Budget',
                    content: 'Are you sure you want to delete this budget?',
                    cancelText: 'Cancel',
                    confirmText: 'Delete',
                    confirmAction: _deleteBudget,
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: const Color.fromARGB(255, 255, 220, 225),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: CustomPaint(
                  foregroundPainter: LinePainter(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'RM ${_amountLeft.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'RM ${_amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Daily Spending',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const BudgetGraph(),
          const SizedBox(height: 24),
          Wrap(
            children: List.generate(_history.length, (index) {
              return _history[index];
            }),
          ),
        ],
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sector = size.width / 3;
    final upper = Offset(sector * 2, 0);
    final lower = Offset(sector * 1, size.height);
    final paint = Paint()
      ..color = const Color.fromARGB(255, 255, 190, 195)
      ..strokeWidth = 3;
    canvas.drawLine(upper, lower, paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) => false;
}
