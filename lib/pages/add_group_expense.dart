import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../forms/group_expense_form.dart';
import '../constants/constant.dart';

class AddGroupExpense extends StatefulWidget {
  const AddGroupExpense({Key? key}) : super(key: key);

  @override
  State<AddGroupExpense> createState() => _AddGroupExpenseState();
}

class _AddGroupExpenseState extends State<AddGroupExpense> {
  @override
  Widget build(BuildContext context) {
    if (Constant.isMobile(context) && !kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Add Group Expense'),
        ),
        body: const Padding(
          padding: EdgeInsets.fromLTRB(12, 10, 12, 0),
          child: GroupExpenseForm(),
        ),
      );
    } else {
      return AlertDialog(
        title: const Text('Add Group Expense'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 400,
            maxWidth: 400,
            maxHeight: 600,
          ),
          child: const GroupExpenseForm(),
        ),
      );
    }
  }
}
