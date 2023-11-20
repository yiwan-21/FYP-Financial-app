// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/alert_with_checkbox.dart';
import '../components/history_card.dart';
import '../components/tracker_transaction.dart';
import '../components/growing_tree.dart';
import '../components/alert_confirm_action.dart';
import '../constants/constant.dart';
import '../providers/goal_provider.dart';
import '../providers/total_transaction_provider.dart';
import '../services/goal_service.dart';
import '../services/transaction_service.dart';

class GoalDetail extends StatefulWidget {
  const GoalDetail({super.key});

  @override
  State<GoalDetail> createState() => _GoalDetailState();
}

class _GoalDetailState extends State<GoalDetail> {
  String _id = '';
  String _title = '';
  bool _pinned = false;

  @override
  void initState() {
    super.initState();
    final GoalProvider goalProvider =
        Provider.of<GoalProvider>(context, listen: false);
    _id = goalProvider.getId;
    _title = goalProvider.getTitle;
    _pinned = goalProvider.getPinned;
  }

  void _deleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertConfirmAction(
          title: 'Delete Savings Goal',
          content: 'Are you sure you want to delete this goal?',
          cancelText: 'Cancel',
          confirmText: 'Delete',
          confirmAction: _didSpentDialog,
        );
      },
    );
  }

  void _didSpentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertConfirmAction(
          title: 'Did you spent the money?',
          content: 'Did you spent the money saved for this goal?',
          confirmText: 'Yes',
          confirmAction: () => _deleteGoal(true),
          cancelText: 'No',
          cancelAction: () => _deleteGoal(false),
        );
      }
    );
  }

  void _deleteGoal(bool didSpent) async {
    final double saved = Provider.of<GoalProvider>(context, listen: false).getSaved;
    // savings goal expense (debit)
    // cash account income (credit)
    if (saved > 0) {
      if (didSpent) {
        // final TrackerTransaction expenseTransaction = TrackerTransaction(
        //   id: '',
        //   title: 'Completed Goal: $_title',
        //   amount: saved,
        //   date: DateTime.now(),
        //   isExpense: true,
        //   category: 'Savings Goal',
        //   notes: 'Auto Generated: Debit to Savings Goal: $_title',
        // );
        // await TransactionService.addTransaction(expenseTransaction).then((_) async {
        //   await Provider.of<TotalTransactionProvider>(context, listen: false).updateTransactions();
        // });

      } else {
        final TrackerTransaction expenseTransaction = TrackerTransaction(
          id: '',
          title: 'Cancelled Goal: $_title',
          amount: saved,
          date: DateTime.now(),
          isExpense: true,
          category: 'Savings Goal',
          notes: 'Auto Generated: Debit to Savings Goal: $_title',
        );
        await TransactionService.addTransaction(expenseTransaction);
        // return the remaining amount to cash account
        final TrackerTransaction incomeTransaction = TrackerTransaction(
          id: '',
          title: 'Cancelled Goal: $_title',
          amount: saved,
          date: DateTime.now(),
          isExpense: false,
          category: 'Savings Goal',
          notes: 'Auto Generated: Credit to Cash Account',
        );
        await TransactionService.addTransaction(incomeTransaction).then((_) async {
          await Provider.of<TotalTransactionProvider>(context, listen: false).updateTransactions();
        });
      }
    }
    
    await GoalService.deleteGoal(_id).then((_) {
      // quit dialog boxes
      Navigator.pop(context);
      Navigator.pop(context);
      // quit goal progress page
      // to inform the goal has been deleted
      Navigator.pop(context, 'delete');
    });
  }

  void _setPinned() async {
    setState(() {
      _pinned = !_pinned;
    });

    Provider.of<GoalProvider>(context, listen: false).setPinned(_pinned);
  }

  @override
  Widget build(BuildContext context) {
    if (Constant.isMobile(context)) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_title),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Plant'),
                Tab(text: 'History'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteDialog,
              ),
              IconButton(
                // push_pin with a slash
                icon: Icon(
                  _pinned ? Icons.push_pin : Icons.push_pin_outlined,
                  semanticLabel: _pinned ? 'Unpin' : 'Pin',
                ),
                onPressed: _setPinned,
              )
            ],
          ),
          body: const TabBarView(
            children: [
              GoalProgress(),
              GoalHistory(),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(_title),
          actions: [
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.delete),
              onPressed: _deleteDialog,
            ),
            const SizedBox(width: 10),
            IconButton(
              // push_pin with a slash
              iconSize: 30,
              icon: Icon(
                _pinned ? Icons.push_pin : Icons.push_pin_outlined,
                semanticLabel: _pinned ? 'Unpin' : 'Pin',
              ),
              onPressed: _setPinned,
            ),
            const SizedBox(width: 15),
          ],
        ),
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(
                flex: 3,
                child: GoalProgress(),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 50.0, bottom: 50.0, right: 20.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Text('History', style: TextStyle(fontSize: 26)),
                        const Divider(thickness: 1.5, height: 10),
                        SizedBox(height: 10),
                        const Expanded(
                          child: GoalHistory(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

//widget for the first tab
class GoalProgress extends StatefulWidget {
  const GoalProgress({super.key});

  @override
  State<GoalProgress> createState() => _GoalProgressState();
}

class _GoalProgressState extends State<GoalProgress> {
  String _id = '';
  String _title = '';
  double _totalAmount = 0;
  double _saved = 0;
  double _remaining = 0;

  double _progress = 0;
  double _daily = 0;
  double _weekly = 0;
  double _monthly = 0;
  int _days = 0;

  final String _dialogTitle = 'Add Saved Amount';
  final String _contentLabel = 'Amount';
  final String _checkboxLabel = 'Add an expense record';

  @override
  void initState() {
    super.initState();
    final GoalProvider goalProvider =
        Provider.of<GoalProvider>(context, listen: false);
    _id = goalProvider.getId;
    _title = goalProvider.getTitle;
    _totalAmount = goalProvider.getAmount;
    _saved = goalProvider.getSaved;
    _remaining = goalProvider.getRemaining;

    _progress = _saved / _totalAmount * 100;

    _days = goalProvider.targetDate.difference(DateTime.now()).abs().inDays + 1;
    _daily = _remaining / _days;
    _weekly = _remaining / (_days / 7).ceil();
    _monthly = _remaining / (_days / 30).ceil();
  }

  void _updateProgress() {
    setState(() {
      _progress = _saved / _totalAmount * 100;
      _daily = _remaining / _days;
      _weekly = _remaining / (_days / 7).ceil();
      _monthly = _remaining / (_days / 30).ceil();
    });
  }

  void _onSubmit(double value) async {
    if (value > _remaining) {
      value = _remaining;
    }
    setState(() {
      _saved += value;
      _remaining -= value;
    });

    _updateProgress();
    Provider.of<GoalProvider>(context, listen: false).setSaved(_saved);
    await GoalService.updateGoalSavedAmount(_id, _saved);
    await GoalService.addHistory(_id, value);
    await _addTransactionRecords(value);
  }

  void _addProgressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertWithCheckbox(
          title: _dialogTitle,
          contentLabel: _contentLabel,
          checkboxLabel: _checkboxLabel,
          onSaveFunction: _onSubmit,
          disableCheckbox: true,
          maxValue: _remaining,
        );
      },
    );
  }

  Future<void> _addTransactionRecords(double value) async {
    // cash account expense (debit)
    // savings goal income (credit)
    final TrackerTransaction expenseTransaction = TrackerTransaction(
      id: '',
      title: 'Added to Goal: $_title',
      amount: value,
      date: DateTime.now(),
      isExpense: true,
      category: 'Savings Goal',
      notes: 'Auto Generated: Debit to Cash Account',
    );
    await TransactionService.addTransaction(expenseTransaction);
    final TrackerTransaction incomeTransaction = TrackerTransaction(
      id: '',
      title: 'Added to Goal: $_title',
      amount: value,
      date: DateTime.now(),
      isExpense: false,
      category: 'Savings Goal',
      notes: 'Auto Generated: Credit to Savings Goal: $_title',
    );
    await TransactionService.addTransaction(incomeTransaction).then((_) async {
      await Provider.of<TotalTransactionProvider>(context, listen: false).updateTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        GrowingTree(progress: _progress),
        _remaining == 0 
        ? Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 50),
            child: Text(
              'Congratulations! \nYou have completed this goal!',
              textAlign: TextAlign.center,
              maxLines: 2,
              textWidthBasis: TextWidthBasis.parent,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.green,
              ),
            ),
        )
        : Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 20, bottom: 50),
            child: 
            Container(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: const Size(150, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                onPressed: _addProgressDialog,
                child: const Text('Add Goal Progress'),
              ),
            ),
          ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('SAVED',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  Text('RM ${_saved.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
              SizedBox(width: _remaining == 0 ? 0 : 40),
              _remaining == 0
                  ? Container()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('REMAINING',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        Text('RM ${_remaining.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
            ],
          ),
        ),
        if (_remaining != 0)
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 30, top: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: 30),
                    const Text('Daily',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    Text('RM ${_daily.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
                const SizedBox(width: 30),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('SAVINGS PLANS',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    const SizedBox(height: 10),
                    const Text('Weekly',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    Text('RM ${_weekly.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
                const SizedBox(width: 30),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: 30),
                    const Text('Monthly',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                    Text('RM ${_monthly.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

//widget for the second tab
class GoalHistory extends StatefulWidget {
  const GoalHistory({super.key});

  @override
  State<GoalHistory> createState() => _GoalHistoryState();
}

class _GoalHistoryState extends State<GoalHistory> {
  Stream<QuerySnapshot> _stream = const Stream.empty();

  @override
  void initState() {
    super.initState();
    final GoalProvider goalProvider =
        Provider.of<GoalProvider>(context, listen: false);
    _stream = GoalService.getHistoryStream(goalProvider.id);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 768,
        ),
        child: StreamBuilder(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No history yet'),
              );
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong'),
              );
            }

            final List<HistoryCard> historyData =
                snapshot.data!.docs.map((doc) {
              return HistoryCard.fromDocument(doc);
            }).toList();
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: historyData.length,
              itemBuilder: (context, index) {
                return historyData[index];
              },
            );
          },
        ),
      ),
    );
  }
}
