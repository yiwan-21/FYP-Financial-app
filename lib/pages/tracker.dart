import 'package:flutter/material.dart';
import '../components/categoryChart.dart';
import '../components/transaction.dart';
import '../constants.dart';

class Tracker extends StatefulWidget {
  const Tracker({super.key});

  @override
  State<Tracker> createState() => _TrackerState();
}

class _TrackerState extends State<Tracker> with SingleTickerProviderStateMixin {
  final List<Transaction> _transactions = [
    Transaction(
        'T1', 'New Short', 49.99, DateTime.now(), true, 'Other Expenses',
        notes: "Notes"),
    Transaction(
        'T2', 'Groceries', 10.00, DateTime.now(), false, 'Savings'),
    Transaction(
        'T3', 'New Shoes', 69.98, DateTime.now(), true, 'Other Expenses',
        notes: "Notes"),
    Transaction('T4', 'Salary', 90.00, DateTime.now(), false, 'Savings',
        notes: "Yay!"),
    Transaction(
        'T5', 'Groceries', 20.53, DateTime.now(), false, 'Savings'),
    Transaction(
        'T6', 'New Shoes', 169.99, DateTime.now(), true, 'Other Expenses',
        notes: "Notes"),
    Transaction('T7', 'Salary', 1000.00, DateTime.now(), false, 'Savings',
        notes: "Yay!"),
    Transaction(
        'T8', 'New Clothes', 169.99, DateTime.now(), true, 'Other Expenses',
        notes: "Notes"),
    Transaction(
        'T9', 'Groceries', 16.53, DateTime.now(), false, 'Savings'),
    Transaction('T10', 'Salary', 3000.00, DateTime.now(), false, 'Savings',
        notes: "Yay!"),
    Transaction(
        'T11', 'New Jeans', 269.99, DateTime.now(), true, 'Other Expenses',
        notes: "Notes"),
    Transaction(
        'T12', 'Groceries', 12.99, DateTime.now(), false, 'Savings'),
    Transaction('T13', 'Salary', 5000.00, DateTime.now(), false, 'Savings',
        notes: "Yay!"),
  ];

  final List<double> categoriesValue = [
    10,
    20,
    3,
    5,
    8,
    7,
    3,
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(
          children: [
            const SizedBox(height: 24),
            Container(
              alignment: Constants.isMobile(context) ? Alignment.center : Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: Constants.isMobile(context) ? 0 : 8),
              child:  const Text(
                "Spending Categories",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,),
              ),
            ),
            CategoryChart(
              Constants.expenseCategories,
              categoriesValue,
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Transactions (RM)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              FloatingActionButton.small(
                backgroundColor: Colors.grey,
                onPressed: () {
                  Navigator.pushNamed(context, '/tracker/add').then((value) {
                    if (value != null && value is Transaction) {
                      setState(() {
                        _transactions.add(value);
                      });
                    }
                  });
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Wrap(
          children: List.generate(
            _transactions.length,
            (index) {
              final reversedIndex = _transactions.length - index - 1;
              if (Constants.isDesktop(context)) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width / 3,
                  child: _transactions[reversedIndex],
                );
              }
              else if (Constants.isTablet(context)) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: _transactions[reversedIndex],
                );
              } else {
                return _transactions[reversedIndex];
              }
            },
          ),
        ),
      ],
    );
  }
}
