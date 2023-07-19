import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../firebase_instance.dart';
import '../constant/constant.dart';
import '../components/transaction.dart';
import '../components/custom_switch.dart';
import '../providers/transaction_provider.dart';
import '../services/transaction_service.dart';

class EditTransaction extends StatefulWidget {
  const EditTransaction({super.key});

  @override
  State<EditTransaction> createState() => _EditTransactionState();
}

class _EditTransactionState extends State<EditTransaction> {
  final _formKey = GlobalKey<FormState>();
  String _id = '';
  String _title = '';
  String? _notes;
  double _amount = 0;
  bool _isExpense = true;
  String _category = '';
  DateTime _date = DateTime.now();
  List<String> _categoryList = [];

  @override
  void initState() {
    super.initState();
    final TransactionProvider transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);
    _id = transactionProvider.getId;
    _title = transactionProvider.getTitle;
    _notes = transactionProvider.getNotes;
    _amount = transactionProvider.getAmount;
    _date = transactionProvider.getDate;
    _isExpense = transactionProvider.getIsExpense;
    _category = transactionProvider.getCategory;
    _categoryList =
        _isExpense ? Constant.expenseCategories : Constant.incomeCategories;
  }

  void updateTransaction() async {
    if (_formKey.currentState!.validate()) {
      // Form is valid
      _formKey.currentState!.save();
      final editedTransaction = TrackerTransaction(
        _id,
        FirebaseInstance.auth.currentUser!.uid,
        _title,
        _amount,
        _date,
        _isExpense,
        _category,
        notes: _notes,
      );

      await TransactionService.updateTransaction(editedTransaction).then((_) {
        Navigator.pop(context, editedTransaction);
      });
    }
  }

  void deleteTransaction() async {
    await TransactionService.deleteTransaction(_id).then((_) {
      // quit dialog box
      Navigator.pop(context);
      // quit edit transaction page
      // need to return something, because
      // null returned will not update transaction list
      Navigator.pop(context, 'deleted');
    });
  }

  Future<void> _selectDate(BuildContext context, DateTime initialValue) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialValue,
        firstDate: DateTime(2020),
        lastDate: DateTime(2025));
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transaction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Delete Transaction'),
                    content: const Text(
                        'Are you sure you want to delete this transaction?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: deleteTransaction,
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        alignment:
            Constant.isMobile(context) ? Alignment.topCenter : Alignment.center,
        child: SingleChildScrollView(
          child: Container(
            decoration: Constant.isMobile(context)
                ? null
                : BoxDecoration(
                    border: Border.all(color: Colors.black45, width: 1),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38.withOpacity(0.2),
                        offset: const Offset(3, 5),
                        blurRadius: 5.0,
                      )
                    ],
                  ),
            width: Constant.isMobile(context) ? null : 500,
            padding: Constant.isMobile(context)
                ? null
                : const EdgeInsets.fromLTRB(24, 40, 24, 24),
            margin: Constant.isMobile(context)
                ? const EdgeInsets.fromLTRB(12, 24, 12, 0)
                : null,
            child: Form(
              key: _formKey,
              child: Column(
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
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1.5, color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your title';
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
                    onTap: () {
                      _selectDate(context, _date);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      labelStyle: TextStyle(color: Colors.black),
                      suffixIcon: Icon(Icons.calendar_today),
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1.5, color: Colors.red),
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
                          initialValue: _amount.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                            labelStyle: TextStyle(color: Colors.black),
                            fillColor: Colors.white,
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1.5, color: Colors.red),
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
                              return 'Please enter an amount';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid amount';
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
                            if (_categoryList
                                .contains(transactionProvider.getCategory)) {
                              _category = transactionProvider.getCategory;
                            } else {
                              _category = _categoryList[0];
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
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1.5, color: Colors.red),
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
                        onPressed: updateTransaction,
                        child: const Text('Edit Transaction'),
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
          ),
        ),
      ),
    );
  }
}
