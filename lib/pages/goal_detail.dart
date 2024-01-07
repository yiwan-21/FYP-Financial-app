import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/alert_with_checkbox.dart';
import '../components/goal.dart';
import '../components/history_card.dart';
import '../components/tracker_transaction.dart';
import '../components/growing_tree.dart';
import '../components/alert_confirm_action.dart';
import '../constants/constant.dart';
import '../providers/goal_provider.dart';
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
    final GoalProvider goalProvider = Provider.of<GoalProvider>(context, listen: false);
    final Goal goal = goalProvider.goal;
    _id = goal.id;
    _title = goal.title;
    _pinned = goal.pinned;
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
    final Goal goal = Provider.of<GoalProvider>(context, listen: false).goal;
    // savings goal expense (debit)
    // cash account income (credit)
    if (goal.saved > 0) {
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
          amount: goal.saved,
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
          amount: goal.saved,
          date: DateTime.now(),
          isExpense: false,
          category: 'Savings Goal',
          notes: 'Auto Generated: Credit to Cash Account',
        );
        await TransactionService.addTransaction(incomeTransaction);
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
        body: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: GoalProgress(),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 50.0, bottom: 50.0, right: 20.0),
                  child: Center(
                    child: Column(
                      children: [
                        Text('History', style: TextStyle(fontSize: 26)),
                        Divider(thickness: 1.5, height: 10),
                        SizedBox(height: 10),
                        Expanded(
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

  @override
  void initState() {
    super.initState();
    final GoalProvider goalProvider = Provider.of<GoalProvider>(context, listen: false);
    final Goal goal = goalProvider.goal;
    _id = goal.id;
    _title = goal.title;
    _totalAmount = goal.amount;
    _saved = goal.saved;
    _remaining = goalProvider.goalRemaining;

    _progress = _saved / _totalAmount * 100;

    _days = goal.targetDate.difference(DateTime.now()).abs().inDays + 1;
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
    await GoalService.updateGoalSavedAmount(_id, _saved).then((_) {
      final GoalProvider goalProvider = Provider.of<GoalProvider>(context, listen: false);
      Goal goal = goalProvider.goal;
      goalProvider.setGoal(
        _id,
        _title,
        _totalAmount,
        _saved,
        goal.targetDate,
        goal.pinned,
        goal.createdAt,
      );
    });
    await GoalService.addHistory(_id, value);
    await _addTransactionRecords(value);
  }

  void _addProgressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertWithCheckbox(
          title: 'Save Money to Goal',
          contentLabel: 'Amount',
          checkboxLabel: 'Add an expense record',
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
    await TransactionService.addTransaction(incomeTransaction);
  }

  Widget _savingsPlan() {
    return const Text('SAVINGS PLANS',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ));
  }

  Widget _dailyPlan() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text('Daily',
            style: TextStyle(
                fontSize: 14, color: Colors.grey)),
        Text('RM ${_daily.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }

  Widget _weeklyPlan() {
    return Column(
      children: [
        const Text('Weekly',
            style: TextStyle(
                fontSize: 14,  color: Colors.grey)),
        Text('RM ${_weekly.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }

  Widget _monthlyPlan() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text('Monthly',
            style: TextStyle(
                fontSize: 14, color: Colors.grey)),
        Text('RM ${_monthly.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        GrowingTree(progress: _progress),
        _remaining == 0
            ? const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 50),
                child: Text(
                  'Congratulations! \nYou have completed this goal!',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  textWidthBasis: TextWidthBasis.parent,
                  style: TextStyle(
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
                      fixedSize: const Size(160, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                    onPressed: _addProgressDialog,
                    child: const Text('Add Goal Progress'),
                  ),
                ),
              ),
        Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 40,
              runSpacing: 10,
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
                if (_remaining > 0)
                    Column(
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
          ],
        ),
        if (_remaining != 0)
          Container(
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 30, top: 50),
            child: Column(
              children: [
                _savingsPlan(),
                const SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 15,
                  children: [
                    _dailyPlan(),
                    _weeklyPlan(),
                    _monthlyPlan(),
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
    final GoalProvider goalProvider = Provider.of<GoalProvider>(context, listen: false);
    final Goal goal = goalProvider.goal;
    _stream = GoalService.getHistoryStream(goal.id);
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
