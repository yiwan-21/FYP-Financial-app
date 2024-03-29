import 'package:financial_app/components/custom_input_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/goal.dart';
import '../constants/message_constant.dart';
import '../services/goal_service.dart';

class GoalForm extends StatefulWidget {
  final bool pinned;
  const GoalForm({required this.pinned, super.key});

  @override
  State<GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends State<GoalForm> {
  final _formKey = GlobalKey<FormState>();
  String _id = '';
  String _title = '';
  double _amount = 0;
  DateTime _date = DateTime.now();
  bool _loading = false;

  Future<void> _selectDate(BuildContext context) async {
    final firstDate = DateTime.now();
    final lastDate = DateTime.now().add(const Duration(days: 30 * 365));
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

  Future<void> addGoal() async {
    setState(() {
      _loading = true;
    });
    if (_formKey.currentState!.validate()) {
      // Submit form data to server or database
      _formKey.currentState!.save();
      final newGoal = Goal(
        id: _id,
        title: _title,
        amount: _amount,
        saved: 0,
        targetDate: _date,
        pinned: widget.pinned,
        createdAt: DateTime.now(),
      );
      await GoalService.addGoal(newGoal).then((value) {
        _id = value.id;
      });
      if (widget.pinned) {
        await GoalService.setPinned(_id, widget.pinned);
      }
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
    setState(() {
      _loading = false;
    });
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
              decoration: customInputDecoration(labelText: 'Goal Title'),
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
              decoration: customInputDecoration(labelText: 'Target Date'),
              controller: TextEditingController(
                text: _date.toString().substring(0, 10),
              ),
            ),
            const SizedBox(height: 24.0),
            TextFormField(
              decoration: customInputDecoration(labelText: 'Total Amount to Save'),
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
            const SizedBox(height: 18.0),
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
                  onPressed: _loading ? null : addGoal,
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