import 'package:financial_app/providers/totalTransactionProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/categoryChart.dart';
import '../components/transaction.dart';
import '../constants.dart';

class Tracker extends StatefulWidget {
  const Tracker({super.key});

  @override
  State<Tracker> createState() => _TrackerState();
}

class _TrackerState extends State<Tracker> with SingleTickerProviderStateMixin {


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
            const CategoryChart(),
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
                      Provider.of<TotalTransactionProvider>(context, listen: false).updateTransactions();
                    }
                  });
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Consumer<TotalTransactionProvider>(
          builder: (context, totalTransactionProvider, _) {
            return FutureBuilder(
              future: totalTransactionProvider.getTransactions,
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
            );
          }
        ),
      ],
    );
  }
}
