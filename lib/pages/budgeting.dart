import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constants/constant.dart';
import '../constants/style_constant.dart';
import '../components/budget_card.dart';
import '../pages/set_budget.dart';
import '../providers/show_case_provider.dart';
import '../services/budget_service.dart';

class Budgeting extends StatefulWidget {
  const Budgeting({super.key});

  @override
  State<Budgeting> createState() => _BudgetingState();
}

class _BudgetingState extends State<Budgeting> {
  final Future<Stream<QuerySnapshot>> _streamFuture =
      BudgetService.getBudgetingStream();
  final TextEditingController _textController = TextEditingController();
  DateTime _startingDate = DateTime.now();
  DateTime _resetDate = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  List<BudgetCard> budget = [];


  bool get _isMobile => Constant.isMobile(context);
  final List<GlobalKey> _webKeys = [
    GlobalKey(),
  ];
  final List<GlobalKey> _mobileKeys = [
    GlobalKey(),
  ];
  bool _showcasingWebView = false;
  
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
    
    ShowcaseProvider showcaseProvider = Provider.of<ShowcaseProvider>(context, listen: false);
    if (showcaseProvider.isFirstTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mobileKeys.add(showcaseProvider.navMoreKey);
        _mobileKeys.add(showcaseProvider.navBillKey);
        _webKeys.add(showcaseProvider.navMoreKey);
        _webKeys.add(showcaseProvider.navBillKey);
        if (_isMobile) {
          ShowCaseWidget.of(context).startShowCase(_mobileKeys);
          _showcasingWebView = false;
        } else {
          ShowCaseWidget.of(context).startShowCase(_webKeys);
          _showcasingWebView = true;
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ShowcaseProvider showcaseProvider = Provider.of<ShowcaseProvider>(context, listen: false);
    if (kIsWeb && showcaseProvider.isRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (_showcasingWebView && _isMobile) {
          // If the showcase is running on web and the user switches to mobile view
          await Future.delayed(const Duration(milliseconds: 300)).then((_) {
            ShowCaseWidget.of(context).startShowCase(_mobileKeys);
            _showcasingWebView = false;
          });
        } else if (!_showcasingWebView && !_isMobile) {
          // If the showcase is running on mobile and the user switches to web view
          ShowCaseWidget.of(context).startShowCase(_webKeys);
          _showcasingWebView = true;
        }
      });
    }
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
              border: OutlineInputBorder(
                borderSide: BorderSide(width: 1),
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
              _isMobile
                  ? Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10))
                  : Container(
                      alignment: Alignment.bottomRight,
                      margin:
                          const EdgeInsets.only(top: 10, bottom: 10, right: 8),
                      child: Showcase(
                        key: _webKeys[0],
                        title: "Budget",
                        description: "Set Your Budget here",
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(100, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          onPressed: setBudget,
                          child: const Text('Set Budget'),
                        ),
                      ),
                    ),
              FutureBuilder(
                future: _streamFuture,
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
      floatingActionButtonLocation: _isMobile
          ? FloatingActionButtonLocation.startFloat
          : null,
      floatingActionButton: _isMobile
          ? Showcase(
              key: _mobileKeys[0],
              title: "Budget",
              description: "Set Your Budget here",
              child: FloatingActionButton(
                backgroundColor: ColorConstant.lightBlue,
                onPressed: setBudget,
                child: const Icon(
                  Icons.note_add_outlined,
                  size: 27,
                  color: Colors.black,
                ),
              ),
            )
          : null,
    );
  }
}
