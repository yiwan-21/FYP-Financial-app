import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditTransaction extends StatefulWidget {
  const EditTransaction({super.key});

  @override
  State<EditTransaction> createState() => _EditTransactionState();
}

class _EditTransactionState extends State<EditTransaction> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String? _notes;
  double _amount = 0;
  bool _isExpense = true;
  final List<String> _categories = [
    'Food',
    'Transportation',
    'Rental',
    'Water&Electricity Bill',
    'Internet Bill',
    'Other Utility Bill',
    'Education',
    'Personal Items',
    'Game',
    'Gifts',
    'Donations',
    'Others'
  ];
  String _selectedCategory = '';
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories[0];
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2025));
    if (picked != null) {
      setState(() {
        _date = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // get title, amount, date, isExpense from Navigator.pushNamed
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _title = args['title'];
    _amount = args['amount'];
    _date = args['date'];
    _isExpense = args['isExpense'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Transaction'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 18, 12, 0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  initialValue: _title,
                  decoration: const InputDecoration(
                    labelText: 'Title',
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
                      return 'Please enter your title';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _title = value;
                    });
                  },
                ),
                const SizedBox(height: 18.0),
                TextFormField(
                  initialValue: _notes,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    labelStyle: TextStyle(color: Colors.black),
                    fillColor: Colors.white,
                    filled: true,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 1),
                    ),
                  ),
                  validator: (value) {
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _notes = value;
                    });
                  },
                ),
                const SizedBox(height: 18.0),
                // date
                TextFormField(
                  readOnly: true,
                  onTap: () {
                    _selectDate(context);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Date',
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
                const SizedBox(height: 18.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _amount.toString(),
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
                            borderSide:
                                BorderSide(width: 1.5, color: Colors.red),
                          ),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
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
                    ),
                    const SizedBox(width: 12),
                    CustomSwitch(
                      isIncome: false,
                      onToggle: (value) {
                        setState(() {
                          _isExpense = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 18.0),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                  items: _categories
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
                const SizedBox(height: 20.0),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // backgroundColor: Color.fromRGBO(0, 0, 0, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                    ),
                    child: const Text('Edit Transaction'),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Form is valid, do something
                        _formKey.currentState!.save();
                        // For example, submit the form to a server
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomSwitch extends StatefulWidget {
  const CustomSwitch({
    Key? key,
    required this.onToggle,
    this.isIncome = false,
  }) : super(key: key);

  final Color activeColor = const Color.fromARGB(255, 185, 246, 202);
  final Color inactiveColor = const Color.fromARGB(255, 255, 176, 176);
  final List<String> labels = const ['Income', 'Expense'];
  final ValueChanged<bool> onToggle;
  final bool isIncome;

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _animation;

  bool _value = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _animation = Tween<Offset>(
      begin: const Offset(0.1, 0),
      end: const Offset(3.2, 0),
    ).animate(_controller);
    _value = widget.isIncome;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    _value = !_value;
    widget.onToggle(_value);

    if (_value) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        width: 125.0,
        height: 34.0,
        decoration: BoxDecoration(
          border: _value
              ? Border.all(color: Colors.green[600]!, width: 2.0)
              : Border.all(color: Colors.red[600]!, width: 2.0),
          borderRadius: BorderRadius.circular(16.0),
          color: _value ? widget.activeColor : widget.inactiveColor,
        ),
        child: Padding(
          padding: _value
              ? const EdgeInsets.only(left: 14.0)
              : const EdgeInsets.only(right: 14.0),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.labels[0],
                  style: TextStyle(
                    color: _value ? Colors.black : widget.inactiveColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  widget.labels[1],
                  style: TextStyle(
                    color: _value ? widget.activeColor : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (BuildContext context, Widget? child) {
                  return SlideTransition(
                    // alignment:
                    //     _value ? Alignment.centerRight : Alignment.centerLeft,
                    position: _animation,
                    child: Container(
                      width: 25.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: _value
                            ? Border.all(color: Colors.green[600]!, width: 2.0)
                            : Border.all(color: Colors.red[600]!, width: 2.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.6),
                            blurRadius: 4.0,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
