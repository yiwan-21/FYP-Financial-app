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
import '../pages/chat.dart';
import '../providers/notification_provider.dart';
import '../providers/split_money_provider.dart';
import '../providers/total_transaction_provider.dart';
import '../services/chat_service.dart';
import '../services/notification_service.dart';
import '../services/split_money_service.dart';
import '../services/transaction_service.dart';

class SplitMoneyExpense extends StatefulWidget {
  final String expenseID;
  // 0 for record tab, 1 for chat tab
  final int tabIndex;

  const SplitMoneyExpense({required this.expenseID, required this.tabIndex, super.key});

  @override
  State<SplitMoneyExpense> createState() => _SplitMoneyExpenseState();
}

class _SplitMoneyExpenseState extends State<SplitMoneyExpense> with SingleTickerProviderStateMixin {
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

    Provider.of<NotificationProvider>(context, listen: false).getCurrentChatNotification();

    Stream<QuerySnapshot> chatStream = ChatService.getChatStream();
    chatStream.listen((querySnapshot) {
      try {
        // the widget has been disposed of, so don't proceed
        if (!mounted) {
          return;
        }
        
        // the user is currently on the chat page, no need to search for unread messages
        if (_tabController.index == 1) {
          // real time update the read status when message arrives
          updateReadStatus();
          return;
        }

        String userID = FirebaseInstance.auth.currentUser!.uid;
        bool hasUnreadMessage = querySnapshot.docs.last['senderID'] != userID && !querySnapshot.docs.last['readStatus'].contains(userID);

        if (hasUnreadMessage) {
          Provider.of<NotificationProvider>(context, listen: false).setChatNotification(true);
        }
      } catch (e) {
        debugPrint('Split Money Expense Chat Error: $e');
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> updateReadStatus() async {
    await ChatService.updateReadStatus();
  }

  Future<SplitExpense> _getExpense() {
    return SplitMoneyService.getExpenseByID(widget.expenseID);
  }

  void _fetchExpenses() async {
    await _getExpense().then((expense) {
      setState(() {
        _expense = expense;
      });
    });
  }

  bool _isPayer() {
    return FirebaseInstance.auth.currentUser!.uid == _expense.paidBy.id;
  }

  String _getRemainingAmount() {
    double paidAmount = 0;
    for (var record in _expense.sharedRecords) {
      paidAmount += record.paidAmount;
    }
    double amount = _expense.amount - paidAmount;

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
            maxValue: _expense.sharedRecords
                .firstWhere((record) =>
                    record.id == FirebaseInstance.auth.currentUser!.uid)
                .amount,
          );
        });
  }

  Future<void> _onSettleUp(double amount) async {
    SplitMoneyProvider splitMoneyProvider =
        Provider.of<SplitMoneyProvider>(context, listen: false);
    await SplitMoneyService.settleUp(widget.expenseID, amount).then((_) {
      // Update the new paid amount
      setState(() {
        for (var record in _expense.sharedRecords) {
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
      title: 'Settle Up: ${_expense.title}',
      amount: amount,
      date: DateTime.now(),
      isExpense: true,
      category: 'Savings Goal',
      notes:
          'Auto Generated: Pay RM ${_expense.amount.toStringAsFixed(2)} to ${_expense.paidBy.name}',
    );
    await TransactionService.addTransaction(newTransaction).then((_) {
      Provider.of<TotalTransactionProvider>(context, listen: false)
          .updateTransactions();
    });
  }

  Future<void> _remind() async {
    const type = NotificationType.EXPENSE_REMINDER_NOTIFICATION;
    final receiverID = _expense.sharedRecords.map((record) => record.id).toList();
    receiverID.remove(FirebaseInstance.auth.currentUser!.uid);
    final functionID = widget.expenseID;
    await NotificationService.sendNotification(type, receiverID, functionID: functionID);
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
              onPressed: () {
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
              },
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
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
                          'RM ${_expense.amount.toStringAsFixed(2)}',
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
                          'paid by ${_expense.paidBy.name}',
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
                    ..._expense.sharedRecords.map((record) {
                      return SplitRecordCard(record: record);
                    }).toList(),
                  ],
                ),
              ),
            ),
            // Widget for the second tab
            const Chat(),
          ],
        ),
      );
  }
}
