import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/tracker_transaction.dart';
import '../components/expense_income_graph.dart';
import '../providers/navigation_provider.dart';
import '../providers/total_goal_provider.dart';
import '../providers/total_transaction_provider.dart';
import '../providers/user_provider.dart';

const trackerIndex = 1;
const analyticsIndex = 2;
const goalIndex = 3;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(20.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Consumer<UserProvider>(
              builder: (context, userProvider, _) {
                return Row(
                  children: [
                    FutureBuilder(
                      future: userProvider.profileImage,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.data != null) {
                          return CircleAvatar(
                              radius: 20.0,
                              backgroundImage: NetworkImage(snapshot.data!),
                            );
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
                      }),
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
                  ],
                );
              }
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
                                  .setCurrentIndex(goalIndex);
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
                          return FutureBuilder(
                              future: totalGoalProvider.getPinnedGoal,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                                  return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        return snapshot.data![index];
                                      });
                                } else {
                                  return Container();
                                }
                              });
                        }
                      ),
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
                                  .setCurrentIndex(trackerIndex);
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
                      Consumer<TotalTransactionProvider>(
                        builder: (context, totalTransactionProvider, _) {
                          List<TrackerTransaction> transactions = totalTransactionProvider.getRecentTransactions;
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              return TrackerTransaction(
                                id: transactions[index].id,
                                userID: transactions[index].userID,
                                title: transactions[index].userID, // to undo to 'title'
                                amount: transactions[index].amount,
                                date: transactions[index].date,
                                isExpense: transactions[index].isExpense,
                                category: transactions[index].category,
                                notes: transactions[index].notes,
                              );
                            },
                          );
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
