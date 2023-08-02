import 'package:financial_app/models/split_expense.dart';
import 'package:financial_app/services/split_money_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants/constant.dart';
import '../constants/message_constant.dart';
import '../models/group_user.dart';
import '../providers/split_money_provider.dart';

class AddGroupExpense extends StatefulWidget {
  const AddGroupExpense({Key? key}) : super(key: key);

  @override
  State<AddGroupExpense> createState() => _AddGroupExpenseState();
}

class _AddGroupExpenseState extends State<AddGroupExpense> {
  final _formKey = GlobalKey<FormState>();
  final List<String> _splitMethodList = Constant.splitMethod;
  List<GroupUser> _members = [];
  String _title = '';
  double _amount = 0;
  GroupUser _selectedPayMember = GroupUser('', '', '');
  String _splitMethod = Constant.splitMethod[0];
  List<GroupUser> _sharedBy = [];
  List<double> _amountToPay = [];
  bool _isOpen = false;

  void _toggleOpen() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _members =
          Provider.of<SplitMoneyProvider>(context, listen: false).members!;
      _selectedPayMember = _members[0];
    });
  }

  List<GroupUser> _getShareMember() {
    return _members
        .where((member) =>
            member.id != _selectedPayMember.id &&
            _sharedBy.where((selected) => selected.id == member.id).isEmpty)
        .toList();
  }

  // TODO: split method
  String _calAmount() {
    switch (_splitMethod) {
      case 'Equally':
        return (_amount/_sharedBy.length).toStringAsFixed(2);
      case 'Unequally':
        return '0.00';
      
      default:
        return '';
    }
  }

  void _addGroupExpense() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newGroupExpense = SplitExpense(
        title: _title,
        amount: _amount,
        splitMethod: _splitMethod,
        paidBy: _selectedPayMember,
        sharedBy: _sharedBy,
      );

      String groupID =
          Provider.of<SplitMoneyProvider>(context, listen: false).id!;
      SplitMoneyService.addExpense(groupID, newGroupExpense).then((_) {
        Navigator.pop(context, newGroupExpense);
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
                        _title = value;
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
                  const SizedBox(height: 18.0),
                  DropdownButtonFormField<String>(
                    value: _splitMethod,
                    onChanged: (value) {
                      setState(() {
                        _splitMethod = value!;
                      });
                    },
                    items: _splitMethodList
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
                    value: _selectedPayMember.id,
                    onChanged: (value) {
                      setState(() {
                        _selectedPayMember =
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
                      if (_sharedBy
                          .where((selectedMember) => selectedMember.id == value)
                          .isEmpty) {
                        setState(() {
                          _sharedBy.add(
                            _members.firstWhere((member) => member.id == value),
                          );
                          _amountToPay.add(0);
                        });
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
                      if (_sharedBy.isEmpty) {
                        return ValidatorMessage.emptySharedBy;
                      }
                      return null;
                    },
                  ),
                  if (_sharedBy.isNotEmpty)
                    // Align(
                    //   alignment: Alignment.centerLeft,
                    //   child: Wrap(
                    //     children: _sharedBy.map((member) {
                    //       return Padding(
                    //         padding: const EdgeInsets.symmetric(horizontal: 4),
                    //         child: Chip(
                    //           label: Text(member.name),
                    //           onDeleted: () {
                    //             setState(() {
                    //               _sharedBy.remove(member);
                    //             });
                    //           },
                    //         ),
                    //       );
                    //     }).toList(),
                    //   ),
                    // ),
                    ListView.builder(
                        shrinkWrap: true,
                        itemCount: _sharedBy.length,
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
                                    _sharedBy.removeAt(index);
                                    _amountToPay.removeAt(index);
                                  });
                                }
                              ),
                              title: Text(_sharedBy[index].name),
                              trailing: SizedBox(
                                width: 120,
                                height: 40,
                                child: TextFormField(
                                  initialValue: _calAmount(),
                                  decoration: const InputDecoration(
                                    labelText: 'Amount',
                                    labelStyle: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 1),
                                    ),
                                    floatingLabelStyle: TextStyle(fontSize: 0),
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
                                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                      return ValidatorMessage.invalidAmountToPay;
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      _amountToPay[index] =
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
