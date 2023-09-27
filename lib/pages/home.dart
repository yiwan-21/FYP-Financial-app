import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/bill_card.dart';
import '../components/budget_card.dart';
import '../components/goal.dart';
import '../components/split_expense_card.dart';
import '../components/tracker_transaction.dart';

import '../constants/constant.dart';
import '../constants/home_constant.dart';
import '../constants/route_name.dart';
import '../providers/home_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/split_money_provider.dart';
import '../providers/total_goal_provider.dart';
import '../providers/total_transaction_provider.dart';
import '../providers/user_provider.dart';
import '../services/bill_service.dart';
import '../services/budget_service.dart';
import '../services/split_money_service.dart';
import '../utils/date_utils.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool get _isMobile => Constant.isMobile(context);
  List<Widget> _items = [];

  @override
  void initState() {
    super.initState();
    _items = _getHomeItems();
  }

  void _navigateToHomeSettings() {
    Navigator.pushNamed(context, RouteName.homeSettings);
  }

  List<Widget> _getHomeItems() {
    final List<Widget> items = [];
    Provider.of<HomeProvider>(context, listen: false).displayedItems.forEach((item) {
      HomeConstant.homeItems.forEach((key, value) {
        if (item == key) {
          items.add(value);
        }
      });
    });

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 5.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Consumer<UserProvider>(builder: (context, userProvider, _) {
              String image = userProvider.profileImage;
              return Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Row(
                  children: [
                    image.isNotEmpty
                        ? CircleAvatar(
                            radius: 20.0,
                            backgroundImage: NetworkImage(image),
                          )
                        : const CircleAvatar(
                            radius: 20.0,
                            child: Icon(
                              Icons.account_circle,
                              color: Colors.white,
                              size: 40.0,
                            ),
                          ),
                    const SizedBox(width: 20.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello,",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          userProvider.name,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: _navigateToHomeSettings,
                      icon: const Icon(Icons.settings),
                    ),
                  ],
                ),
              );
            }),
            
            const SizedBox(height: 20.0),
            Wrap(
              direction: Axis.horizontal,
              spacing: 20.0,
              children: _items.map((item) {
                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: _isMobile ? Constant.mobileMaxWidth : (MediaQuery.of(context).size.width / 2 - 20)),
                  child: item,
                );
              }).toList(),
            ),
          ],
        ));
  }
}

class RecentTransactions extends StatefulWidget {
  const RecentTransactions({super.key});

  @override
  State<RecentTransactions> createState() => _RecentTransactionsState();
}

class _RecentTransactionsState extends State<RecentTransactions> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
              child: Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Provider.of<NavigationProvider>(context, listen: false).goToTracker();
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
            ),
          ],
        ),
        StreamBuilder<QuerySnapshot>(
          stream: Provider.of<TotalTransactionProvider>(context, listen: false).getHomeTransactionsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Text(
                  'Something went wrong: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text("No transaction yet"));
            }
    
            List<TrackerTransaction> transactions = snapshot
                .data!.docs
                .take(3)
                .map((doc) => TrackerTransaction.fromDocument(doc))
                .toList();
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return transactions[index];
              },
            );
          },
        ),
      ],
    );
  }
}


class RecentGoal extends StatefulWidget {
  const RecentGoal({super.key});

  @override
  State<RecentGoal> createState() => _RecentGoalState();
}

class _RecentGoalState extends State<RecentGoal> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
              child: Text(
                'Recent Goal',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Provider.of<NavigationProvider>(context, listen: false).goToGoal();
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
            ),
          ],
        ),
        Consumer<TotalGoalProvider>(
          builder: (context, totalGoalProvider, _) {
            List<Goal> goal = totalGoalProvider.getPinnedGoal;
            if (goal.isEmpty) {
              return const Center(
                child: Text("No goal yet"),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: goal.length,
              itemBuilder: (context, index) {
                return goal[index];
              },
            );
          },
        ),
      ],
    );
  }
}


class RecentGroupExpense extends StatefulWidget {
  const RecentGroupExpense({super.key});

  @override
  State<RecentGroupExpense> createState() => _RecentGroupExpenseState();
}

