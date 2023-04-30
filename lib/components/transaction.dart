import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class Transaction extends StatefulWidget {
  String id;
  String title;
  String? notes;
  double amount;
  DateTime date;
  bool isExpense;
  String category;

  Transaction(this.id, this.title, this.amount, this.date, this.isExpense,
      this.category,
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
      'id': widget.id,
      'title': widget.title,
      'notes': widget.notes,
      'amount': widget.amount,
      'date': widget.date,
      'isExpense': widget.isExpense,
      'category': widget.category,
    }).then((tx) => {
          if (tx != null && tx is Transaction)
            {
              setState(() {
                widget.title = tx.title;
                widget.notes = tx.notes;
                widget.amount = tx.amount;
                widget.date = tx.date;
                widget.isExpense = tx.isExpense;
                widget.category = tx.category;
              }),
            }
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
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Icon(
                            _expanded ? Icons.expand_less : Icons.expand_more),
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
