import 'package:financial_app/components/budget_card.dart';
import 'package:financial_app/components/custom_input_decoration.dart';
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

class _SetBudgetState extends State<SetBudget> {
  final _formKey = GlobalKey<FormState>();
  String _category = Constant.expenseCategories[0];
  double _amount = 0;
  bool _categoryExist = false;
  bool _loading = false;

  Future<void> _setBudget() async {
    setState(() {
      _loading = true;
    });
    // check other fields' validator
    if (_formKey.currentState!.validate()) {
      // check whether the category is exist in database
      _categoryExist = await BudgetService.isCategoryExist(_category);
      if (_formKey.currentState!.validate()) {
        // Submit form data to server or database
        _formKey.currentState!.save();
        await BudgetService.addBudget(BudgetCard(_category, _amount, 0)).then((_) {
              Navigator.pop(context);
        });
      }
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Spending Limit'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: Constant.isMobile(context) ? null : 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 18),
              DropdownButtonFormField<String>(
                value: _category,
                onChanged: (value) {
                  setState(() {
                    _categoryExist = false;
                    _category = value!;
                  });
                },
                items: Constant.expenseCategories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                decoration: customInputDecoration(labelText: 'Category'),
                validator: (value) {
                  if (_categoryExist) {
                    return ValidatorMessage.repeatCategory;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                decoration: customInputDecoration(labelText: 'Amount'),
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
            ],
          ),
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
          onPressed: _loading ? null : _setBudget,
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
