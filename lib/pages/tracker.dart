import 'package:financial_app/firebaseInstance.dart';
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
  final List<TrackerTransaction> _transactions = [];

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
  void initState() {
    super.initState();
    _getTransactions();
  }

  Future<List<TrackerTransaction>> _getTransactions() async {
    List<TrackerTransaction> _transactionData = [];
    await FirebaseInstance.firestore.collection('transactions')
      .orderBy('date', descending: false)
      .get()
      .then((event) {
        for (var transaction in event.docs) {
          _transactionData.add(TrackerTransaction(
            transaction.id,
            transaction['userID'],
            transaction['title'],
            transaction['amount'],
            transaction['date'].toDate(),
            transaction['isExpense'],
            transaction['category'],
            notes: transaction['notes'],
          ));
        }
      });
    return _transactionData;
  }

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
                    if (value != null && value is TrackerTransaction) {
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
        FutureBuilder(
          future: _getTransactions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
              return Wrap(
                children: List.generate(
                  snapshot.data!.length,
                  (index) {
                    final reversedIndex = snapshot.data!.length - index - 1;
                    if (Constants.isDesktop(context)) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: snapshot.data![reversedIndex],
                      );
                    }
                    else if (Constants.isTablet(context)) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: snapshot.data![reversedIndex],
                      );
                    } else {
                      return snapshot.data![reversedIndex];
                    }
                  },
                ),
              );
            } else {
              return Container();
            }
          }
        ),
      ],
    );
  }
}
