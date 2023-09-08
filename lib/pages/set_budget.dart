import 'package:financial_app/components/budget_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/constant.dart';
import '../constants/message_constant.dart';
import '../services/budget_service.dart';

class SetBudget extends StatefulWidget {
  const SetBudget({Key? key}) : super(key: key);

  @override
  State<SetBudget> createState() => _SetBudgetState();
}

//TODO: no repeat category -create a category list, filter with existed, return
class _SetBudgetState extends State<SetBudget> {
  final _formKey = GlobalKey<FormState>();
  String _category = Constant.expenseCategories[0];
  double amount = 0;

  void _setBudget() {
    if (_formKey.currentState!.validate()) {
      // Submit form data to server or database
      _formKey.currentState!.save();
      BudgetService.addBudget(BudgetCard(_category, amount, 0));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Spending Limit'),
      content: SizedBox(
        width: Constant.isMobile(context) ? null : 500,
        child: Flex(
          direction:
              Constant.isMobile(context) ? Axis.vertical : Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 18),
            Flexible(
              child: DropdownButtonFormField<String>(
                value: _category,
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
                items: Constant.expenseCategories
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
            ),
            const SizedBox(height: 18),
            Flexible(
              child: Form(
                key: _formKey,
                child: TextFormField(
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
                      amount = double.tryParse(value) == null
                          ? 0
                          : double.parse(value);
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(100, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
          onPressed: _setBudget,
          child: const Text('Set'),
        ),
        if (!Constant.isMobile(context)) const SizedBox(width: 12),
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
    );
  }
}
