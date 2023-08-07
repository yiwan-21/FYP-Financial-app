import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/message_constant.dart';

class AlertWithCheckbox extends StatefulWidget {
  final String title;
  final String contentLabel;
  final double? defaultValue;
  final double? maxValue;
  final String checkboxLabel;
  final bool defaultChecked;
  final Function(double value) onSaveFunction;
  final Function(double value) checkedFunction;

  const AlertWithCheckbox({
    required this.title, 
    required this.contentLabel, 
    required this.checkboxLabel,
    required this.defaultChecked, 
    required this.onSaveFunction, 
    required this.checkedFunction,
    this.defaultValue, 
    this.maxValue,
    super.key
  });

  @override
  State<AlertWithCheckbox> createState() => _AlertWithCheckboxState();
}

class _AlertWithCheckboxState extends State<AlertWithCheckbox> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  bool _isChecked = true;
  double _value = 0;

  @override
  void initState() {
    super.initState();
    _isChecked = widget.defaultChecked;
    if (widget.defaultValue != null) {
      _controller.text = widget.defaultValue!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _checkMaxValue() {
    if (widget.maxValue != null && _value > widget.maxValue!) {
      _value = widget.maxValue!;
      _controller.text = _value.toStringAsFixed(2);
    }
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
          Text(widget.title),
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
              controller: _controller,
              decoration: InputDecoration(
                labelText: widget.contentLabel,
                labelStyle: const TextStyle(color: Colors.black),
                fillColor: Colors.white,
                filled: true,
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(width: 1.5),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(width: 1),
                ),
                errorBorder: const OutlineInputBorder(
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
                  return ValidatorMessage.emptyAmount;
                }
                if (double.tryParse(value) == null) {
                  return ValidatorMessage.invalidAmount;
                }
                return null;
              },
              onChanged: (value) {
                _value = double.tryParse(value) == null ? 0 : double.parse(value);
                
                _checkMaxValue();
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
                Text(widget.checkboxLabel),
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
