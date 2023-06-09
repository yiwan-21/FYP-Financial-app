import 'dart:io';

import 'package:financial_app/firebaseInstance.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'analytics.dart';
import '../components/transaction.dart';
import '../components/goal.dart';
import '../providers/userProvider.dart';

class Home extends StatefulWidget {
  final File? profileImage;
  const Home({this.profileImage, super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<List<TrackerTransaction>> _getTransactions() async {
    List<TrackerTransaction> _transactions = [];
    await FirebaseInstance.firestore.collection('transactions')
      .orderBy('date', descending: true)
      .limit(3)
      .get()
      .then((event) {
        for (var transaction in event.docs) {
          _transactions.add(TrackerTransaction(
            transaction.id,
            transaction['userID'],
            transaction['title'],
            transaction['amount'],
            transaction['date'].toDate(),
            transaction['isExpense'],
            transaction['category'],
            notes: transaction['notes'],
          ));
        }
      });
    return _transactions;
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
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage: widget.profileImage == null
                      ? null
                      : FileImage(widget.profileImage!),
                  child: widget.profileImage == null
                      ? const Icon(
                          Icons.account_circle,
                          color: Colors.white,
                          size: 40.0,
                        )
                      : null,
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
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
                            child: Text(
                              'Recent Goals',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // TextButton(
                          //   onPressed: () {},
                          //   child: const Text(
                          //     'View All',
                          //     style: TextStyle(
                          //       fontSize: 16.0,
                          //       fontWeight: FontWeight.bold,
                          //       color: Colors.pink,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      Goal('G1', 'Buy Food', 49.99, 30.00, DateTime.now()),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(
                                left: 10.0, top: 40.0, bottom: 10.0),
                            child: Text(
                              'Recent Transactions',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // TextButton(
                          //   onPressed: () {},
                          //   child: const Text(
                          //     'View All',
                          //     style: TextStyle(
                          //       fontSize: 16.0,
                          //       fontWeight: FontWeight.bold,
                          //       color: Colors.pink,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      FutureBuilder(
                        future: _getTransactions(),
                        builder:(context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
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
                            return Container();
                          }
                          
                        },
                      ),
                      // _transactions.isEmpty
                      //   ? const Text('No transactions found')
                      //   : 
                      // TrackerTransaction('T1', 'New Short', 49.99, DateTime.now(),
                      //     true, 'Other Expenses',
                      //     notes: "Notes"),
                      // TrackerTransaction('T2', 'Groceries', 10.00, DateTime.now(),
                      //     false, 'Savings'),
                      // TrackerTransaction('T3', 'New Shoes', 69.98, DateTime.now(),
                      //     true, 'Other Expenses',
                      //     notes: "Notes"),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Flexible(
                  flex: MediaQuery.of(context).size.width < 768 ? 0 : 1,
                  child: Column(
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
