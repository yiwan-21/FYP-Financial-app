import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants/constant.dart';
import '../constants/message_constant.dart';
import '../models/split_expense.dart';
import '../models/group_user.dart';
import '../models/split_record.dart';
import '../services/split_money_service.dart';
import '../providers/split_money_provider.dart';

class AddGroupExpense extends StatefulWidget {
  const AddGroupExpense({Key? key}) : super(key: key);

  @override
  State<AddGroupExpense> createState() => _AddGroupExpenseState();
}

class _AddGroupExpenseState extends State<AddGroupExpense> {
  final _formKey = GlobalKey<FormState>();
  final SplitExpense _splitExpense = SplitExpense(
    title: '',
    amount: 0,
    paidAmount: 0,
    splitMethod: Constant.splitMethod[0],
    paidBy: GroupUser('', '', ''),
    sharedRecords: [],
    createdAt: DateTime.now(),
  );
  List<GroupUser> _members = [];
  final List<TextEditingController> _amountControllers = [];
  bool _checkAmount = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _members =
          Provider.of<SplitMoneyProvider>(context, listen: false).members!;
      _splitExpense.paidBy = _members[0];
    });
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in _amountControllers) {
      controller.dispose();
    }
  }

  void _calAmount() {
    if (_splitExpense.splitMethod == Constant.splitEqually) {
      double amount = _splitExpense.amount / _splitExpense.sharedRecords.length;
      for (var controller in _amountControllers) {
        controller.text = amount.toStringAsFixed(2);
      }
      setState(() {
        for (var record in _splitExpense.sharedRecords) {
          record.amount = amount;
        }
      });
    }
  }

  void _addGroupExpense() {
    // check the total amount and split amounts
    double inputAmount = 0;
    for (var record in _splitExpense.sharedRecords) {
      inputAmount += record.amount;
      if (record.id == _splitExpense.paidBy.id) {
        record.paidAmount = record.amount;
        _splitExpense.paidAmount = record.amount;
      }
    }

    if (inputAmount != _splitExpense.amount) {
      _checkAmount = true;
      inputAmount = 0;
    } else {
      _checkAmount = false;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

     String groupID =
          Provider.of<SplitMoneyProvider>(context, listen: false).id!;
      SplitMoneyService.addExpense(groupID, _splitExpense).then((_) {
        Navigator.pop(context, _splitExpense);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Group Expense'),
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
                ? const EdgeInsets.fromLTRB(12, 10, 12, 0)
                : const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: Constant.isMobile(context)
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.spaceBetween,
                    children: [
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
                      if (!Constant.isMobile(context))
                        const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(100, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                        onPressed: _addGroupExpense,
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18.0),
                  TextFormField(
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
                        return ValidatorMessage.emptyTransactionTitle;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _splitExpense.title = value;
                      });
                    },
                  ),
                  const SizedBox(height: 18.0),
                  TextFormField(
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
                        borderSide: BorderSide(width: 1.5, color: Colors.red),
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
                      if (_checkAmount) {
                        return ValidatorMessage.invalidTotalAmount;
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _splitExpense.amount = double.tryParse(value) == null
                            ? 0
                            : double.parse(value);
                      });
                      _calAmount();
                    },
                  ),
                  const SizedBox(height: 18.0),
                  DropdownButtonFormField<String>(
                    value: _splitExpense.splitMethod,
                    onChanged: (value) {
                      setState(() {
                        _splitExpense.splitMethod = value!;
                      });
                      _calAmount();
                    },
                    items: Constant.splitMethod
                        .map((method) => DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            ))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Split Method',
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
                  const SizedBox(height: 18.0),
                  DropdownButtonFormField<String>(
                    value: _splitExpense.paidBy.id,
                    onChanged: (value) {
                      setState(() {
                        _splitExpense.paidBy =
                            _members.firstWhere((member) => member.id == value);
                      });
                    },
                    items: _members
                        .map((member) => DropdownMenuItem(
                              value: member.id,
                              child: Text(member.name),
                            ))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Paid by',
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
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    value: 'select',
                    onChanged: (value) {
                      if (_splitExpense.sharedRecords
                          .where((selectedMember) => selectedMember.id == value)
                          .isEmpty) {
                        GroupUser selectedMember =
                            _members.firstWhere((member) => member.id == value);
                        setState(() {
                          _splitExpense.sharedRecords.add(SplitRecord(
                            id: selectedMember.id,
                            name: selectedMember.name,
                            amount: 0,
                            paidAmount: 0,
                            date: DateTime.now(),
                          ));
                          _amountControllers.add(TextEditingController());
                        });
                        _calAmount();
                      }
                    },
                    items: [
                      const DropdownMenuItem(
                        value: 'select',
                        enabled: false,
                        child: Text(
                          'Select member for cost sharing',
                          style: TextStyle(
                            color: Colors.black45,
                          ),
                        ),
                      ),
                      ..._members
                          .map((member) => DropdownMenuItem(
                                value: member.id,
                                child: Text(member.name),
                              ))
                          .toList()
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Share by',
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
                      if (_splitExpense.sharedRecords.isEmpty) {
                        return ValidatorMessage.emptySharedBy;
                      }
                      return null;
                    },
                  ),
                  if (_splitExpense.sharedRecords.isNotEmpty)
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: _splitExpense.sharedRecords.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            child: ListTile(
                              tileColor: Colors.grey[200],
                              contentPadding:
                                  const EdgeInsets.only(left: 0, right: 8),
                              horizontalTitleGap: 0,
                              leading: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _splitExpense.sharedRecords.removeAt(index);
                                      _amountControllers[index].dispose();
                                      _amountControllers.removeAt(index);
                                      _calAmount();
                                    });
                                  }),
                              title: Text(_splitExpense.sharedRecords[index].name),
                              trailing: SizedBox(
                                width: 120,
                                child: TextFormField(
                                  controller: _amountControllers[index],
                                  decoration: const InputDecoration(
                                    labelText: 'Amount',
                                    labelStyle: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(12),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 1),
                                    ),
                                    floatingLabelStyle: TextStyle(fontSize: 0),
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return ValidatorMessage.emptyAmountToPay;
                                    }
                                    if (double.tryParse(value) == null ||
                                        double.parse(value) <= 0) {
                                      return ValidatorMessage
                                          .invalidAmountToPay;
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _splitExpense.splitMethod =
                                          Constant.splitUnequally;

                                      _splitExpense.sharedRecords[index].amount =
                                          double.tryParse(value) == null
                                              ? 0
                                              : double.parse(value);
                                    });
                                  },
                                ),
                              ),
                            ),
                          );
                        }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}