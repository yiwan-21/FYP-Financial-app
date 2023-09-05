import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/message_constant.dart';

class EditBudget extends StatefulWidget {
  const EditBudget({super.key});

  @override
  State<EditBudget> createState() => _EditBudgetState();
}

class _EditBudgetState extends State<EditBudget> {
  final _formKey = GlobalKey<FormState>();
  double amount = 0;

  void editBudget() {
    if (_formKey.currentState!.validate()) {
      // Submit form data to server or database
      _formKey.currentState!.save();
      Navigator.pop(context);
    }
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
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
              amount = double.tryParse(value) == null ? 0 : double.parse(value);
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
          onPressed: editBudget,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
