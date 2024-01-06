import 'package:financial_app/components/custom_input_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/message_constant.dart';
import '../services/debt_service.dart';

class DebtForm extends StatefulWidget {
  final bool isEditing;
  final String? id;
  final String? title;
  final double? amount;
  final double? interest;
  final int? year;
  final int? month;

  const DebtForm({
    required this.isEditing,
    this.id,
    this.title,
    this.amount,
    this.interest,
    this.year,
    this.month,
    super.key,
  });

  @override
  State<DebtForm> createState() => _DebtFormState();
}

class _DebtFormState extends State<DebtForm> {
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

      int duration = _year * 12 + _month;
      await DebtService.addDebt(_title, duration, _amount, _interest).then((_) {
        Navigator.pop(context);
      });
    }
  }

  Future<void> _editDebt() async {
    if (_formKey.currentState!.validate()) {
      // Submit form data to server or database
      _formKey.currentState!.save();

      int duration = _year * 12 + _month;
      await DebtService.editDebt(
              widget.id!, _title, duration, _amount, _interest)
          .then((_) {
        Navigator.pop(context);
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
              decoration: customInputDecoration(labelText: 'Debt Title'),
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
                    initialValue: _year == 0 ? null : _year.toString(),
                    decoration: customInputDecoration(labelText: 'Duration(Year)'),
                    keyboardType: const TextInputType.numberWithOptions(),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+')),
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
                        _year =
                            int.tryParse(value) == null ? 0 : int.parse(value);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                const Text("and", style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    initialValue: _month == 0 ? null : _month.toString(),
                    decoration: customInputDecoration(labelText: 'Duration(Month)'),
                    keyboardType: const TextInputType.numberWithOptions(),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+')),
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
                        _month =
                            int.tryParse(value) == null ? 0 : int.parse(value);
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            TextFormField(
              initialValue: _amount == 0 ? null : _amount.toStringAsFixed(2),
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
                return null;
              },
              onChanged: (value) {
                setState(() {
                  _amount =
                      double.tryParse(value) == null ? 0 : double.parse(value);
                });
              },
            ),
            const SizedBox(height: 24.0),
            TextFormField(
              initialValue:
                  _interest == 0 ? null : _interest.toStringAsFixed(2),
              decoration: customInputDecoration(labelText: 'Interest % (optional)'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (value) {
                setState(() {
                  _interest =
                      double.tryParse(value) == null ? 0 : double.parse(value);
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
    );
  }
}
