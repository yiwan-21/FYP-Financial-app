import 'package:financial_app/components/custom_alert_dialog.dart';
import 'package:financial_app/components/transaction.dart';
import 'package:financial_app/firebaseInstance.dart';
import 'package:financial_app/providers/goalProvider.dart';
import 'package:financial_app/providers/totalTransactionProvider.dart';
import 'package:financial_app/services/goal_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../components/growingTree.dart';

class GoalProgress extends StatefulWidget {
  const GoalProgress({super.key});

  @override
  State<GoalProgress> createState() => _GoalProgressState();
}

class _GoalProgressState extends State<GoalProgress>
    with SingleTickerProviderStateMixin {
  String _id = '';
  String _title = '';
  double _totalAmount = 0;
  double _saved = 0;
  double _remaining = 0;
  bool _pinned = false;

  Future<List<HistoryCard>> _history = Future.value([]);

  double _progress = 0;
  double _daily = 0;
  double _weekly = 0;
  double _monthly = 0;

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
    _pinned = goalProvider.getPinned;

    _history = _getHistory();

    _progress = _saved / _totalAmount * 100;
    _daily = _remaining / 30;
    _weekly = _remaining / 4;
    _monthly = _remaining;
  }

  void _updateProgress() {
    setState(() {
      _progress = _saved / _totalAmount * 100;
      _daily = _remaining / 30;
      _weekly = _remaining / 4;
      _monthly = _remaining;
    });
  }

  void _updateHistory() {
    setState(() {
      _history = _getHistory();
    });
  }

  Future<List<HistoryCard>> _getHistory() async {
    final List<HistoryCard> history = [];
    await FirebaseInstance.firestore
        .collection('goals')
        .doc(_id)
        .collection('history')
        .orderBy('date', descending: true)
        .get()
        .then((value) => {
              for (var historyData in value.docs)
                {
                  history.add(
                    HistoryCard(
                      historyData['amount'],
                      historyData['date'].toDate(),
                    ),
                  ),
                }
            });
    return history;
  }

  void _onSave(double value) async {
    if (value > _remaining) {
      value = _remaining;
    }
    setState(() {
      _saved += value;
      _remaining -= value;
    });
    _updateProgress();
    Provider.of<GoalProvider>(context,listen: false).setSaved(_saved);
    await FirebaseInstance.firestore
        .collection('goals')
        .doc(_id)
        .update({'saved': _saved});
    await FirebaseInstance.firestore
        .collection('goals')
        .doc(_id)
        .collection('history')
        .add({
          'amount': value,
          'date': DateTime.now(),
        })
        .then((_) {
          _updateHistory();
        });
  }

  void _checkedFunction(double value) async {
    final TrackerTransaction transaction = TrackerTransaction(
      '',
      FirebaseInstance.auth.currentUser!.uid,
      'Goal: $_title',
      value,
      DateTime.now(),
      true,
      'Savings Goal',
      notes: 'Auto Generated: Saved RM ${value.toStringAsFixed(2)} for $_title',
    );
    await FirebaseInstance.firestore
      .collection('transactions')
      .add(transaction.toCollection())
      .then((_) {
        Provider.of<TotalTransactionProvider>(context, listen: false).updateTransactions();
      });
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {
                showDialog(
                  context: context, 
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Delete Savings Goal'),
                      content: const Text('Are you sure you want to delete this goal?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          }, 
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await FirebaseInstance.firestore
                                .collection("goals")
                                .doc(_id)
                                .delete()
                                .then((_) {
                                  // quit dialog box
                                  Navigator.pop(context);
                                  // quit goal progress page
                                  // need to return something, because
                                  // null returned will not update goal list
                                  Navigator.pop(context, 'deleted');
                                });
                          }, 
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            IconButton(
              // push_pin with a slash
              icon: Icon(
                _pinned ? Icons.push_pin : Icons.push_pin_outlined,
                semanticLabel: _pinned ? 'Unpin' : 'Pin',
              ),
              onPressed: () async {
                setState(() {
                  _pinned = !_pinned;
                });
                if (_pinned) {
                  GoalService.setPinned(_id, _pinned);
                } else {
                  FirebaseInstance.firestore
                    .collection('goals')
                    .doc(_id)
                    .update({'pinned': _pinned});
                }
                Provider.of<GoalProvider>(context, listen: false).setPinned(_pinned);
              },
            )
          ],
        ),
        body: TabBarView(
          children: [
            // Widget for the first tab
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: GrowingTree(progress: _progress)),
                SliverToBoxAdapter(
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: ElevatedButton(
                      onPressed: _remaining == 0
                          ? null
                          : () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomAlertDialog(
                                      _dialogTitle, 
                                      _contentLabel, 
                                      _checkboxLabel,
                                      true,
                                      _onSave,
                                      _checkedFunction,
                                    );
                                  });
                            },
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 213, 242, 255),
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20)),
                      child: Image.asset(
                        'assets/images/wateringCan.png',
                        width: 38,
                        height: 38,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Center(
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
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                        _remaining == 0
                            ? Container()
                            : const SizedBox(width: 30),
                        _remaining == 0
                            ? Container()
                            : Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('REMAINING',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey)),
                                  Text('RM ${_remaining.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ],
                              ),
                      ],
                    ),
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
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
                ),
              ],
            ),
            // Widget for the second tab
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 768,
                ),
                child: FutureBuilder(
                  future: _history,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.data != null) {
                      return ListView(
                        children: List.generate(
                          snapshot.data!.length,
                          (index) {
                            return snapshot.data![index];
                          },
                        ),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final double amount;
  final DateTime date;

  const HistoryCard(this.amount, this.date, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date.toString().substring(0, 10),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '+ ${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            )
          ],
        ),
      ),
    );
  }
}
