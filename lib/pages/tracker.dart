import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constant.dart';
import '../constants/route_name.dart';
import '../components/category_chart.dart';
import '../components/tracker_transaction.dart';

import '../providers/total_transaction_provider.dart';

class Tracker extends StatefulWidget {
  const Tracker({super.key});

  @override
  State<Tracker> createState() => _TrackerState();
}

class _TrackerState extends State<Tracker> {
  final List<String> _categories = [Constant.noFilter, ...Constant.categories];
  String _selectedItem = Constant.noFilter;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Column(
          children: [
            const SizedBox(height: 24),
            Container(
              alignment: Constant.isMobile(context)
                  ? Alignment.center
                  : Alignment.centerLeft,
              padding: EdgeInsets.symmetric(
                  horizontal: Constant.isMobile(context) ? 0 : 8),
              child: const Text(
                "Spending Categories",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const CategoryChart(),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              const Text(
                "Transactions (RM)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: _selectedItem,
                icon: const Icon(Icons.filter_alt_outlined), // Icon to display
                iconSize: 24,
                elevation: 16,
                hint: const Text('Filter'),
                onChanged: (newValue) {
                  setState(() {
                    _selectedItem = newValue!;
                  });
                },
                items:
                    _categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              const Spacer(),
              FloatingActionButton.small(
                elevation: 2,
                onPressed: () {
                  Navigator.pushNamed(context, RouteName.manageTransaction, arguments: {'isEditing': false}).then((value) {
                    if (value != null && value is TrackerTransaction) {
                      Provider.of<TotalTransactionProvider>(context,
                              listen: false)
                          .updateTransactions();
                    }
                  });
                },
                child: const Icon(
                  Icons.add,
                ),
              ),
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: Provider.of<TotalTransactionProvider>(context, listen: false).getAllTransactionsStream,
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Something went wrong: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No transaction yet"));
            }

            List<TrackerTransaction> transactions = snapshot.data!.docs
                .where((doc) =>
                    _selectedItem == Constant.noFilter ||
                    doc['category'] == _selectedItem)
                .map((doc) => TrackerTransaction.fromDocument(doc))
                .toList();
            return Wrap(
              children: List.generate(
                transactions.length,
                (index) {
                  if (Constant.isDesktop(context) &&
                      MediaQuery.of(context).size.width > 1200) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: transactions[index],
                    );
                  } else if (Constant.isTablet(context) ||
                      MediaQuery.of(context).size.width >
                          Constant.tabletMaxWidth) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: transactions[index],
                    );
                  } else {
                    return transactions[index];
                  }
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
