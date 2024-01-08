import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/message_constant.dart';
import '../components/custom_input_decoration.dart';
import '../services/budget_service.dart';

class EditBudget extends StatefulWidget {
  final String category;
  
  const EditBudget(this.category, {super.key});

  @override
  State<EditBudget> createState() => _EditBudgetState();
}

class _EditBudgetState extends State<EditBudget> {
  final _formKey = GlobalKey<FormState>();
  double _amount = 0;
  bool _loading = false;

  Future<void> editBudget() async {
    setState(() {
      _loading = true;
    });
    if (_formKey.currentState!.validate()) {
      // Submit form data to server or database
      _formKey.currentState!.save();
      await BudgetService.updateTotalBudget(widget.category, _amount).then((_) {
        Navigator.pop(context);
      });
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Edit Budget'),
          IconButton(
            iconSize: 20,
            splashRadius: 20,
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          decoration: customInputDecoration(labelText: 'Amount'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
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
              _amount = double.tryParse(value) == null ? 0 : double.parse(value);
            });
          },
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
          onPressed: _loading ? null : editBudget,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
