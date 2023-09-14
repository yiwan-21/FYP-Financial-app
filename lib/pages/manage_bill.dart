import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/alert_confirm_action.dart';
import '../constants/constant.dart';
import '../constants/message_constant.dart';
import '../services/bill_service.dart';

class ManageBill extends StatefulWidget {
  final bool isEditing;
  final String? id;
  final String? title;
  final double? amount;
  final DateTime? date;
  final bool? fixed;

  const ManageBill(
      this.isEditing, this.id, this.title, this.amount, this.date, this.fixed,
      {super.key});

  @override
  State<ManageBill> createState() => _ManageBillState();
}

class _ManageBillState extends State<ManageBill> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  double _amount = 0;
  DateTime _date = DateTime.now();
  bool _fixed = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _title = widget.title ?? '';
      _amount = widget.amount ?? 0;
      _date = widget.date ?? DateTime.now();
      _fixed = widget.fixed ?? false;
    });
  }

  Future<void> _addBill() async {
    if (_formKey.currentState!.validate()) {
      // Submit form data to server or database
      _formKey.currentState!.save();

      await BillService.addBill(_title, _amount, _date, _fixed).then((_) {
        Navigator.pop(context);
      });
    }
  }

  Future<void> _editBill() async {
    if (_formKey.currentState!.validate()) {
      // Submit form data to server or database
      _formKey.currentState!.save();

      await BillService.editBill(widget.id!, _title, _amount, _date, _fixed).then((_) {
        Navigator.pop(context);
      });
    }
  }

  Future<void> _deleteBill() async {
    await BillService.deleteBill(widget.id!).then((_) {
      // close dialog
      Navigator.pop(context);
      // back to bill page
      Navigator.pop(context);
    });
  }

  //only select within the month?
  Future<void> _selectDate(BuildContext context) async {
    DateTime now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, 1);
    final lastDate = DateTime(now.year, now.month + 1, 0);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date.day == DateTime.now().day ? firstDate : _date,
      firstDate: firstDate,
      lastDate: lastDate,
    );
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
        title:
            widget.isEditing ? const Text('Edit Bill') : const Text('Add Bill'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertConfirmAction(
                      title: 'Delete Bill',
                      content: 'Are you sure you want to delete this bill?',
                      cancelText: 'Cancel',
                      confirmText: 'Delete',
                      confirmAction: _deleteBill,
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
                      labelText: 'Bill Title',
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
                        return ValidatorMessage.emptyGoalTitle;
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
                  TextFormField(
                    readOnly: true,
                    onTap: () {
                      _selectDate(context);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Payment Due Date on This Month',
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
                  const SizedBox(height: 10.0),
                  Row(
                    children: [
                      const SizedBox(width: 5.0),
                      Text(
                        'Fixed Monthly Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              _fixed ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      Checkbox(
                        value: _fixed,
                        onChanged: (value) {
                          setState(() {
                            _fixed = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  TextFormField(
                    enabled: _fixed,
                    initialValue:
                        _amount == 0 ? null : _amount.toStringAsFixed(2),
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(
                        color: _fixed? Colors.black : Colors.black38 ,
                      ),
                      fillColor: _fixed ? Colors.white : null,
                      filled: true,
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(width: 1.5),
                      ),
                      border: const OutlineInputBorder(
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
                      if (!_fixed) {
                        return null;
                      }
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
                        onPressed: widget.isEditing ? _editBill : _addBill,
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
