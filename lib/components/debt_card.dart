import 'package:flutter/material.dart';

import '../constants/route_name.dart';

class DebtCard extends StatefulWidget {
  final String id;
  final String title;
  final int duration; // in months
  final double amount;
  final double interests;
  final double plan;

  const DebtCard(this.id, this.title, this.duration, this.amount,
      this.interests, this.plan,
      {super.key});

  @override
  State<DebtCard> createState() => _DebtCardState();
}

class _DebtCardState extends State<DebtCard> {
  int _year = 0;
  int _month = 0;
  
  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 3),
                SizedBox(
                  width: 160,
                  child: Text('$_year years and $_month months'),
                ),
                const Icon(Icons.auto_graph_rounded, size: 20),
                const SizedBox(width: 3),
                Text('Interests: ${widget.interests}%'),
              ],
            ),
            const Divider(thickness: 1, height: 10),
            const SizedBox(height: 10),
            Table(
              // border: TableBorder.all(),
              columnWidths: const <int, TableColumnWidth>{
                0: FixedColumnWidth(80),
              },
              children: const [
                TableRow(
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
                TableRow(children: [
                  SizedBox(height: 5),
                  SizedBox(height: 5),
                  SizedBox(height: 5),
                ]),
                //TODO: Table Row List loop
                TableRow(
                  children: [
                    Text('Aug 12'),
                    Text('1000', textAlign: TextAlign.center),
                    Text('500', textAlign: TextAlign.center),
                  ],
                ),
                TableRow(
                  children: [
                    Text('Sep 12'),
                    Text('1000', textAlign: TextAlign.center),
                    Text('500', textAlign: TextAlign.center),
                  ],
                ),
                TableRow(
                  children: [
                    Text('Oct 12'),
                    Text('1000', textAlign: TextAlign.center),
                    Text('500', textAlign: TextAlign.center),
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
