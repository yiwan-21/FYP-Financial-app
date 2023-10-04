import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../pages/edit_budget.dart';
import '../constants/constant.dart';
import '../components/budget_chart.dart';
import '../components/history_card.dart';
import '../components/alert_confirm_action.dart';
import '../services/budget_service.dart';
import '../services/transaction_service.dart';
import '../utils/date_utils.dart';

class BudgetDetail extends StatefulWidget {
  final String category;

  const BudgetDetail({required this.category, super.key});

  @override
  State<BudgetDetail> createState() => _BudgetDetailState();
}

class _BudgetDetailState extends State<BudgetDetail> {
  final double _maxWidth = 900;
  Future<List<HistoryCard>> _future = Future.value([]);
  Stream<DocumentSnapshot> _stream = const Stream.empty();
  Future<void> _deleteBudget() async {
    await BudgetService.deleteBudget(widget.category).then((_) {
      // close alert dialog
      Navigator.pop(context);
      // back to budgeting page
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _future = TransactionService.getHistoryCards(
          widget.category, BudgetService.startingDate);
      _stream = BudgetService.getSingleBudgetStream(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category),
        actions: [
          IconButton(
            iconSize: Constant.isMobile(context)? 25 : 30,
            icon: const Icon(Icons.edit),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return EditBudget(widget.category);
                },
              );
            },
          ),
          if (!Constant.isMobile(context)) const SizedBox(width: 10),
          IconButton(
            iconSize: Constant.isMobile(context)? 25 : 30,
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
          if (!Constant.isMobile(context)) const SizedBox(width: 15),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: _maxWidth,
              ),
              child: Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: const Color.fromARGB(255, 255, 220, 225),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: CustomPaint(
                      foregroundPainter: LinePainter(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: StreamBuilder<DocumentSnapshot>(
                            stream: _stream,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  snapshot.hasError ||
                                  !snapshot.hasData ||
                                  !snapshot.data!.exists) {
                                return Container();
                              }
                              double total =
                                  snapshot.data!['amount'].toDouble();
                              double used = snapshot.data!['used'].toDouble();
                              return Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'RM ${used.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'RM ${total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                      )),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FutureBuilder(
              future: _future,
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
                  final date = getOnlyDate(card.date);
                  final amount = card.amount;
                  int index = date.difference(startDate).inDays;
                  dailyAmount[index] += amount;
                }
                for (int i = 0; i < days; i++) {
                  budgetData.add(BudgetChartData(
                      dailyAmount[i], startDate.add(Duration(days: i))));
                }

                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    const Text(
                      'Daily Spending',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    BudgetChart(budgetData),
                    const SizedBox(height: 24),
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: _maxWidth,
                        ),
                        child: Wrap(
                          verticalDirection: VerticalDirection.up,
                          children: List.generate(historyCards.length, (index) {
                            return historyCards[index];
                          }),
                        ),
                      ),
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
