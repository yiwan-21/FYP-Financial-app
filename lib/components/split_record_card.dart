import 'package:flutter/material.dart';

class SplitRecordCard extends StatefulWidget {
  final String name;
  final double amount;
  final double paidAmount;
  final DateTime date;
  const SplitRecordCard(
      this.name, this.amount, this.paidAmount, this.date,
      {super.key});

  @override
  State<SplitRecordCard> createState() => _SplitRecordCardState();
}

class _SplitRecordCardState extends State<SplitRecordCard> {
  bool _isSettle() {
    return widget.amount - widget.paidAmount == 0;
  }

  String _getRemainingAmount() {
    return (widget.amount - widget.paidAmount).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _isSettle() ? Colors.greenAccent[100] : Colors.white,
      child: Container(
        margin: const EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 20,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'RM ${_getRemainingAmount()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Paid RM ${widget.paidAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
