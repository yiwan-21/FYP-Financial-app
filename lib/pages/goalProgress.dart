import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../components/growingTree.dart';
import '../constants.dart';

class GoalProgress extends StatefulWidget {
  const GoalProgress({super.key});

  @override
  State<GoalProgress> createState() => _GoalProgressState();
}

class _GoalProgressState extends State<GoalProgress>
    with SingleTickerProviderStateMixin {
  final double _totalAmount = 3000;
  double _saved = 2000;
  double _remaining = 1000;
  double _addAmount = 0;
  double _daily = 0;
  double _weekly = 0;
  double _monthly = 0;

  double _progress = 0;
  final List<HistoryCard> _historyCard = [
    HistoryCard(amount: 2000, date: DateTime.now()),
  ];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _progress = _saved / _totalAmount * 100;
    _daily = _remaining / 30;
    _weekly = _remaining / 4;
    _monthly = _remaining;
  }

  void _onAddAmount() {
    setState(() {
      _progress = _saved / _totalAmount * 100;
      _daily = _remaining / 30;
      _weekly = _remaining / 4;
      _monthly = _remaining;
    });
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
                                                _historyCard.add(HistoryCard(
                                                    amount: _addAmount,
                                                    date: DateTime.now()));
                                              });
                                              _onAddAmount();
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
                        _remaining == 0 ? Container() : const SizedBox(width: 30),
                        _remaining == 0 ? Container() : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                child: ListView(
                  children: List.generate(
                    _historyCard.length,
                    ((index) {
                      final reversedIndex = _historyCard.length - index - 1;
                      return _historyCard[reversedIndex];
                    }),
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

class HistoryCard extends StatelessWidget {
  final double amount;
  final DateTime date;

  const HistoryCard({required this.amount, required this.date, super.key});

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
              '+ $amount',
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
