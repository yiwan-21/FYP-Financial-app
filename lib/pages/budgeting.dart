import 'package:flutter/material.dart';

import '../constants/style_constant.dart';
import '../components/budget_card.dart';
import '../pages/set_budget.dart';

class Budgeting extends StatefulWidget {
  const Budgeting({super.key});

  @override
  State<Budgeting> createState() => _BudgetingState();
}

class _BudgetingState extends State<Budgeting> {
  final TextEditingController _textController = TextEditingController();
  DateTime _resetDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  List<BudgetCard> budget = const [
    BudgetCard('Food', 100, 50),
    BudgetCard('Transportation', 100, 70),
    BudgetCard('Food', 200, 200),
  ];

  @override
  void initState() {
    super.initState();
    _textController.text = _selectedDate.toString().substring(0, 10);
  }

  @override
    void dispose() {
      _textController.dispose();
      super.dispose();
    }

  void setBudget() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return const SetBudget();
        });
  }

  Future<void> _selectDate(BuildContext context) async {
    // pick date and month only TODO: pick start or end date?
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 2),
        initialDatePickerMode: DatePickerMode.day);
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
      _textController.text = _selectedDate.toString().substring(0, 10);
    }
  }

  Future<void> onDateChanged() async {
    setState(() {
      _resetDate = _selectedDate;
    });
    Navigator.pop(context);
    // TODO:  Save the data in database
  }

  void setResetDate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Starting Date'),
          content: TextFormField(
            onTap: () {
              _selectDate(context);
            },
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Monthly Budget Starting Date',
              labelStyle: TextStyle(color: Colors.black),
              suffixIcon: Icon(Icons.calendar_today),
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
            controller: _textController,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: onDateChanged,
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 10),
              const Text(
                'Starting date    :\nResetting date :   ',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Text(
                '${DateTime(_resetDate.year, _resetDate.month - 1, _resetDate.day).toString().substring(0, 10)}\n${_resetDate.toString().substring(0, 10)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: setResetDate,
                child: const Text(
                  'Change',
                  style: TextStyle(
                    color: Colors.pink,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          ...List.generate(
            budget.length,
            (index) => budget[index],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorConstant.lightBlue,
        onPressed: setBudget,
        child: const Icon(
          Icons.note_add_outlined,
          size: 27,
          color: Colors.black,
        ),
      ),
    );
  }
}
