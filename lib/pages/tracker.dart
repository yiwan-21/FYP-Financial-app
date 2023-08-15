import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/constant.dart';
import '../components/category_chart.dart';
import '../components/tracker_transaction.dart';
import '../providers/total_transaction_provider.dart';

class Tracker extends StatefulWidget {
  const Tracker({super.key});

  @override
  State<Tracker> createState() => _TrackerState();
}

class _TrackerState extends State<Tracker> {
  String _selectedItem = Constant.noFilter;
  final List<String> _categories = [Constant.noFilter, ...Constant.categories];

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Transactions (RM)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
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
                items: _categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              FloatingActionButton.small(
                elevation: 2,
                onPressed: () {
                  Navigator.pushNamed(context, '/tracker/add').then((value) {
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
        Consumer<TotalTransactionProvider>(
          builder: (context, totalTransactionProvider, _) {
            List<TrackerTransaction> transactions = totalTransactionProvider.getFilteredTransactions(_selectedItem);
            return Wrap(
              children: List.generate(
                transactions.length,
                (index) {
                  final reversedIndex = transactions.length - index - 1;
                  if (Constant.isDesktop(context)) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width / 3,
                      child: transactions[reversedIndex],
                    );
                  } else if (Constant.isTablet(context)) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: transactions[reversedIndex],
                    );
                  } else {
                    return transactions[reversedIndex];
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
