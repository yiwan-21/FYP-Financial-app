import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/split_expense_card.dart';
import '../constants/constant.dart';
import '../models/split_group.dart';
import '../providers/split_money_provider.dart';
import '../providers/total_split_money_provider.dart';

class SplitMoneyGroup extends StatefulWidget {
  const SplitMoneyGroup({super.key});

  @override
  State<SplitMoneyGroup> createState() => _SplitMoneyGroupState();
}

class _SplitMoneyGroupState extends State<SplitMoneyGroup> {
  SplitGroup _group = SplitGroup();

  void _addExpense() {
    Navigator.pushNamed(context, '/group/expense/add',
        arguments: {'members': _group.members}).then((expense) {
      if (expense != null) {
        Provider.of<SplitMoneyProvider>(context, listen: false)
            .updateExpenses();
      }
    });
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, '/group/settings',
        arguments: {'splitGroup': _group}).then((_) {
      Provider.of<TotalSplitMoneyProvider>(context, listen: false)
          .updateGroups();
    });
  }

  String formatMonthYear(DateTime date) {
    return '${Constant.monthLabels[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<SplitMoneyProvider>(
            builder: (context, splitMoneyProvider, _) {
          return Text(splitMoneyProvider.name ?? 'Loading...');
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      bottomNavigationBar: Constant.isMobile(context)
          ? Consumer<SplitMoneyProvider>(
              builder: (context, splitMoneyProvider, _) {
              if (splitMoneyProvider.members != null && splitMoneyProvider.members!.length > 1) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(150, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: _addExpense,
                    child: const Text('Add Expense'),
                  ),
                );
              }
              return const SizedBox(height: 0, width: 0);
            })
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            children: [
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.diversity_3,
                    size: 60,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 20),
                  Consumer<SplitMoneyProvider>(
                      builder: (context, splitMoneyProvider, _) {
                    return Text(
                      splitMoneyProvider.name ?? 'Loading...',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),
              Consumer<SplitMoneyProvider>(
                  builder: (context, splitMoneyProvider, _) {
                if (splitMoneyProvider.members == null) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (splitMoneyProvider.members!.length > 1) {
                  return Container(
                    alignment: Alignment.centerRight,
                    child: !Constant.isMobile(context)
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(150, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            onPressed: _addExpense,
                            child: const Text('Add Expense'),
                          )
                        : null,
                  );
                } else {
                  return TextButton.icon(
                    onPressed: _navigateToSettings,
                    label: const Text('Add more members for sharing money'),
                    icon: const Icon(
                      Icons.person_add_alt,
                      size: 30,
                    ),
                  );
                }
              }),
              Consumer<SplitMoneyProvider>(
                builder: (context, splitMoneyProvider, _) {
                  if (splitMoneyProvider.members != null &&
                      splitMoneyProvider.members!.length > 1) {
                    if (splitMoneyProvider.expenses == null ||
                        splitMoneyProvider.expenses!.isEmpty) {
                      return const Text(
                        "No expenses yet.",
                        textAlign: TextAlign.center,
                      );
                    }

                    // Group expenses by month
                    final Map<String, List<SplitExpenseCard>> expensesByMonth =
                        {};
                    for (var expense in splitMoneyProvider.expenses!) {
                      final String monthYear = formatMonthYear(expense.date);
                      if (!expensesByMonth.containsKey(monthYear)) {
                        expensesByMonth[monthYear] = [];
                      }
                      expensesByMonth[monthYear]!.add(expense);
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: expensesByMonth.length,
                      itemBuilder: (context, index) {
                        final String monthYear =
                            expensesByMonth.keys.elementAt(index);
                        final List<SplitExpenseCard> expenses =
                            expensesByMonth[monthYear]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 24, bottom: 10, left: 16),
                              child: Text(
                                monthYear,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ...expenses,
                          ],
                        );
                      },
                    );
                  }
                  return Container();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
