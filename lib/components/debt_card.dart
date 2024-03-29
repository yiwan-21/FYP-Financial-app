import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/services/debt_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/constant.dart';
import '../constants/route_name.dart';
import '../pages/manage_debt.dart';
import '../services/transaction_service.dart';
import '../components/alert_with_checkbox.dart';
import '../components/tracker_transaction.dart';

class DebtCard extends StatefulWidget {
  final String id;
  final String title;
  final int duration; // in months
  final double amount;
  final double interests;
  final List<Map<String, dynamic>> history;
  final int remainingDuration; // in months
  final bool paid;

  const DebtCard(
      {required this.id,
      required this.title,
      required this.duration,
      required this.amount,
      required this.interests,
      required this.history,
      required this.remainingDuration,
      required this.paid,
      super.key});

  DebtCard.fromDocument(QueryDocumentSnapshot doc, {super.key})
      : id = doc.id,
        title = doc['title'],
        duration = doc['duration'],
        amount = doc['amount'].toDouble(),
        interests = doc['interest'].toDouble(),
        history = List<Map<String, dynamic>>.from(doc['history']),
        remainingDuration = doc['duration'] -
            getDifferenceInMonths(doc['created_at'].toDate(), DateTime.now()),
        paid = doc['paid'];

  double get plan {
    return interests == 0
        ? double.parse((amount / duration).toStringAsFixed(2))
        : double.parse(((amount * ((interests / 100) / 12)) /
                (1 - pow((1 + (interests / 100) / 12), (-12 * duration / 12))))
            .toStringAsFixed(2));
  }

  static int getDifferenceInMonths(DateTime createdDate, DateTime currentDate) {
    return createdDate.month -
        ((currentDate.year - createdDate.year) * 12 + currentDate.month);
  }

  @override
  State<DebtCard> createState() => _DebtCardState();
}

class _DebtCardState extends State<DebtCard> {
  int _year = 0;
  int _month = 0;
  int _remainYear = 0;
  int _remainMonth = 0;
  bool get _isMobile => Constant.isMobile(context);

  void calculateDuration() {
    setState(() {
      _year = widget.duration ~/ 12;
      _month = widget.duration % 12;
      _remainYear = widget.remainingDuration ~/ 12;
      _remainMonth = widget.remainingDuration % 12;
    });
  }

  void _editDebt() {
    if (Constant.isMobile(context) && !kIsWeb) {
      Navigator.pushNamed(context, RouteName.manageDebt, arguments: {
        'isEditing': true,
        'id': widget.id,
        'title': widget.title,
        'amount': widget.amount,
        'interest': widget.interests,
        'year': _year,
        'month': _month,
      });
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return ManageDebt(
            true,
            id: widget.id,
            title: widget.title,
            amount: widget.amount,
            interest: widget.interests,
            year: _year,
            month: _month,
          );
        },
      );
    }
  }

  void _payDebtDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertWithCheckbox(
            title: 'Pay the debt',
            contentLabel: 'Amount',
            checkboxLabel: 'Add an expense record',
            defaultChecked: true,
            defaultValue: widget.plan,
            onSaveFunction: _payDebt,
            checkedFunction: _addTransactionRecord,
            confirmButtonLabel: 'Pay',
            maxValue: _getMaxValue(),
          );
        });
  }

  double _getMaxValue() {
    if (widget.history.isNotEmpty) {
      return widget.history.last['balance'];
    }
    return widget.amount;
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
    await TransactionService.addTransaction(newTransaction);
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
                    overflow: TextOverflow.visible,
                  ),
                ),
                const Spacer(),
                if (!_isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Monthly plan: RM ${widget.plan.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                      Text(
                        'Total: RM ${widget.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.brown[200],
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ],
                  ),
                IconButton(
                  iconSize: 20,
                  splashRadius: 10,
                  onPressed: _editDebt,
                  icon: const Icon(Icons.edit),
                  color: Colors.brown,
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.all(0),
                ),
              ],
            ),
            if (_isMobile)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    Text(
                      'Monthly plan: RM ${widget.plan.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    Text(
                      'Total: RM ${widget.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.brown[200],
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 3),
                Text('Debt Duration: $_year years $_month months'),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.timer_outlined, size: 20),
                const SizedBox(width: 3),
                Text(
                    'Remaining Duration: $_remainYear years $_remainMonth months'),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_graph_rounded, size: 20),
                const SizedBox(width: 3),
                Text('Interests: ${widget.interests}%'),
                const Spacer(),
                if ((widget.history.isEmpty || widget.history.last['balance'] >= 0))
                  GestureDetector(
                    onTap: widget.paid ? null : _payDebtDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.brown,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            "Pay Debt",
                            style: TextStyle(
                              color: Colors.brown,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 10),
                          widget.paid
                            ? const Icon(Icons.check_circle_outlined, size: 20, color: Colors.green)
                            : const Icon(Icons.payment_sharp, size: 20, color: Colors.brown),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            if (widget.history.isNotEmpty)
              const Divider(thickness: 1, height: 30),
            if (widget.history.isNotEmpty)
              Table(
                columnWidths: const <int, TableColumnWidth>{
                  0: FixedColumnWidth(80),
                },
                children: [
                  const TableRow(
                    children: [
                      Text(''),
                      Text(
                        'Interest',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Principal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Total Paid',
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
                    SizedBox(height: 5),
                    SizedBox(height: 5),
                  ]),
                  for (final row in widget.history.reversed)
                    TableRow(
                      children: [
                        Text(
                            '${Constant.monthLabels[row['date'].toDate().month - 1]} ${row['date'].toDate().day}'),
                        Text(
                          row['interest'].toStringAsFixed(2),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          row['principal'].toStringAsFixed(2),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          (row['interest'] + row['principal'])
                              .toStringAsFixed(2),
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
