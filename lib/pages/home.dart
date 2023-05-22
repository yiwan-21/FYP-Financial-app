import 'dart:io';

import 'package:flutter/material.dart';
import 'tracker.dart';
import 'analytics.dart';
import 'budgeting.dart';
import 'savingsGoal.dart';
import 'profile.dart';
import '../components/transaction.dart';
import '../components/goal.dart';
import 'analytics.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  File? _profileImage;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onImageChange(File? profileImage) {
    setState(() {
      _profileImage = profileImage;
    });
  }

  final Map<String, Widget> _pages = {
    "Home": const HomeContent(),
    "Tracker": const Tracker(),
    "Financial Analytics": const Analytics(),
    "Savings Goal": const SavingsGoal(),
    "Budgeting Tool": const Budgeting(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(_pages.keys.elementAt(_selectedIndex)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          Builder(builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Scaffold.of(context).openEndDrawer();
              },
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.pink,
                backgroundImage:
                    _profileImage == null ? null : FileImage(_profileImage!),
                child: _profileImage == null
                    ? const Icon(
                        Icons.account_circle,
                        color: Colors.white,
                      )
                    : null,
              ),
            );
          }),
          const SizedBox(width: 12),
        ],
      ),
      endDrawer: Profile(
        profileImage: _profileImage,
        onImageChange: _onImageChange,
      ),
      body: Center(child: _pages.values.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Tracker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.align_vertical_bottom_outlined),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Goal',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.account_balance_wallet_outlined),
          //   label: 'Budgeting',
          // ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final File? profileImage;

  const HomeContent({this.profileImage, super.key});

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
                  backgroundImage:
                      profileImage == null ? null : FileImage(profileImage!),
                  child: profileImage == null
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
                    const Text(
                      "John Doe",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
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
                            padding: EdgeInsets.only(left: 10.0, top: 40.0, bottom: 10.0),
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
                      Transaction('T1', 'New Short', 49.99, DateTime.now(), true,
                          'Other Expenses',
                          notes: "Notes"),
                      Transaction('T2', 'Groceries', 10.00, DateTime.now(), false,
                          'Savings'),
                      Transaction('T3', 'New Shoes', 69.98, DateTime.now(), true,
                          'Other Expenses',
                          notes: "Notes"),
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
