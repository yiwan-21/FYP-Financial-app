import 'package:flutter/material.dart';
import '../constants/constant.dart';
import '../components/split_expense_card.dart';
import '../models/split_group.dart';
import '../services/split_money_service.dart';

class SplitMoneyGroup extends StatefulWidget {
  final String groupID;
  const SplitMoneyGroup({required this.groupID, super.key});

  @override
  State<SplitMoneyGroup> createState() => _SplitMoneyGroupState();
}

class _SplitMoneyGroupState extends State<SplitMoneyGroup> {
  SplitGroup _group = SplitGroup();
  bool _hasMembers = false;
  List<SplitExpenseCard> _expenses = [];

  @override
  void initState() {
    super.initState();
    _setGroup();
  }

  void _setGroup() async {
    SplitGroup group = await SplitMoneyService.getGroupByID(widget.groupID);
    setState(() {
      _group = group;
      _hasMembers = _group.members != null && _group.members!.isNotEmpty;
      _expenses = _group.expenses ?? [];
    });
  }

  void _addExpense() {
    Navigator.pushNamed(context, '/group/expense/add'); //to be modify
  }

  void _navigateToMember() {
    Navigator.pushNamed(context, '/group/member'); //to be modify
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_group.name ?? 'Group'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: _navigateToMember,
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
                  Text(
                    _group.name ?? 'Loading',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _hasMembers
                ? 
                Container(
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
                  )
                : TextButton.icon(
                    onPressed: _navigateToMember,
                    label: const Text('Add Group Member'),
                    icon: const Icon(
                      Icons.person_add_alt,
                      size: 30,
                    ),
                  ),
              const SizedBox(height: 20),
              _hasMembers
                  ? Column(
                      children: _expenses,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
