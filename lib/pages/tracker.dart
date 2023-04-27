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
  final List<Transaction> transactions = [
    Transaction('T14', 'Weekly Groceries', 16.53, DateTime.now(), false, 'test'),
    Transaction('T13', 'New Shoes', 69.99, DateTime.now(), true, 'test'),
    Transaction('T12', 'Weekly Groceries', 16.53, DateTime.now(), false, 'test'),
    Transaction('T11', 'New Shoes', 69.99, DateTime.now(), true, 'test'),
    Transaction('T10', 'Weekly Groceries', 16.53, DateTime.now(), false, 'test'),
    Transaction('T9', 'New Shoes', 69.99, DateTime.now(), true, 'test'),
    Transaction('T8', 'Weekly Groceries', 16.53, DateTime.now(), false, 'test'),
    Transaction('T7', 'Personal Items', 69.99, DateTime.now(), true, 'Personal Items'),
    Transaction('T6', 'Education', 16.53, DateTime.now(), false, 'Education'),
    Transaction('T4', 'Rental', 16.53, DateTime.now(), false, 'Rental'),
    Transaction('T5', 'Bill', 69.99, DateTime.now(), true, 'Bill'),
    Transaction('T3', 'New Shoes', 69.99, DateTime.now(), true, 'Other Expenses', notes: "Notes"),
    Transaction('T2', 'Weekly Groceries', 16.53, DateTime.now(), false, 'Food'),
    Transaction('T1', 'Salary', 50000000.00, DateTime.now(), false, 'Savings', notes: "Yay!"),
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

  bool _scrollHandler(scrollNotification) {
    if (scrollNotification is ScrollUpdateNotification) {
      if (scrollNotification.depth != 0) {
        return false;
      }

      double currentPosition = scrollNotification.metrics.pixels;
      if (currentPosition > 5) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FadeTransition(
          opacity: _animation,
          child: Visibility(
            visible: !_isVisible,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                const Text(
                  "Spending Categories",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                CategoryChart(
                  Constants.expenseCategories,
                  categoriesValue,
                ),
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
                  Navigator.pushNamed(context, '/tracker/add').then((value) {
                    if (value != null && value is Transaction) {
                      setState(() {
                        transactions.add(value);
                      });
                    }
                  });
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _scrollHandler,
            child: SingleChildScrollView(
              child: Column(
                verticalDirection: VerticalDirection.up,
                children: transactions,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
