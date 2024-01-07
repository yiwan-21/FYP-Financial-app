import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants/constant.dart';
import '../constants/message_constant.dart';
import '../components/custom_input_decoration.dart';
import '../models/group_user.dart';
import '../models/split_expense.dart';
import '../models/split_record.dart';
import '../providers/split_money_provider.dart';
import '../services/split_money_service.dart';

class GroupExpenseForm extends StatefulWidget {
  const GroupExpenseForm({super.key});

  @override
  State<GroupExpenseForm> createState() => _GroupExpenseFormState();
}

class _GroupExpenseFormState extends State<GroupExpenseForm> {
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
  bool _didChangeAmount = false;
  double _remainingAmount = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      _members = Provider.of<SplitMoneyProvider>(context, listen: false).members!;
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
    }else{
      // reset to 0
      for (var controller in _amountControllers) {
        controller.text = 0.toStringAsFixed(2);
      }
      setState(() {
        for (var record in _splitExpense.sharedRecords) {
          record.amount = 0;
        }
        _remainingAmount = _splitExpense.amount;
      });
    }
  }

  void _calRemainingAmount() {
    if (_didChangeAmount) {
      setState(() {
        _remainingAmount = _splitExpense.amount;
        for (var record in _splitExpense.sharedRecords) {
          _remainingAmount -= record.amount;
        }
        _didChangeAmount = false;
      });
    }
  }

  Future<void> _addGroupExpense() async {
    _calRemainingAmount();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      SplitRecord payer = _splitExpense.sharedRecords
        .firstWhere((record) => record.id == _splitExpense.paidBy.id);
      payer.paidAmount = payer.amount;
      _splitExpense.paidAmount = payer.paidAmount;

      await SplitMoneyService.addExpense(_splitExpense).then((_) {
        Navigator.pop(context, _splitExpense);
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
          children: [
            TextFormField(
              decoration: customInputDecoration(labelText: 'Title'),
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
              decoration: customInputDecoration(labelText: 'Amount'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value!.isEmpty) {
                  return ValidatorMessage.emptyAmount;
                }
                if (double.tryParse(value) == null ||
                    double.parse(value) <= 0) {
                  return ValidatorMessage.invalidAmount;
                }
                if (_remainingAmount != 0) {
                  return ValidatorMessage.invalidTotalAmount;
                }
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _splitExpense.amount =
                      double.tryParse(value) == null ? 0 : double.parse(value);
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
              decoration: customInputDecoration(labelText: 'Split Method'),
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
              decoration: customInputDecoration(labelText: 'Paid by'),
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
              decoration: customInputDecoration(
                labelText: 'Share by',
                helperText: 'Can select multiple members'
              ),
              validator: (value) {
                if (_splitExpense.sharedRecords.isEmpty) {
                  return ValidatorMessage.emptySharedBy;
                }
                return null;
              },
            ),
            if (_splitExpense.splitMethod != Constant.splitEqually)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text("Remaining Amount: ${_remainingAmount.toStringAsFixed(2)}"),
              ),
            if (_splitExpense.sharedRecords.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _splitExpense.sharedRecords.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: ListTile(
                      tileColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.only(left: 0, right: 8),
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
                          decoration: customInputDecoration(
                            labelText: 'Amount',
                            isDense: true,
                            contentPadding: const EdgeInsets.all(12),
                            floatingLabelStyle: const TextStyle(fontSize: 0),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
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
                              return ValidatorMessage.invalidAmountToPay;
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _splitExpense.splitMethod = Constant.splitUnequally;
            
                              _splitExpense.sharedRecords[index].amount =
                                  double.tryParse(value) == null
                                      ? 0
                                      : double.parse(value);
                              _didChangeAmount = true;
                            });
                          },
                          onTap: _calRemainingAmount,
                          onTapOutside: (_) => _calRemainingAmount,
                          onEditingComplete: _calRemainingAmount,
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
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
                  onPressed: _addGroupExpense,
                  child: const Text('Save'),
                ),
                if (!Constant.isMobile(context)) const SizedBox(width: 10),
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
