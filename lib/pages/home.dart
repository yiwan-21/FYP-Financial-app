import 'package:financial_app/firebaseInstance.dart';
import 'package:financial_app/providers/navigationProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'analytics.dart';
import '../components/transaction.dart';
import '../components/goal.dart';
import '../providers/userProvider.dart';

const TrackerIndex = 1;
const AnalyticsIndex = 2;
const GoalIndex = 3;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<List<TrackerTransaction>> _getTransactions() async {
    List<TrackerTransaction> _transactions = [];
    await FirebaseInstance.firestore
        .collection('transactions')
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .orderBy('date', descending: true)
        .limit(3)
        .get()
        .then((event) {
      for (var transaction in event.docs) {
        _transactions.add(TrackerTransaction(
          transaction.id,
          transaction['userID'],
          transaction['title'],
          transaction['amount'].toDouble(),
          transaction['date'].toDate(),
          transaction['isExpense'],
          transaction['category'],
          notes: transaction['notes'],
        ));
      }
    });
    return _transactions;
  }

  Future<List<Goal>> _getGoals() async {
    final List<Goal> goalData = [];

    await FirebaseInstance.firestore
        .collection('goals')
        .where('userID', isEqualTo: FirebaseInstance.auth.currentUser!.uid)
        .orderBy('pinned', descending: true)
        .orderBy('targetDate', descending: false)
        .limit(1)
        .get()
        .then((value) => {
              for (var goal in value.docs)
                {
                  goalData.add(Goal(
                    goal.id,
                    goal['userID'],
                    goal['title'],
                    goal['amount'].toDouble(),
                    goal['saved'].toDouble(),
                    goal['targetDate'].toDate(),
                    goal['pinned'],
                  )),
                }
            });
    return goalData;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(20.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Row(
              children: [
                Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    return FutureBuilder(
                        future: userProvider.profileImage,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done &&
                              snapshot.data != null) {
                            return CircleAvatar(
                                radius: 20.0,
                                backgroundImage: NetworkImage(snapshot.data!));
                          } else {
                            return const CircleAvatar(
                              radius: 20.0,
                              child: Icon(
                                Icons.account_circle,
                                color: Colors.white,
                                size: 40.0,
                              ),
                            );
                          }
                        });
                  }
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
                    Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        return Text(
                          userProvider.name,
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            Flex(
              crossAxisAlignment: CrossAxisAlignment.start,
              direction: MediaQuery.of(context).size.width < 768
                  ? Axis.vertical
                  : Axis.horizontal,
              children: [
                Flexible(
                  flex: MediaQuery.of(context).size.width < 768 ? 0 : 1,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
                            child: Text(
                              'Recent Goals',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Provider.of<NavigationProvider>(context,
                                      listen: false)
                                  .setCurrentIndex(GoalIndex);
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
                      FutureBuilder(
                          future: _getGoals(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.data != null) {
                              return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return snapshot.data![index];
                                  });
                            } else {
                              return Container();
                            }
                          }),
                      const SizedBox(height: 40.0),
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
                              Provider.of<NavigationProvider>(context,
                                      listen: false)
                                  .setCurrentIndex(TrackerIndex);
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
                      FutureBuilder(
                        future: _getTransactions(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              snapshot.data != null) {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return TrackerTransaction(
                                  snapshot.data![index].id,
                                  snapshot.data![index].userID,
                                  snapshot.data![index].title,
                                  snapshot.data![index].amount,
                                  snapshot.data![index].date,
                                  snapshot.data![index].isExpense,
                                  snapshot.data![index].category,
                                  notes: snapshot.data![index].notes,
                                );
                              },
                            );
                          } else {
                            return const Text('No transactions found');
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Flexible(
                  flex: MediaQuery.of(context).size.width < 768 ? 0 : 1,
                  child: Column(
                    children: const [
                      ExpenseIncomeGraph(),
                    ],
                  ),
                )
              ],
            )
          ],
        ));
  }
}