class _RecentGroupExpenseState extends State<RecentGroupExpense> {
  // let user select group in customization setting page
  // show the recent group expenses of the selected group
  final String _groupID = '6ytSklvH87EYQUfVCfCN'; // ID of 'test' group
  Stream<QuerySnapshot> _stream = const Stream.empty();

  @override
  void initState() {
    super.initState();
    SplitMoneyService.setGroupID(_groupID);
    _stream = SplitMoneyService.getExpenseStream(_groupID);
  }

  void navigateToGroup() {
    Provider.of<SplitMoneyProvider>(context, listen: false).setNewSplitGroup(_groupID);
    Navigator.pushNamed(context, RouteName.splitMoneyGroup);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
              child: FutureBuilder(
                future: SplitMoneyService.getGroupName(_groupID),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.connectionState == ConnectionState.waiting 
                      ? 'Recent Group Expenses'
                      : '${snapshot.data}\'s Expenses',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
              ),
            ),
            TextButton(
              onPressed: navigateToGroup,
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
            ),
          ],
        ),
        StreamBuilder<QuerySnapshot>(
          stream: _stream, 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Text(
                  'Something went wrong: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text("No group expense yet"));
            }
            
            List<SplitExpenseCard> expenses = snapshot
                .data!.docs
                .map((doc) => SplitExpenseCard.fromDocument(doc))
                .toList();       
    
            List<SplitExpenseCard> settled = expenses.where((card) => card.isSettle).take(3).toList();
            expenses.removeWhere((card) => card.isSettle);
            expenses = expenses.followedBy(settled).take(3).toList();
    
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                return expenses[index];
              },
            );
          },
        ),
      ],
    );
  }
}


class RecentBudget extends StatefulWidget {
  const RecentBudget({super.key});

  @override
  State<RecentBudget> createState() => _RecentBudgetState();
}

class _RecentBudgetState extends State<RecentBudget> {
  // let user select category in customization setting page
  final String _category = Constant.expenseCategories[0]; // 'Food' category
  Stream<DocumentSnapshot> _stream = const Stream.empty();

  @override
  void initState() {
    super.initState();
    _stream = BudgetService.getSingleBudgetStream(_category);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
              child: Text(
                '$_category Budget',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Provider.of<NavigationProvider>(context, listen: false).goToBudgeting();
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
            ),
          ],
        ),
        StreamBuilder(
          stream: _stream, 
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Text('Something went wrong: ${snapshot.error}');
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("No Budget on this category yet"));
            }

            return BudgetCard(
              _category,
              snapshot.data!['amount'].toDouble(),
              snapshot.data!['used'].toDouble(),
            );
          },
        ),
      ],
    );
  }
}


class UnpaidBills extends StatefulWidget {
  const UnpaidBills({super.key});

  @override
  State<UnpaidBills> createState() => _UnpaidBillsState();
}

class _UnpaidBillsState extends State<UnpaidBills> {
  Stream<QuerySnapshot> _stream = const Stream.empty();

  @override
  void initState() {
    super.initState();
    _stream = BillService.getBillStream();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
              child: Text(
                'Unpaid Bills',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Provider.of<NavigationProvider>(context, listen: false).goToBill();
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
            ),
          ],
        ),
        StreamBuilder<QuerySnapshot>(
          stream: _stream, 
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
                child: Text("No Bill Yet"),
              );
            }
    
            List<BillCard> bills = snapshot.data!.docs
                .where((doc) => !doc['paid'])
                .map((doc) => BillCard.fromDocument(doc))
                .toList();
            DateTime now = getOnlyDate(DateTime.now());
            // due date closest to now
            bills.sort((a, b) => getOnlyDate(a.dueDate).difference(now).inDays.abs().compareTo(getOnlyDate(b.dueDate).difference(now).inDays.abs()));
            bills = bills.take(2).toList();
    
            if (bills.isEmpty) {
              return const Center(
                child: Text("All bills are paid"),
              );
            }
            
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bills.length,
              itemBuilder: (context, index) {
                return bills[index];
              },
            );
          },
        ),
      ],
    );
  }
}
