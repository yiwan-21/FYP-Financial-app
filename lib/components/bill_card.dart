import 'package:financial_app/services/bill_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/route_name.dart';
import '../constants/style_constant.dart';
import '../components/alert_with_checkbox.dart';
import '../components/tracker_transaction.dart';
import '../providers/total_transaction_provider.dart';
import '../services/transaction_service.dart';
import '../utils/date_utils.dart';

class BillCard extends StatefulWidget {
  final String id;
  final String title;
  final double amount;
  final bool paid;
  final DateTime dueDate;
  final bool fixed;
  // final Map<DateTime, double> history;

  const BillCard(
      this.id, this.title, this.amount, this.paid, this.dueDate, this.fixed,
      {super.key});

  @override
  State<BillCard> createState() => _BillCardState();
}

class _BillCardState extends State<BillCard> {
  int get dueIn {
    return widget.dueDate.difference(getOnlyDate(DateTime.now())).inDays;
  }

  void _editBill() {
    Navigator.pushNamed(context, RouteName.manageBill, arguments: {
      'isEditing': true,
      'id': widget.id,
      'title': widget.title,
      'amount': widget.amount,
      'date': widget.dueDate,
      'fixed': widget.fixed,
    });
  }

  void _payBillDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertWithCheckbox(
            title: 'Add Amount',
            contentLabel: 'Amount',
            checkboxLabel: 'Add an expense record',
            defaultChecked: true,
            onSaveFunction: _payBill,
            checkedFunction: _checkedFunction,
            confirmButtonLabel: 'Pay',
          );
        });
  }

  Future<void> _payBill(double value) async {
    await BillService.payBill(widget.id, value, widget.fixed);
  }

  Future<void> _checkedFunction(double value) async {
    final TrackerTransaction newTransaction = TrackerTransaction(
      id: '',
      title: 'Bill: ${widget.title}',
      amount: value,
      date: DateTime.now(),
      isExpense: true,
      category: 'Bill',
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
    return Card(
      elevation: 2,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(
        vertical: 6,
        horizontal: 8,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Column(
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 5),
                    widget.paid
                      ? const Text(
                          'Paid',
                          style: TextStyle(
                            color:  Colors.grey,
                            fontSize: 12,
                          ),
                        )
                      : Text(
                          dueIn < 0 ? 'Overdue by ${dueIn.abs()} days': 'Due in $dueIn days',
                          style: TextStyle(
                            color: dueIn < 0 ? Colors.red: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    if (widget.fixed || widget.paid)
                      Text(
                        'RM ${widget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: widget.paid
                          ? Colors.greenAccent[700]
                          : Colors.grey[300],
                      child: widget.paid
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Divider(
                thickness: 0.5,
              ),
            ),
            Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Past Bills',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Text('Aug',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            )),
                        SizedBox(width: 30),
                        Text('RM 55000',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            )),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Text('July',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            )),
                        SizedBox(width: 30),
                        Text('RM 800',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            )),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        fixedSize:
                            MaterialStateProperty.all<Size>(const Size(80, 20)),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: _editBill,
                      child: const Text(
                        'Edit Bill',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ButtonStyle(
                        fixedSize:
                            MaterialStateProperty.all<Size>(const Size(80, 20)),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: MaterialStateProperty.all<Color>(
                            widget.paid ? Colors.grey[400]! : lightRed),
                      ),
                      onPressed: widget.paid ? null : _payBillDialog,
                      child: Text(
                        widget.paid ? 'Paid' : 'Pay Now',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
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
