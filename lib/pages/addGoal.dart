import 'package:financial_app/firebaseInstance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants.dart';
import '../components/goal.dart';

class AddGoal extends StatefulWidget {
  const AddGoal({super.key});

  @override
  State<AddGoal> createState() => _AddGoalState();
}

class _AddGoalState extends State<AddGoal> {
  final _formKey = GlobalKey<FormState>();
  String _id = '';
  String _title = '';
  double _amount = 0;
  DateTime _date = DateTime.now();
 
  Future<void> _selectDate(BuildContext context) async {
    final firstDate = DateTime.now().add(const Duration(days: 7));
    final lastDate = DateTime.now().add(const Duration(days: 5 * 365));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Goal'),
        ),
        body: Container(
          alignment: Constants.isMobile(context)
              ? Alignment.topCenter
              : Alignment.center,
          child: SingleChildScrollView(
            child: Container(
              decoration: Constants.isMobile(context)
                  ? null
                  : BoxDecoration(
                      border: Border.all(color: Colors.black45, width: 1),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38.withOpacity(0.2),
                          offset: const Offset(3, 5),
                          blurRadius: 5.0,
                        )
                      ],
                    ),
              width: Constants.isMobile(context) ? null : 500,
              padding: Constants.isMobile(context)
                  ? null
                  : const EdgeInsets.fromLTRB(24, 40, 24, 24),
              margin: Constants.isMobile(context)
                  ? const EdgeInsets.fromLTRB(12, 24, 12, 0)
                  : null,
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Goal Title',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter goal's title";
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
                    decoration: const InputDecoration(
                      labelText: 'Target Date',
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
                    controller: TextEditingController(
                      text: _date.toString().substring(0, 10),
                    ),
                  ),
                    const SizedBox(height: 24.0),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Total Amount to Save',
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
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid amount';
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
                          child: const Text('Save'),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Submit form data to server or database
                              _formKey.currentState!.save();
                              final new_goal = Goal(
                                _id,
                                FirebaseInstance.auth.currentUser!.uid,
                                _title,
                                _amount,
                                0,
                                _date,
                                false,
                              );

                              FirebaseInstance.firestore.collection('goals').add(new_goal.toCollection());
                              Navigator.pop(context, new_goal);
                            }
                          },
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
            ),
          ),
        ));
  }
}
