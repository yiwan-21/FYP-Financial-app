import 'package:flutter/material.dart';

import '../components/budget_chart.dart';
import '../components/history_card.dart';
import '../components/alert_confirm_action.dart';
import '../pages/edit_budget.dart';
import '../services/budget_service.dart';
import '../services/transaction_service.dart';

class BudgetDetail extends StatefulWidget {
  final String category;
  final double amount;
  final double used;

  const BudgetDetail(
      {required this.category,
      required this.amount,
      required this.used,
      super.key});

  @override
  State<BudgetDetail> createState() => _BudgetDetailState();
}

class _BudgetDetailState extends State<BudgetDetail> {
  double _amountLeft = 0;

  @override
  void initState() {
    super.initState();
    _amountLeft = widget.amount - widget.used;
  }

  Future<void> _deleteBudget() async {
    await BudgetService.deleteBudget(widget.category).then((_) {
      // close alert dialog
      Navigator.pop(context);
      // back to budgeting page
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
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
        physics: const BouncingScrollPhysics(),
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
                            'RM ${widget.amount.toStringAsFixed(2)}',
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
          FutureBuilder(
              future: TransactionService.getHistoryCards(
                  widget.category, BudgetService.startingDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No spending within budgeting date range yet'),
                  );
                }

                List<HistoryCard> historyCards = snapshot.data!;
                List<BudgetChartData> budgetData = [];
                DateTime startDate = BudgetService.startingDate;
                int days = DateTime.now().difference(startDate).inDays + 1;
                List<double> dailyAmount = List.filled(days, 0);
                for (var card in historyCards) {
                  final date = BudgetService.getOnlyDate(card.date);
                  final amount = card.amount;
                  int index = date.difference(startDate).inDays;
                  dailyAmount[index] += amount;
                }
                for (int i = 0; i < days; i++) {
                  budgetData.add(BudgetChartData(dailyAmount[i], startDate.add(Duration(days: i))));
                }
                // final Map<DateTime, double> totalAmountPerDate = {};
                
                // for (var card in historyCards) {
                //   final date = BudgetService.getOnlyDate(card.date);
                //   final amount = card.amount;

                //   if (totalAmountPerDate.containsKey(date)) {
                //     totalAmountPerDate[date] = totalAmountPerDate[date]! + amount;
                //   } else {
                //     totalAmountPerDate[date] = amount;
                //   }
                // }
                // budgetData = totalAmountPerDate.entries.map((entry) {
                //   return BudgetChartData(entry.value, entry.key);
                // }).toList();

                
                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    const Text(
                      'Daily Spending',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    BudgetChart(budgetData),
                    const SizedBox(height: 24),
                    Wrap(
                      verticalDirection: VerticalDirection.up,
                      children: List.generate(historyCards.length, (index) {
                        return historyCards[index];
                      }),
                    ),
                  ],
                );
              }),
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
