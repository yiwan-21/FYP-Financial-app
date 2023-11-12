import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';


import '../constants/constant.dart';
import '../constants/style_constant.dart';
import '../forms/transaction_form.dart';
import '../components/alert_confirm_action.dart';
import '../providers/total_transaction_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/transaction_service.dart';

class ManageTransaction extends StatefulWidget {
  final bool isEditing;
  const ManageTransaction(this.isEditing, {super.key});

  @override
  State<ManageTransaction> createState() => _ManageTransactionState();
}

class _ManageTransactionState extends State<ManageTransaction> {
  String _id = '';
  String _title = '';
  String? _notes;
  double _amount = 0;
  bool _isExpense = true;
  DateTime _date = DateTime.now();
  List<String> _categoryList = [...Constant.expenseCategories, ...Constant.excludedCategories];
  String _category = Constant.expenseCategories[0];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      final TransactionProvider transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);

      _id = transactionProvider.getId;
      _title = transactionProvider.getTitle;
      _notes = transactionProvider.getNotes;
      _amount = transactionProvider.getAmount;
      _date = transactionProvider.getDate;
      _isExpense = transactionProvider.getIsExpense;
      _category = transactionProvider.getCategory;
      _categoryList = _isExpense ? Constant.expenseCategories : Constant.incomeCategories;
      _categoryList = [..._categoryList, ...Constant.excludedCategories];
    }
  }

  void _deleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertConfirmAction(
          title: 'Delete Transaction',
          content:
              'Are you sure you want to delete this transaction?',
          cancelText: 'Cancel',
          confirmText: 'Delete',
          confirmAction: _deleteTransaction,
        );
      },
    );
  }

  void _deleteTransaction() async {
    await TransactionService.deleteTransaction(_id, _isExpense).then((_) {
      Provider.of<TotalTransactionProvider>(context, listen: false)
          .updateTransactions();
      // quit dialog box
      Navigator.pop(context);
      // quit edit transaction page
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Constant.isMobile(context) && !kIsWeb) {
      return Scaffold(
          appBar: AppBar(
            title: widget.isEditing
                ? const Text('Edit Transaction')
                : const Text('Add Transaction'),
            actions: [
              if (widget.isEditing)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _deleteDialog,
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(12, 24, 12, 0),
            child: TransactionForm(
              id: _id,
              title: _title,
              notes: _notes,
              amount: _amount,
              isExpense: _isExpense,
              date: _date,
              category: _category,
              categoryList: _categoryList,
              isEditing: widget.isEditing,
            ),
          ),
        );
    } else {
      return AlertDialog(
        title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget.isEditing
                  ? const Text('Edit Transaction')
                  : const Text('Add Transaction'),
            if (widget.isEditing)
              IconButton(
                iconSize: 30,
                splashRadius: 30,
                color: lightRed,
                icon: const Icon(Icons.delete),
                onPressed: _deleteDialog,
              ),
          ],
        ),    
        content: SizedBox(
          width: 500,
          child: TransactionForm(
            id: _id,
            title: _title,
            notes: _notes,
            amount: _amount,
            isExpense: _isExpense,
            date: _date,
            category: _category,
            categoryList: _categoryList,
            isEditing: widget.isEditing,
          ),
        ),
      );
    }

  }
}
