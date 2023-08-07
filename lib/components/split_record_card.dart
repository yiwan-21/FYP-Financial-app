import 'package:flutter/material.dart';

import '../models/split_record.dart';

class SplitRecordCard extends StatefulWidget {
  final SplitRecord record;
  const SplitRecordCard({required this.record, super.key});

  @override
  State<SplitRecordCard> createState() => _SplitRecordCardState();
}

class _SplitRecordCardState extends State<SplitRecordCard> {
  bool _isSettle() {
    return widget.record.amount - widget.record.paidAmount == 0;
  }

  String _getRemainingAmount() {
    return (widget.record.amount - widget.record.paidAmount).toStringAsFixed(2);
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
                      widget.record.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.record.date.toString().substring(0, 10),
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
                  'Paid RM ${widget.record.paidAmount.toStringAsFixed(2)}',
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
