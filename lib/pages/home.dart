import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/goal.dart';
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
            Consumer<UserProvider>(builder: (context, userProvider, _) {
              String image = userProvider.profileImage;
              return Row(
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
                ],
              );
            }),
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
                        List<Goal> goal = totalGoalProvider.getPinnedGoal;
                        return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: goal.length,
                            itemBuilder: (context, index) {
                              return goal[index];
                            });
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
                      StreamBuilder<QuerySnapshot>(
                        stream: Provider.of<TotalTransactionProvider>(context, listen: false).getHomeTransactionsStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                              .map(
                                  (doc) => TrackerTransaction.fromDocument(doc))
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
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Flexible(
                  flex: MediaQuery.of(context).size.width < 768 ? 0 : 1,
                  child: const Column(
                    children: [
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
