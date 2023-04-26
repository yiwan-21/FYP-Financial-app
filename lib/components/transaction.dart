import 'package:flutter/material.dart';
import '../constants.dart';

class Transaction extends StatefulWidget {
  final String title;
  String? notes;
  final double amount;
  final DateTime date;
  final bool isExpense;
  final String category;

  Transaction(this.title, this.amount, this.date, this.isExpense, this.category,
      {this.notes, super.key});

  @override
  State<Transaction> createState() => _TransactionState();
}

class _TransactionState extends State<Transaction>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  void _navigateToEdit() {
    Navigator.pushNamed(context, '/tracker/edit', arguments: {
      'title': widget.title,
      'notes': widget.notes,
      'amount': widget.amount,
      'date': widget.date,
      'isExpense': widget.isExpense,
      'category': widget.category,
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpanded,
      onDoubleTap: _navigateToEdit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        height: _expanded ? 150 : 75,
        child: Card(
          elevation: _expanded ? 8 : 2,
          color: widget.isExpense
              ? const Color.fromARGB(255, 255, 176, 176)
              : Colors.greenAccent[100],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Constants.getCategoryIcon(widget.category),
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    child: Text(
                      '${widget.isExpense ? "-" : "+"}  RM${widget.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              _expanded
                  ? Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 15, bottom: 15),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.notes == null
                                    ? "No Notes"
                                    : "Notes: ${widget.notes}",
                              ),
                              Text("Category: ${widget.category}"),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
