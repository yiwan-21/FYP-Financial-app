import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/notification_type.dart';
import '../firebase_instance.dart';
import '../components/alert_confirm_action.dart';
import '../components/split_record_card.dart';
import '../components/tracker_transaction.dart';
import '../components/alert_with_checkbox.dart';
import '../constants/constant.dart';
import '../models/split_expense.dart';
import '../models/group_user.dart';
import '../models/split_record.dart';
import '../pages/chat.dart';
import '../providers/notification_provider.dart';
import '../providers/split_money_provider.dart';
import '../services/chat_service.dart';
import '../services/notification_service.dart';
import '../services/split_money_service.dart';
import '../services/transaction_service.dart';

class SplitMoneyExpense extends StatefulWidget {
  final String expenseID;
  // 0 for record tab, 1 for chat tab
  final int tabIndex;

  const SplitMoneyExpense(
      {required this.expenseID, required this.tabIndex, super.key});

  @override
  State<SplitMoneyExpense> createState() => _SplitMoneyExpenseState();
}

class _SplitMoneyExpenseState extends State<SplitMoneyExpense>
    with SingleTickerProviderStateMixin {
  SplitExpense _expense = SplitExpense(
    title: '',
    amount: 0,
    paidAmount: 0,
    paidBy: GroupUser('', '', ''),
    splitMethod: '',
    sharedRecords: [],
    createdAt: DateTime.now(),
  );
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 2);
    _tabController.animateTo(widget.tabIndex);

    _fetchExpenses();
    // set expense ID for chat service
    ChatService.setExpenseID(widget.expenseID);

    Provider.of<NotificationProvider>(context, listen: false)
        .getCurrentChatNotification();

    Stream<QuerySnapshot> chatStream = ChatService.getChatStream();
    chatStream.listen((querySnapshot) {
      try {
        // the widget has been disposed of, so don't proceed
        if (!mounted || querySnapshot.docs.isEmpty) {
          return;
        }

        // the user is currently on the chat page, no need to search for unread messages
        if (_tabController.index == 1 || !Constant.isMobile(context)) {
          // real time update the read status when message arrives
          updateReadStatus();
          return;
        }

        String userID = FirebaseInstance.auth.currentUser!.uid;
        bool hasUnreadMessage = querySnapshot.docs.last['senderID'] != userID &&
            !querySnapshot.docs.last['readStatus'].contains(userID);

        if (hasUnreadMessage) {
          Provider.of<NotificationProvider>(context, listen: false)
              .setChatNotification(true);
        }
      } catch (e) {
        debugPrint('Error on getting chat messages: $e');
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _fetchExpenses() async {
    await SplitMoneyService.getExpenseByID(widget.expenseID).then((expense) {
      setState(() {
        _expense = expense;
      });
    });
  }

  Future<void> updateReadStatus() async {
    await ChatService.updateReadStatus();
  }

  void _deleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertConfirmAction(
          title: 'Delete Expense',
          content: 'Are you sure you want to delete this expense?',
          cancelText: 'Cancel',
          confirmText: 'Delete',
          confirmAction: _deleteExpense,
        );
      },
    );
  }

  Future<void> _deleteExpense() async {
    await SplitMoneyService.deleteExpense(widget.expenseID).then((_) {
      // close the alert dialog
      Navigator.pop(context);
      // close the expense page and go back to the group detail page
      // need to return a value to the group detail page to update the expense list
      // (null will not update the list)
      Navigator.pop(context, 'deleted');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Constant.isMobile(context)) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_expense.title),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              const Tab(text: 'Record'),
              Consumer<NotificationProvider>(
                  builder: (context, notificationProvider, _) {
                return Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Chat'),
                      const SizedBox(width: 10),
                      if (notificationProvider.chatNotification)
                        const Icon(
                          Icons.circle,
                          color: Colors.white,
                          size: 10,
                        ),
                    ],
                  ),
                );
              }),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteDialog,
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Widget for the first tab
            ExpenseRecords(expenseID: widget.expenseID, expense: _expense),
            // Widget for the second tab
            const Chat(),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(_expense.title),
          actions: [
            IconButton(
              iconSize: 30,
              icon: const Icon(Icons.delete),
              onPressed: _deleteDialog,
            ),
            const SizedBox(width: 15),
          ],
        ),
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                flex: 3,
                child: ExpenseRecords(
                  expenseID: widget.expenseID, 
                  expense: _expense,
                ),
              ),
              Flexible(
                flex: 2,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: const Card(
                    elevation: 10,
                    margin: EdgeInsets.only(top: 20, bottom: 40, left: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(0)),
                    ),
                    child: Chat(),
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

// Widget for the first tab
class ExpenseRecords extends StatefulWidget {
  final String expenseID;
  final SplitExpense expense;
  const ExpenseRecords(
      {required this.expenseID, required this.expense, super.key});

  @override
  State<ExpenseRecords> createState() => _ExpenseRecordsState();
}

class _ExpenseRecordsState extends State<ExpenseRecords> {
  bool _isSettle = false;
  bool _allSettle = false;

  @override
  void initState() {
    super.initState();
  }

  bool get _isPayer {
    return FirebaseInstance.auth.currentUser!.uid == widget.expense.paidBy.id;
  }

  String _getRemainingAmount() {
    double paidAmount = 0;
    for (var record in widget.expense.sharedRecords) {
      if (record.id == FirebaseInstance.auth.currentUser!.uid) {
        _isSettle = record.paidAmount == record.amount;
      }
      paidAmount += record.paidAmount;
    }
    double amount = widget.expense.amount - paidAmount;

    setState(() {
      _allSettle = amount == 0;
    });
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
            maxValue: _getMaxValue(),
          );
        });
  }

  double _getMaxValue() {
    SplitRecord record = widget.expense.sharedRecords.firstWhere(
        (record) => record.id == FirebaseInstance.auth.currentUser!.uid);
    return record.amount - record.paidAmount;
  }

  Future<void> _onSettleUp(double amount) async {
    SplitMoneyProvider splitMoneyProvider =
        Provider.of<SplitMoneyProvider>(context, listen: false);
    await SplitMoneyService.settleUp(widget.expenseID, amount).then((_) {
      // Update the new paid amount
      setState(() {
        for (var record in widget.expense.sharedRecords) {
          if (record.id == FirebaseInstance.auth.currentUser!.uid) {
            record.paidAmount += amount;
            break;
          }
        }
      });

      // update expense list
      splitMoneyProvider.updateExpenses();
    });
  }

  Future<void> _checkedFunction(double amount) async {
    final TrackerTransaction newTransaction = TrackerTransaction(
      id: '',
      title: 'Settle Up: ${widget.expense.title}',
      amount: amount,
      date: DateTime.now(),
      isExpense: true,
      category: 'Other Expenses',
      notes:
          'Auto Generated: Pay RM ${widget.expense.amount.toStringAsFixed(2)} to ${widget.expense.paidBy.name}',
    );
    await TransactionService.addTransaction(newTransaction);
  }

  Future<void> _remind() async {
    const type = NotificationType.EXPENSE_REMINDER_NOTIFICATION;
    final receiverID =
        widget.expense.sharedRecords.map((record) => record.id).toList();
    receiverID.remove(FirebaseInstance.auth.currentUser!.uid);
    final functionID = widget.expenseID;
    await NotificationService.sendNotification(type, receiverID,
        functionID: functionID);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 768),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          children: [
            Column(
              children: [
                const SizedBox(height: 30),
                Text(
                  'RM ${widget.expense.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 34,
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
                  'paid by ${widget.expense.paidBy.name}',
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            if (!_allSettle)
              Container(
                alignment: Constant.isMobile(context)
                    ? Alignment.center
                    : Alignment.centerRight,
                margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
                child: _isPayer
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
                    : !_isSettle
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(150, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            onPressed: _settleUp,
                            child: const Text('Settle Up'),
                          )
                        : const SizedBox(height: 40),
              ),
            ...widget.expense.sharedRecords.map((record) {
              return SplitRecordCard(record: record);
            }).toList(),
          ],
        ),
      ),
    );
  }
}
