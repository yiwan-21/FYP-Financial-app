import 'package:flutter/material.dart';

class Transaction extends StatelessWidget {
  final String title;
  final double amount;
  final DateTime date;
  final bool isExpense;

  const Transaction(this.title, this.amount, this.date, this.isExpense,
      {super.key});

  @override
  Widget build(BuildContext context) {
    // DateTime now = date.toUtc().add(Duration(hours:8));

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/tracker/edit', arguments: {
          'title': title,
          'amount': amount,
          'date': date,
          'isExpense': isExpense,
        });
      },
      child: Card(
        color: isExpense
            ? const Color.fromARGB(255, 255, 176, 176)
            : Colors.greenAccent[100],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    // "${now.year.toString()}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')} ${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}",
                    date.toString().substring(0, 10),
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 15,
              ),
              child: Text(
                '${isExpense ? "-" : "+"}  RM${amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
