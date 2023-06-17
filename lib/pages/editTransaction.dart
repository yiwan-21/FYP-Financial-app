import 'package:financial_app/firebaseInstance.dart';
import 'package:financial_app/providers/transactionProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../components/transaction.dart';

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
        _isExpense ? Constants.expenseCategories : Constants.incomeCategories;
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
                    content: const Text('Are you sure you want to delete this transaction?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        }, 
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await FirebaseInstance.firestore
                              .collection("transactions")
                              .doc(_id)
                              .delete()
                              .then((_) {
                                // quit dialog box
                                Navigator.pop(context);
                                // quit edit transaction page
                                // need to return something, because
                                // null returned will not update transaction list
                                Navigator.pop(context, 'deteled');
                              });
                        }, 
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
        alignment: Constants.isMobile(context)
            ? Alignment.topCenter
            : Alignment.center,
        child: SingleChildScrollView(
          child: Container(
            decoration: Constants.isMobile(context)
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
            width: Constants.isMobile(context) ? null : 500,
            padding: Constants.isMobile(context)
                ? null
                : const EdgeInsets.fromLTRB(24, 40, 24, 24),
            margin: Constants.isMobile(context)
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
                                ? Constants.expenseCategories
                                : Constants.incomeCategories;
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          padding: const EdgeInsets.all(20),
                        ),
                        child: const Text('Edit Transaction'),
                        onPressed: () async {
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

                            await FirebaseInstance.firestore
                                .collection("transactions")
                                .doc(_id)
                                .update(editedTransaction.toCollection())
                                .then((_) {
                                  Navigator.pop(context, editedTransaction);
                                });
                          }
                        },
                      ),
                      if (!Constants.isMobile(context))
                        const SizedBox(width: 12),
                      if (!Constants.isMobile(context))
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

class CustomSwitch extends StatefulWidget {
  const CustomSwitch({
    Key? key,
    required this.onToggle,
    this.isIncome = false,
  }) : super(key: key);

  final Color activeColor = const Color.fromARGB(255, 185, 246, 202);
  final Color inactiveColor = const Color.fromARGB(255, 255, 176, 176);
  final List<String> labels = const ['Income', 'Expense'];
  final ValueChanged<bool> onToggle;
  final bool isIncome;

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  bool _value = false;

  @override
  void initState() {
    const duration = Duration(milliseconds: 100);
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: duration,
    );
    _animation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: const Offset(3.2, 0),
    ).animate(_controller);
    if (widget.isIncome) {
      _controller.duration = const Duration(milliseconds: 0);
      _controller.forward();
      _controller.duration = duration;
    }
    _value = widget.isIncome;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    _value = !_value;
    widget.onToggle(_value);

    if (_value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        width: 125.0,
        height: 34.0,
        decoration: BoxDecoration(
          border: _value
              ? Border.all(color: Colors.green[600]!, width: 2.0)
              : Border.all(color: Colors.red[600]!, width: 2.0),
          borderRadius: BorderRadius.circular(16.0),
          color: _value ? widget.activeColor : widget.inactiveColor,
        ),
        child: Padding(
          padding: _value
              ? const EdgeInsets.only(left: 14.0)
              : const EdgeInsets.only(right: 14.0),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.labels[0],
                  style: TextStyle(
                    color: _value ? Colors.black : widget.inactiveColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  widget.labels[1],
                  style: TextStyle(
                    color: _value ? widget.activeColor : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  return SlideTransition(
                    position: _animation,
                    child: Container(
                      width: 25.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: _value
                            ? Border.all(color: Colors.green[600]!, width: 2.0)
                            : Border.all(color: Colors.red[600]!, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.6),
                            blurRadius: 4.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
