import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/alert_confirm_action.dart';
import '../constants/constant.dart';
import '../constants/message_constant.dart';

class ManageDebt extends StatefulWidget {
  final bool isEditing;
  final String? id;
  final String? title;
  final double? amount;
  final double? interest;
  final int? year;
  final int? month;

  const ManageDebt(
    this.isEditing, 
    this.id, 
    this.title, 
    this.amount, 
    this.interest, 
    this.year, 
    this.month,
    {super.key}
  );

  @override
  State<ManageDebt> createState() => _ManageDebtState();
}

class _ManageDebtState extends State<ManageDebt> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  double _amount = 0;
  double _interest = 0;
  int _year = 0;
  int _month = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      _title = widget.title ?? '';
      _amount = widget.amount ?? 0;
      _interest = widget.interest ?? 0;
      _year = widget.year ?? 0;
      _month = widget.month ?? 0;
    });
  }

  Future<void> _addDebt() async {
    if (_formKey.currentState!.validate()) {
      // Submit form data to server or database
      _formKey.currentState!.save();
    }
  }

  Future<void> _editDebt() async {
    if (_formKey.currentState!.validate()) {
      // Submit form data to server or database
      _formKey.currentState!.save();
    }
  }

  Future<void> _deleteDebt() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            widget.isEditing ? const Text('Edit Debt') : const Text('Add Debt'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertConfirmAction(
                      title: 'Delete Debt',
                      content: 'Are you sure you want to delete this Debt?',
                      cancelText: 'Cancel',
                      confirmText: 'Delete',
                      confirmAction: _deleteDebt,
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
                      labelText: 'Debt Title',
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
                        return ValidatorMessage.emptyDebtTitle;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _title = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue:
                          _year == 0 ? null : _year.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Duration(Year)',
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1.5),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(width: 1),
                            ),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+')),
                          ],
                          validator: (value) {
                            if (value!.isEmpty && _month == 0) {
                              return ValidatorMessage.emptyDuration;
                            }
                            if (int.tryParse(value) == null && _month == 0) {
                              return ValidatorMessage.invalidDuration;
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _year = int.tryParse(value) == null
                                  ? 0
                                  : int.parse(value);
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text("and", style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          initialValue:
                          _month == 0 ? null : _month.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Duration(Month)',
                            labelStyle: TextStyle(
                              color: Colors.black,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(width: 1.5),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(width: 1),
                            ),
                          ),
                          keyboardType:
                              const TextInputType.numberWithOptions(),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+')),
                          ],
                          validator: (value) {
                            if (value!.isEmpty && _year == 0) {
                              return ValidatorMessage.emptyDuration;
                            }
                            if (int.tryParse(value) == null && _year == 0) {
                              return ValidatorMessage.invalidDuration;
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _month = int.tryParse(value) == null
                                  ? 0
                                  : int.parse(value);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  TextFormField(
                    initialValue:
                        _amount == 0 ? null : _amount.toStringAsFixed(2),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1.5),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value!.isEmpty) {
                        return ValidatorMessage.emptyAmount;
                      }
                      if (double.tryParse(value) == null) {
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
                  const SizedBox(height: 24.0),
                  TextFormField(
                    initialValue:
                        _interest == 0 ? null : _interest.toStringAsFixed(2),
                    decoration: const InputDecoration(
                      labelText: 'Interest % (optional)',
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1.5),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _amount = double.tryParse(value) == null
                            ? 0
                            : double.parse(value);
                      });
                    },
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(100, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        onPressed: widget.isEditing ? _editDebt : _addDebt,
                        child: const Text('Save'),
                      ),
                      const SizedBox(width: 12),
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
                      )
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
