import 'package:financial_app/firebaseInstance.dart';
import 'package:financial_app/providers/goalProvider.dart';
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
  double _totalAmount = 0;
  double _saved = 0;
  double _remaining = 0;
  bool _pinned = false;

  double _progress = 0;
  double _daily = 0;
  double _weekly = 0;
  double _monthly = 0;
  double _addAmount = 0;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final GoalProvider goalProvider =
        Provider.of<GoalProvider>(context, listen: false);
    _id = goalProvider.getId;
    _totalAmount = goalProvider.getAmount;
    _saved = goalProvider.getSaved;
    _remaining = goalProvider.getRemaining;
    _pinned = goalProvider.getPinned;

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Progress'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Plant'),
              Tab(text: 'History'),
            ],
          ),
          actions: [
            IconButton(
              // push_pin with a slash
              icon: Icon(
                _pinned ? Icons.push_pin : Icons.push_pin_outlined,
                semanticLabel: _pinned ? 'Unpin' : 'Pin',
              ),
              onPressed: () async {
                if (!_pinned) {
                  await FirebaseInstance.firestore
                      .collection('goals')
                      .where('userID',
                          isEqualTo: FirebaseInstance.auth.currentUser!.uid)
                      .where('pinned', isEqualTo: true)
                      .get()
                      .then((value) => {
                            for (var goal in value.docs)
                              {
                                FirebaseInstance.firestore
                                    .collection('goals')
                                    .doc(goal.id)
                                    .update({'pinned': false}),
                              }
                          });
                }
                setState(() {
                  _pinned = !_pinned;
                });
                Provider.of<GoalProvider>(context, listen: false)
                    .setPinned(_pinned);
                FirebaseInstance.firestore
                    .collection('goals')
                    .doc(_id)
                    .update({'pinned': _pinned});
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
                                    return AlertDialog(
                                      elevation: 1,
                                      titlePadding: const EdgeInsets.only(
                                          top: 12, left: 16),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 20),
                                      actionsPadding: const EdgeInsets.only(
                                          bottom: 12, right: 16),
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            labelText: 'Amount',
                                            labelStyle:
                                                TextStyle(color: Colors.black),
                                            fillColor: Colors.white,
                                            filled: true,
                                            focusedBorder: OutlineInputBorder(
                                              borderSide:
                                                  BorderSide(width: 1.5),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(width: 1),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1.5,
                                                  color: Colors.red),
                                            ),
                                          ),
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                                RegExp(r'^\d+\.?\d{0,2}')),
                                          ],
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter an amount';
                                            }
                                            if (double.tryParse(value) ==
                                                null) {
                                              return 'Please enter a valid amount';
                                            }
                                            return null;
                                          },
                                          onChanged: (value) {
                                            _addAmount =
                                                double.tryParse(value) == null
                                                    ? 0
                                                    : double.parse(value);
                                          },
                                        ),
                                      ),
                                      actions: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            fixedSize: const Size(100, 40),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                            ),
                                          ),
                                          child: const Text('Save'),
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              // Submit form data to server or database
                                              _formKey.currentState!.save();
                                              if (_addAmount > _remaining) {
                                                _addAmount = _remaining;
                                              }
                                              setState(() {
                                                _saved += _addAmount;
                                                _remaining -= _addAmount;
                                              });
                                              _updateProgress();
                                              Provider.of<GoalProvider>(context,
                                                      listen: false)
                                                  .setSaved(_saved);
                                              FirebaseInstance.firestore
                                                  .collection('goals')
                                                  .doc(_id)
                                                  .update({'saved': _saved});
                                              FirebaseInstance.firestore
                                                  .collection('goals')
                                                  .doc(_id)
                                                  .collection('history')
                                                  .add({
                                                'amount': _addAmount,
                                                'date': DateTime.now(),
                                              });

                                              Navigator.pop(context);
                                            }
                                          },
                                        ),
                                      ],
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
                  future: _getHistory(),
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
