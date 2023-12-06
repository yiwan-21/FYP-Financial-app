import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constant.dart';
import '../constants/route_name.dart';
import '../constants/style_constant.dart';
import '../pages/manage_transaction.dart';
import '../providers/transaction_provider.dart';

class TrackerTransaction extends StatefulWidget {
  final String id;
  final String title;
  final String? notes;
  final double amount;
  final DateTime date;
  final bool isExpense;
  final String category;

  const TrackerTransaction(
      {required this.id,
      required this.title,
      required this.amount,
      required this.date,
      required this.isExpense,
      required this.category,
      this.notes,
      super.key});

  TrackerTransaction.fromDocument(QueryDocumentSnapshot doc, {super.key})
      : id = doc.id,
        title = doc['title'],
        notes = doc['notes'],
        amount = doc['amount'].toDouble(),
        date = doc['date'].toDate(),
        isExpense = doc['isExpense'],
        category = doc['category'];

  TrackerTransaction.fromSnapshot(DocumentSnapshot doc, {super.key})
      : id = doc.id,
        title = doc['title'],
        notes = doc['notes'],
        amount = doc['amount'].toDouble(),
        date = doc['date'].toDate(),
        isExpense = doc['isExpense'],
        category = doc['category'];

  @override
  State<TrackerTransaction> createState() => _TrackerTransactionState();

  Map<String, dynamic> toCollection() {
    return {
      'title': title,
      'notes': notes,
      'amount': amount,
      'date': date,
      'isExpense': isExpense,
      'category': category,
    };
  }
}

class _TrackerTransactionState extends State<TrackerTransaction> {
  bool _expanded = false;

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  void _navigateToEdit() {
    Provider.of<TransactionProvider>(context, listen: false).setTransaction(
      widget.id,
      widget.title,
      widget.amount,
      widget.date,
      widget.isExpense,
      widget.category,
      notes: widget.notes,
    );
    
    if (Constant.isMobile(context) && !kIsWeb) {
      Navigator.pushNamed(context, RouteName.manageTransaction, arguments: {'isEditing': true});
    } else{
      showDialog(
        context: context, 
        builder: (context) {
          return const ManageTransaction(true);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpanded,
      onDoubleTap: _navigateToEdit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        height: _expanded ? 200 : 75,
        child: Card(
          elevation: _expanded ? 8 : 2,
          color: widget.isExpense
              ? const Color.fromARGB(255, 255, 176, 176)
              : Colors.greenAccent[100],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: StyleConstant.getCategoryIcon(widget.category),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.date.toString().substring(0, 10),
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        child: Text(
                          '${widget.isExpense ? "-" : "+"}${widget.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                      )
                    ],
                  ),
                ],
              ),
              if (_expanded)
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.only(left: 15, bottom: 15, right: 15),
                    child: ListView(
                      children: [
                        Container(
                          alignment: Alignment.topRight,
                          child: const Text(
                            "Double tap to edit",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 70,
                              child: Text("Title: "),
                            ),
                            Flexible(child: Text(widget.title)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 70,
                              child: Text("Amount: "),
                            ),
                            Flexible(
                                child: Text(
                                    'RM ${widget.amount.toStringAsFixed(2)}')),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 70,
                              child: Text("Category: "),
                            ),
                            Flexible(child: Text(widget.category)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 70,
                              child: Text("Notes: "),
                            ),
                            Flexible(
                              child: SizedBox(
                                width: 300,
                                child: Text(widget.notes == null
                                    ? "-"
                                    : "${widget.notes}"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
