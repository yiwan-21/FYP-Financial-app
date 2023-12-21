import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constants/tour_example.dart';
import '../pages/manage_transaction.dart';
import '../constants/constant.dart';
import '../constants/route_name.dart';
import '../components/category_chart.dart';
import '../components/tracker_transaction.dart';
import '../components/showcase_frame.dart';
import '../providers/show_case_provider.dart';
import '../providers/transaction_provider.dart';

class Tracker extends StatefulWidget {
  const Tracker({super.key});

  @override
  State<Tracker> createState() => _TrackerState();
}

class _TrackerState extends State<Tracker> {
  final List<String> _categories = [
    Constant.noFilter,
    ...Constant.allCategories
  ];
  String _selectedItem = Constant.noFilter;
  final List<GlobalKey> _keys = [
    GlobalKey(),
    GlobalKey(),
  ];
  bool _runningShowcase = false;

  @override
  void initState() {
    super.initState();
    ShowcaseProvider showcaseProvider = Provider.of<ShowcaseProvider>(context, listen: false);
    if (showcaseProvider.isFirstTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _keys.add(showcaseProvider.navGoalKey);

        await Future.delayed(const Duration(milliseconds: 200)).then((_) {
          ShowCaseWidget.of(context).startShowCase(_keys);
          setState(() {
            _runningShowcase = true;
          });
        });
      });
    }
  }

  void _addTransaction() {
    if (Constant.isMobile(context) && !kIsWeb) {
      Navigator.pushNamed(context, RouteName.manageTransaction, arguments: {'isEditing': false});
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const ManageTransaction(false);
        },
      );
    }
  }

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
                  fontSize: 20,
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
              Column(
                children: [
                  const Text(
                    "Transactions (RM)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DropdownButton<String>(
                    value: _selectedItem,
                    icon: const Icon(
                        Icons.filter_alt_outlined), // Icon to display
                    iconSize: 22,
                    elevation: 16,
                    hint: const Text('Filter'),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedItem = newValue!;
                      });
                    },
                    items: _categories
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              ShowcaseFrame(
                showcaseKey: _keys[0],
                title: "Transaction",
                description: "Add your transaction here",
                width: 250,
                height: 100,
                child: Constant.isMobile(context)
                    ? FloatingActionButton.small(
                        elevation: 2,
                        onPressed: _addTransaction,
                        child: const Icon(
                          Icons.add,
                        ),
                      )
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(150, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        onPressed: _addTransaction,
                        child: const Text('Add Transaction'),
                      ),
              ),
            ],
          ),
        ),
        Consumer<TransactionProvider>(
          builder: ((context, transactionProvider, _) {
            List<TrackerTransaction> transactions = transactionProvider.getTransactions;
            if (!_runningShowcase) {
              if (transactions.isEmpty) {
                return const Center(child: Text("No transaction yet"));
              }
            }
            return ShowcaseFrame(
              showcaseKey: _keys[1],
              title: "Data Created",
              description: "Tap here to view details, double tap to edit",
              width: 300,
              height: 100,
              child: Wrap(
                children: List.generate(
                  _runningShowcase ? 2 : transactions.length,
                  (index) {
                    List<TrackerTransaction> examples = [TourExample.expenseTransaction, TourExample.incomeTransaction];
                    if (Constant.isDesktop(context) && MediaQuery.of(context).size.width > 1200) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: _runningShowcase ? examples[index] : transactions[index],
                      );
                    } else if (Constant.isTablet(context) || MediaQuery.of(context).size.width > Constant.tabletMaxWidth) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: _runningShowcase ? examples[index] : transactions[index],
                      );
                    } else {
                      return _runningShowcase ? examples[index] : transactions[index];
                    }
                  },
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
