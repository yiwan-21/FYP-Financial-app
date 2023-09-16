import 'package:financial_app/services/debt_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constant.dart';
import '../constants/route_name.dart';
import '../providers/total_transaction_provider.dart';
import '../services/transaction_service.dart';
import '../components/alert_with_checkbox.dart';
import '../components/tracker_transaction.dart';

class DebtCard extends StatefulWidget {
  final String id;
  final String title;
  final int duration; // in months
  final double amount;
  final double interests;
  final double plan;
  final List<Map<String, dynamic>> history;

  const DebtCard(this.id, this.title, this.duration, this.amount,
      this.interests, this.plan, this.history,
      {super.key});

  @override
  State<DebtCard> createState() => _DebtCardState();
}

class _DebtCardState extends State<DebtCard> {
  int _year = 0;
  int _month = 0;

  void calculateDuration() {
    setState(() {
      _year = widget.duration ~/ 12;
      _month = widget.duration % 12;
    });
  }

  void _editDebt() {
    Navigator.pushNamed(context, RouteName.manageDebt, arguments: {
      'isEditing': true,
      'id': widget.id,
      'title': widget.title,
      'amount': widget.amount,
      'interest': widget.interests,
      'year': _year,
      'month': _month,
    });
  }

  void _payDebtDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertWithCheckbox(
            title: 'Add Amount',
            contentLabel: 'Amount',
            checkboxLabel: 'Add an expense record',
            defaultChecked: true,
            defaultValue: widget.plan,
            onSaveFunction: _payDebt,
            checkedFunction: _addTransactionRecord,
            confirmButtonLabel: 'Pay',
          );
        });
  }

  Future<void> _payDebt(double value) async {
    await DebtService.payDebt(widget.id, value);
  }

  Future<void> _addTransactionRecord(double value) async {
    final TrackerTransaction newTransaction = TrackerTransaction(
      id: '',
      title: 'Debt: ${widget.title}',
      amount: value,
      date: DateTime.now(),
      isExpense: true,
      category: 'Other Expenses',
      notes:
          'Auto Generated: Paid RM ${value.toStringAsFixed(2)} for ${widget.title}',
    );
    await TransactionService.addTransaction(newTransaction).then((_) {
      Provider.of<TotalTransactionProvider>(context, listen: false)
          .updateTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    calculateDuration();
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      color: const Color.fromARGB(255, 255, 250, 234),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total: RM ${widget.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Monthly plan: RM ${widget.plan.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.brown[200],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _editDebt,
                  icon: const Icon(Icons.edit),
                  iconSize: 20,
                  color: Colors.brown,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.all(0),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 3),
                Text('$_year years and $_month months'),
                const Spacer(),
                const Icon(Icons.auto_graph_rounded, size: 20),
                const SizedBox(width: 3),
                Text('Interests: ${widget.interests}%'),
                if(widget.history.isEmpty || widget.history.last['balance'] >=0)
                IconButton(
                  onPressed: _payDebtDialog,
                  icon: const Icon(Icons.payment_sharp),
                  iconSize: 20,
                  color: Colors.brown,
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.all(0),
                ),
              ],
            ),
            const Divider(thickness: 1, height: 10),
            const SizedBox(height: 10),
            Table(
              columnWidths: const <int, TableColumnWidth>{
                0: FixedColumnWidth(80),
              },
              children: [
                const TableRow(
                  children: [
                    Text(''),
                    Text(
                      'Saved Amount',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Balance',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const TableRow(children: [
                  SizedBox(height: 5),
                  SizedBox(height: 5),
                  SizedBox(height: 5),
                ]),
                if (widget.history.isNotEmpty)
                  for (final row in widget.history.reversed)
                    TableRow(
                      children: [
                        Text(
                            '${Constant.monthLabels[row['date'].toDate().month - 1]} ${row['date'].toDate().day}'),
                        Text(
                          row['saved'].toStringAsFixed(2),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          row['balance'].toStringAsFixed(2),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
