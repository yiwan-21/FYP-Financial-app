import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/style_constant.dart';
import '../components/budget_card.dart';
import '../pages/set_budget.dart';
import '../services/budget_service.dart';

class Budgeting extends StatefulWidget {
  const Budgeting({super.key});

  @override
  State<Budgeting> createState() => _BudgetingState();
}

class _BudgetingState extends State<Budgeting> {
  final TextEditingController _textController = TextEditingController();
  DateTime _startingDate = DateTime.now();
  DateTime _resetDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  List<BudgetCard> budget = [];

  @override
  void initState() {
    super.initState();
    BudgetService.resetBudget().then((_) {
      setState(() {
        _startingDate = BudgetService.startingDate;
        _resetDate = BudgetService.resettingDate;
        _selectedDate = _resetDate;
      });
      _textController.text = _selectedDate.toString().substring(0, 10);
    });
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
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(
            DateTime.now().year, DateTime.now().month + 1, DateTime.now().day),
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
    await BudgetService.updateDate(_selectedDate).then((_) {
      Navigator.pop(context);
    });
  }

  void setResetDate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Resetting Date'),
          content: TextFormField(
            onTap: () {
              _selectDate(context);
            },
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Monthly Budget Resetting Date',
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 768,
          ),
          child: ListView(
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
                    '${_startingDate.toString().substring(0, 10)}\n${_resetDate.toString().substring(0, 10)}',
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
              FutureBuilder(
                future: BudgetService.getBudgetingStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData) {
                    return const Center(
                      child: Text("No budgeting yet"),
                    );
                  }
                  return StreamBuilder<QuerySnapshot>(
                    stream: snapshot.data,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("No budgeting yet"),
                        );
                      }
                      List<BudgetCard> budgets = [];
                      for (var doc in snapshot.data!.docs) {
                        budgets.add(BudgetCard(
                          doc.id,
                          doc['amount'].toDouble(),
                          doc['used'].toDouble(),
                        ));
                      }
                      return ListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List.generate(
                          budgets.length,
                          (index) => budgets[index],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
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
