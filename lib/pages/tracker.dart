import 'package:flutter/material.dart';
import '../components/categoryChart.dart';
import '../components/transaction.dart';

class Tracker extends StatefulWidget {
  const Tracker({super.key});

  @override
  State<Tracker> createState() => _TrackerState();
}

class _TrackerState extends State<Tracker> with SingleTickerProviderStateMixin {
  final List<Transaction> transactions = [
    Transaction('Salary', 50000000.00, DateTime.now(), false),
    Transaction('Weekly Groceries', 16.53, DateTime.now(), false),
    Transaction('New Shoes', 69.99, DateTime.now(), true),
    Transaction('Weekly Groceries', 16.53, DateTime.now(), false),
    Transaction('New Shoes', 69.99, DateTime.now(), true),
    Transaction('Weekly Groceries', 16.53, DateTime.now(), false),
    Transaction('New Shoes', 69.99, DateTime.now(), true),
    Transaction('Weekly Groceries', 16.53, DateTime.now(), false),
    Transaction('New Shoes', 69.99, DateTime.now(), true),
    Transaction('Weekly Groceries', 16.53, DateTime.now(), false),
    Transaction('New Shoes', 69.99, DateTime.now(), true),
    Transaction('Weekly Groceries', 16.53, DateTime.now(), false),
    Transaction('New Shoes', 69.99, DateTime.now(), true),
    Transaction('Weekly Groceries', 16.53, DateTime.now(), false),
  ];

  bool _isVisible = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification is ScrollUpdateNotification) {
          double currentPosition = scrollNotification.metrics.pixels;
          if (currentPosition > 50) {
            setState(() {
              _isVisible = true;
            });
            _controller.forward();
          } else {
            setState(() {
              _isVisible = false;
            });
            _controller.reverse();
          }
        }
        return true;
      },
      child: Column(
        children: [
          FadeTransition(
            opacity: _animation,
            child: Visibility(
              visible: !_isVisible,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  SizedBox(height: 24),
                  Text(
                    "Spending Categories",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  CategoryChart(),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Transactions",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                FloatingActionButton.small(
                  backgroundColor: Colors.grey,
                  onPressed: () {
                    Navigator.pushNamed(context, '/tracker/add');
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: transactions.map((tx) {
                  return Transaction(
                      tx.title, tx.amount, tx.date, tx.isExpense);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
