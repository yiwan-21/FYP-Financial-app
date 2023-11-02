import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constant.dart';
import '../constants/route_name.dart';
import '../pages/add_group_expense.dart';
import '../components/split_expense_card.dart';
import '../providers/split_money_provider.dart';
import '../services/split_money_service.dart';

class SplitMoneyGroup extends StatefulWidget {
  final String groupID;
  const SplitMoneyGroup({required this.groupID, super.key});

  @override
  State<SplitMoneyGroup> createState() => _SplitMoneyGroupState();
}

class _SplitMoneyGroupState extends State<SplitMoneyGroup> {
  Stream<DocumentSnapshot> _groupStream = const Stream.empty();
  Stream<QuerySnapshot> _expenseStream = const Stream.empty();

  @override
  void initState() {
    super.initState();
    _groupStream = SplitMoneyService.getSingleGroupStream(widget.groupID);
    _expenseStream = SplitMoneyService.getExpenseStream(widget.groupID);
  }

  void _addExpense() {
    if (Constant.isMobile(context) && !kIsWeb) {
      Navigator.pushNamed(context, RouteName.addGroupExpense).then((expense) {
        if (expense != null) {
          Provider.of<SplitMoneyProvider>(context, listen: false)
              .updateExpenses();
        }
      });
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AddGroupExpense();
        },
      ).then((_) {
        Provider.of<SplitMoneyProvider>(context, listen: false)
            .updateExpenses();
      });
    }
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, RouteName.groupSettings);
  }

  String formatMonthYear(DateTime date) {
    return '${Constant.monthLabels[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<DocumentSnapshot>(
          stream: _groupStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null) {
              return const Text('Group Expenses');
            }

            return Text(snapshot.data!['name']);
          },
        ),
        actions: [
          IconButton(
            iconSize: Constant.isMobile(context) ? 25 : 30,
            icon: const Icon(Icons.group),
            onPressed: _navigateToSettings,
          ),
          if (!Constant.isMobile(context)) const SizedBox(width: 15),
        ],
      ),
      bottomNavigationBar: Constant.isMobile(context)
          ? Consumer<SplitMoneyProvider>(
              builder: (context, splitMoneyProvider, _) {
              if (splitMoneyProvider.members != null &&
                  splitMoneyProvider.members!.length > 1) {
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
                  Consumer<SplitMoneyProvider>(
                    builder: (context, splitMoneyProvider, _) {
                      if (splitMoneyProvider.image != null) {
                        return CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(splitMoneyProvider.image!),
                        );
                      } else {
                        return const Icon(
                          Icons.diversity_3,
                          size: 60,
                          color: Colors.black,
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 20),
                  StreamBuilder<DocumentSnapshot>(
                    stream: _groupStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          !snapshot.hasData ||
                          snapshot.data == null) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Text('Error');
                      }

                      return Text(
                        snapshot.data!['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),  
                      );
                    },
                  ),
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
                },
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _expenseStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      !snapshot.hasData ||
                      snapshot.data == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  List<SplitExpenseCard> expenses = snapshot.data!.docs
                      .map((doc) => SplitExpenseCard.fromDocument(doc))
                      .toList();

                  if (expenses.isNotEmpty) {
                    // Group expenses by month
                    final Map<String, List<SplitExpenseCard>> expensesByMonth =
                        {};
                    for (var expense in expenses) {
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
                  } else {
                    return Consumer<SplitMoneyProvider> (
                      builder: (context, splitMoneyProvider, _) {
                        bool moreThanOneMember = splitMoneyProvider.members != null && 
                                splitMoneyProvider.members!.length > 1;
                        if (moreThanOneMember) {
                          return const Text(
                            "No expenses yet.",
                            textAlign: TextAlign.center,
                          );
                        } else {
                          return Container();
                        }
                      }
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
