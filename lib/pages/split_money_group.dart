import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        arguments: {'members': _group.members});
  }

  void _navigateToSettings() {
    Navigator.pushNamed(context, '/group/settings',
        arguments: {'splitGroup': _group})
        .then((_) {
          Provider.of<TotalSplitMoneyProvider>(context, listen: false).updateGroups();
        });
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
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(150, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                onPressed: _addExpense,
                child: const Text('Add Expense'),
              ),
            )
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
                    }
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Consumer<SplitMoneyProvider>(
                builder: (context, splitMoneyProvider, _) {  
                    if (splitMoneyProvider.members == null) {
                      return const CircularProgressIndicator();
                    }
                      if (splitMoneyProvider.members!.length > 1) {
                        return Container(
                          alignment: Alignment.centerRight,
                          child: !Constant.isMobile(context)
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: const Size(150, 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4.0),
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
              const SizedBox(height: 20),
              Consumer<SplitMoneyProvider>(
                builder: (context, splitMoneyProvider, _) {
                    if (splitMoneyProvider.members != null && splitMoneyProvider.members!.length > 1) {
                      if (splitMoneyProvider.expenses == null || splitMoneyProvider.expenses!.isEmpty) {
                        return const Text(
                          "No expenses yet.",
                          textAlign: TextAlign.center,
                        );
                      }
                      return Column(children: splitMoneyProvider.expenses!);
                    }
                    return Container();
              }),
            ],
          ),
        ),
      ),
    );
  }
}
