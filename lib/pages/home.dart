import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import '../components/bill_card.dart';
import '../components/budget_card.dart';
import '../components/goal.dart';
import '../components/showcase_frame.dart';
import '../components/split_expense_card.dart';
import '../components/tracker_transaction.dart';
import '../constants/constant.dart';
import '../constants/home_constant.dart';
import '../constants/route_name.dart';
import '../firebase_instance.dart';
import '../models/split_group.dart';
import '../providers/goal_provider.dart';
import '../providers/home_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/split_money_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/user_provider.dart';
import '../providers/show_case_provider.dart';
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
  final List<GlobalKey> _keys = [
    GlobalKey(),
  ];

  @override
  void initState() {
    super.initState();
    _showTour();
  }

  void _showTour() {
    final showcaseProvider = Provider.of<ShowcaseProvider>(context, listen: false);
    if (showcaseProvider.isFirstTime) {
      SharedPreferences.getInstance().then((SharedPreferences prefs) {
        bool firstTime = prefs.getBool(showcaseProvider.firstTimeKey) ?? true;
        if (firstTime) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_keys.contains(showcaseProvider.navTrackerKey)) {
              _keys.add(showcaseProvider.navTrackerKey);
            }
            ShowCaseWidget.of(context).startShowCase(_keys);
          });
        } else {
          showcaseProvider.setFirstTime(firstTime);
        }
      });
    }
  }

  void _navigateToHomeSettings() {
    Navigator.pushNamed(context, RouteName.homeSettings);
  }

  Widget _buildHomeItem(String item, String groupID, String budgetCategory) {
    switch (item) {
      case HomeConstant.recentTransactions:
        return const RecentTransactions();
      case HomeConstant.recentGoal:
        return const RecentGoal();
      case HomeConstant.recentGroupExpense:
        return RecentGroupExpense(groupID: groupID);
      case HomeConstant.budget:
        return RecentBudget(category: budgetCategory);
      case HomeConstant.unpaidBills:
        return const UnpaidBills();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
          margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 5.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              Consumer<UserProvider>(builder: (context, userProvider, _) {
                String image = userProvider.profileImage;
                return Center(
                  child: Container(
                    padding:
                        _isMobile ? const EdgeInsets.only(left: 15.0) : null,
                    constraints: BoxConstraints(
                        maxWidth: _isMobile
                            ? Constant.mobileMaxWidth
                            : min(768 * 2,
                                MediaQuery.of(context).size.width - 40)),
                    child: Row(
                      children: [
                        image.isNotEmpty
                            ? CircleAvatar(
                                radius: _isMobile ? 20.0 : 25.0,
                                backgroundColor: Colors.transparent,
                                backgroundImage: NetworkImage(image),
                              )
                            : CircleAvatar(
                                radius: _isMobile ? 20.0 : 25.0,
                                child: const Icon(
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
                        Row(
                          children: [
                            ShowcaseFrame(
                              showcaseKey: _keys[0],
                              title: "Set Your Home",
                              description: "Customize your home display here.",
                              width: 250,
                              height: 100,
                              child: GestureDetector(
                                onTap: _navigateToHomeSettings,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.settings,
                                      size: 25,
                                      color: Colors.black,
                                    ),
                                    const SizedBox(width: 8),
                                    if (!_isMobile)
                                      const Text(
                                        'Home Settings',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }),
              Consumer<ShowcaseProvider>(
                builder: (context, showcaseProvider, _) {
                  if (showcaseProvider.isFirstTime && !showcaseProvider.isRunning) {
                    _showTour();
                  }
                  return const SizedBox(height: 20.0);
                }
              ),
              Center(
                child:
                    Consumer<HomeProvider>(builder: (context, homeProvider, _) {
                  String groupID = homeProvider.customization.groupID;
                  String budgetCategory =
                      homeProvider.customization.budgetCategory;
                  return Wrap(
                    direction: Axis.horizontal,
                    spacing: 20.0,
                    runSpacing: 10.0,
                    children: homeProvider.customization.items.map((item) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: _isMobile
                                ? Constant.mobileMaxWidth
                                : min(
                                    768,
                                    MediaQuery.of(context).size.width / 2 -
                                        20)),
                        child: _buildHomeItem(item, groupID, budgetCategory),
                      );
                    }).toList(),
                  );
                }),
              ),
              const SizedBox(height: 20.0),
            ],
          )),
    );
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
                Provider.of<NavigationProvider>(context, listen: false)
                    .goToTracker();
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
        Consumer<TransactionProvider>(
          builder: (context, transactionProvider, _) {
            if (transactionProvider.getTransactions.isEmpty) {
              return const Center(child: Text("No transaction yet"));
            }
            
            List<TrackerTransaction> transactions = transactionProvider.getTransactions;
            int endIndex = transactions.length >= 3 ? 3: transactions.length;
            transactions = transactions.sublist(0, endIndex);

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
                Provider.of<NavigationProvider>(context, listen: false)
                    .goToGoal();
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
        Consumer<GoalProvider>(
          builder: (context, goalProvider, _) {
            Goal? pinnedGoal = goalProvider.pinnedGoal;
            if (pinnedGoal == null && goalProvider.goals.isEmpty) {
              return const Center(
                child: Text("No goal yet"),
              );
            }
            return pinnedGoal ?? goalProvider.goals.first;
          },
        ),
      ],
    );
  }
}

class RecentGroupExpense extends StatefulWidget {
  final String groupID;
  const RecentGroupExpense({required this.groupID, super.key});

  @override
  State<RecentGroupExpense> createState() => _RecentGroupExpenseState();
}

class _RecentGroupExpenseState extends State<RecentGroupExpense> {
  Stream<QuerySnapshot> _stream = const Stream.empty();
  Future<String> _future = Future.value('');

  @override
  void initState() {
    super.initState();
    _setGroup();
  }

  void _setGroup() {
    _future = SplitMoneyService.getGroupName(widget.groupID);
    SplitMoneyService.setGroupID(widget.groupID);
    _stream = SplitMoneyService.getExpenseStream(widget.groupID);
  }

  @override
  void didUpdateWidget(covariant RecentGroupExpense oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupID != widget.groupID) {
      _setGroup();
    }
  }

  @override
  void dispose() {
    SplitMoneyService.setGroupID('');
    super.dispose();
  }

  Future<void> navigateToGroup() async {
    await Provider.of<SplitMoneyProvider>(context, listen: false)
        .setNewSplitGroup(widget.groupID)
        .then((SplitGroup group) {
      if (group.id == null) {
        Provider.of<NavigationProvider>(context, listen: false)
            .goToSplitMoney();
      } else {
        Navigator.pushNamed(context, RouteName.splitMoneyGroup,
            arguments: {'id': widget.groupID});
      }
    });
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
                  future: _future,
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.connectionState == ConnectionState.waiting ||
                              snapshot.data == ""
                          ? 'Recent Group Expenses'
                          : '${snapshot.data}\'s Expenses',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  }),
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
            if (snapshot.hasError ||
                FirebaseInstance.auth.currentUser == null) {
              return Text('Something went wrong: ${snapshot.error}');
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text("No group expense yet"));
            }

            List<SplitExpenseCard> expenses = snapshot.data!.docs
                .map((doc) => SplitExpenseCard.fromDocument(doc))
                .toList();

            List<SplitExpenseCard> settled =
                expenses.where((card) => card.isSettle).take(3).toList();
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
  final String category;
  const RecentBudget({required this.category, super.key});

  @override
  State<RecentBudget> createState() => _RecentBudgetState();
}

class _RecentBudgetState extends State<RecentBudget> {
  Stream<DocumentSnapshot> _stream = const Stream.empty();

  @override
  void initState() {
    super.initState();
    _stream = BudgetService.getSingleBudgetStream(widget.category);
  }

  @override
  void didUpdateWidget(covariant RecentBudget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      _stream = BudgetService.getSingleBudgetStream(widget.category);
    }
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
                '${widget.category} Budget',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Provider.of<NavigationProvider>(context, listen: false)
                    .goToBudgeting();
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
        StreamBuilder<DocumentSnapshot>(
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
              return const Center(
                  child: Text("No Budget on this category yet"));
            }

            return BudgetCard(
              widget.category,
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
                Provider.of<NavigationProvider>(context, listen: false)
                    .goToBill();
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
            bills.sort((a, b) => getOnlyDate(a.dueDate)
                .difference(now)
                .inDays
                .abs()
                .compareTo(
                    getOnlyDate(b.dueDate).difference(now).inDays.abs()));
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
