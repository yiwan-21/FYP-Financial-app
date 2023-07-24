import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../firebase_instance.dart';
import '../components/transaction.dart';
import '../components/alert_with_checkbox.dart';
import '../constants/constant.dart';
import '../models/split_expense.dart';
import '../providers/total_transaction_provider.dart';
import '../services/split_money_service.dart';
import '../services/transaction_service.dart';

class SplitMoneyExpense extends StatefulWidget {
  final String expenseID;

  const SplitMoneyExpense({required this.expenseID, super.key});

  @override
  State<SplitMoneyExpense> createState() => _SplitMoneyExpenseState();
}

class _SplitMoneyExpenseState extends State<SplitMoneyExpense> {
  SplitExpense _expense = SplitExpense();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() async {
    SplitExpense expense =
        await SplitMoneyService.getExpenseByID(widget.expenseID);
    setState(() {
      _expense = expense;
    });
  }

  bool _isPayer() {
    return _expense.paidBy != null &&
        FirebaseInstance.auth.currentUser!.uid == _expense.paidBy!.id;
  }

  String _getRemainingAmount() {
    if (_expense.records == null || _expense.amount == null) {
      return 'Loading';
    }

    double paidAmount = 0;
    for (var record in _expense.records!) {
      paidAmount += record.paidAmount;
    }
    double amount = _expense.amount! - paidAmount;

    return 'Remaining: RM ${amount.toStringAsFixed(2)}';
  }

  void _settleUp() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertWithCheckbox(
          title: 'Settle Up', 
          contentLabel: 'Amount', 
          checkboxLabel: 'Add a transaction record', 
          defaultChecked: true, 
          onSaveFunction: _onSettleUp, 
          checkedFunction: _checkedFunction,
        );
      }
    );
  }

  void _onSettleUp(double amount) async {
    
  }

  void _checkedFunction(double amount) async {
    final TrackerTransaction newTransaction = TrackerTransaction(
      '',
      FirebaseInstance.auth.currentUser!.uid,
      'Settle Up: ${_expense.title}',
      amount,
      DateTime.now(),
      true,
      'Savings Goal',
      notes: 'Auto Generated: Pay RM ${_expense.amount!.toStringAsFixed(2)} to ${_expense.paidBy!.name}',
    );
    await TransactionService.addTransaction(newTransaction).then((_) {
      Provider.of<TotalTransactionProvider>(context, listen: false)
          .updateTransactions();
    });
  }

  void _remind() {}

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_expense.title ?? 'Split Money'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Record'),
              Tab(text: 'Chat'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Widget for the first tab
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 768),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 30),
                        Text(
                          _expense.amount == null
                              ? 'Loading'
                              : 'RM ${_expense.amount!.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getRemainingAmount(),
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _expense.paidBy == null
                              ? 'Loading'
                              : 'paid by ${_expense.paidBy!.name}',
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        
                      ],
                    ),
                    const SizedBox(height: 15),
                    Container(
                      alignment: Constant.isMobile(context)
                          ? Alignment.center
                          : Alignment.centerRight,
                      margin: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 4),
                      child: _isPayer()
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                fixedSize: const Size(150, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                              onPressed: _remind,
                              child: const Text('Remind'),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                fixedSize: const Size(150, 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                              onPressed: _settleUp,
                              child: const Text('Settle Up'),
                            ),
                    ),
                    ..._expense.records ?? [],
                  ],
                ),
              ),
            ),
            // Widget for the second tab
            Container(),
          ],
        ),
      ),
    );
  }
}
