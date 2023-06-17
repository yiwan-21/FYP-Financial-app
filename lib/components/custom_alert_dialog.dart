import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAlertDialog extends StatefulWidget {
  final String title;
  final String contentLabel;
  final double? defaultValue;
  final String checkboxLabel;
  final bool defaultChecked;
  final Function(double value) onSaveFunction;
  final Function(double value) checkedFunction;

  const CustomAlertDialog(this.title, this.contentLabel, this.checkboxLabel,
      this.defaultChecked, this.onSaveFunction, this.checkedFunction,
      {this.defaultValue, super.key});

  @override
  State<CustomAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isChecked = true;
  double _value = 0;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.defaultChecked;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 1,
      titlePadding: const EdgeInsets.only(top: 12, left: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      actionsPadding: const EdgeInsets.only(bottom: 12, right: 16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Add Saved Amount'),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter an amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
              onChanged: (value) {
                _value =
                    double.tryParse(value) == null ? 0 : double.parse(value);
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: _isChecked,
                  onChanged: (value) {
                    setState(() {
                      _isChecked = value!;
                    });
                  },
                ),
                const Text('Add an expense record'),
              ],
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
          child: const Text('Save'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Submit form data to server or database
              _formKey.currentState!.save();
              widget.onSaveFunction(_value);
              if (_isChecked) {
                widget.checkedFunction(_value);
              }
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
