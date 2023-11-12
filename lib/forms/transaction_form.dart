import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants/constant.dart';
import '../constants/message_constant.dart';
import '../components/custom_switch.dart';
import '../components/tracker_transaction.dart';
import '../providers/total_transaction_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/transaction_service.dart';

class TransactionForm extends StatefulWidget {
  final bool isEditing;
  final String id;
  final String title;
  final String? notes;
  final double amount;
  final bool isExpense;
  final DateTime date;
  final List<String> categoryList;
  final String category;

  const TransactionForm({
    required this.isEditing,
    required this.id,
    required this.title,
    required this.notes,
    required this.amount,
    required this.isExpense,
    required this.date,
    required this.categoryList,
    required this.category,
    super.key
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
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
    _id = widget.id;
    _title = widget.title;
    _notes = widget.notes;
    _amount = widget.amount;
    _date = widget.date;
    _isExpense = widget.isExpense;
    _category = widget.category;
    _categoryList = widget.categoryList;
  }

 Future<void> addTransaction() async {
    if (_formKey.currentState!.validate()) {
      // Form is valid
      _formKey.currentState!.save();
      final newTransaction = TrackerTransaction(
        id: 'Auto Generate',
        title: _title,
        amount: _amount,
        date: _date,
        isExpense: _isExpense,
        category: _category,
        notes: _notes,
      );
      await TransactionService.addTransaction(newTransaction).then((_) {
        Navigator.pop(context, newTransaction);
      });
    }
  }

  void updateTransaction() async {
    if (_formKey.currentState!.validate()) {
      // Form is valid
      _formKey.currentState!.save();
      final editedTransaction = TrackerTransaction(
        id: _id,
        title: _title,
        amount: _amount,
        date: _date,
        isExpense: _isExpense,
        category: _category,
        notes: _notes,
      );

      // update budgeting if category is changed
      TrackerTransaction previousTransaction =
          Provider.of<TransactionProvider>(context, listen: false)
              .getTransaction;
      await TransactionService.updateTransaction(
              editedTransaction, previousTransaction)
          .then((_) {
        Provider.of<TotalTransactionProvider>(context, listen: false)
            .updateTransactions();
        Navigator.pop(context);
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.black),
                fillColor: Colors.white,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1.5),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 1),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return ValidatorMessage.emptyTransactionTitle;
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _title = value;
                });
              },
            ),
            const SizedBox(height: 18.0),
            TextFormField(
              initialValue: _notes ?? "",
              decoration: const InputDecoration(
                labelText: 'Notes',
                labelStyle: TextStyle(color: Colors.black),
                fillColor: Colors.white,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1),
                ),
              ),
              validator: (value) {
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _notes = value;
                });
              },
            ),
            const SizedBox(height: 18.0),
            // date
            TextFormField(
              readOnly: true,
              onTap: _selectDate,
              decoration: const InputDecoration(
                labelText: 'Date',
                labelStyle: TextStyle(color: Colors.black),
                suffixIcon: Icon(Icons.calendar_today),
                fillColor: Colors.white,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1.5),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 1),
                ),
              ),
              controller: TextEditingController(
                text: _date.toString().substring(0, 10),
              ),
            ),
            const SizedBox(height: 18.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _amount == 0 ? null : _amount.toStringAsFixed(2),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(color: Colors.black),
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1.5),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value!.isEmpty) {
                        return ValidatorMessage.emptyAmount;
                      }
                      if (double.tryParse(value) == null || double.parse(value) <= 0) {
                        return ValidatorMessage.invalidAmount;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _amount = double.tryParse(value) == null
                            ? 0
                            : double.parse(value);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                CustomSwitch(
                  isIncome: !_isExpense,
                  onToggle: (value) {
                    final TransactionProvider transactionProvider =
                        Provider.of<TransactionProvider>(context,
                            listen: false);
                    setState(() {
                      _isExpense = !value;
                      _categoryList = _isExpense
                          ? Constant.expenseCategories
                          : Constant.incomeCategories;
                      _categoryList = [..._categoryList, ...Constant.excludedCategories];
                      if (!_categoryList.contains(transactionProvider.getCategory) || 
                          (!widget.isEditing && Constant.excludedCategories.contains(transactionProvider.getCategory))) {
                        _category = _categoryList[0];
                      } else {
                        _category = transactionProvider.getCategory;
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 18.0),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: _category,
              onChanged: (value) {
                setState(() {
                  _category = value!;
                });
              },
              items: _categoryList
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: Colors.black),
                helperText: '* Savings Goal is different from Savings',
                fillColor: Colors.white,
                filled: true,
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(width: 1.5),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(width: 1),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(150, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  onPressed: widget.isEditing
                      ? updateTransaction
                      : addTransaction,
                  child: widget.isEditing
                      ? const Text('Edit Transaction')
                      : const Text('Add Transaction'),
                ),
                if (!Constant.isMobile(context))
                  const SizedBox(width: 12),
                if (!Constant.isMobile(context))
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(100, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}