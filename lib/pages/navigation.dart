import 'dart:io';

import 'package:flutter/material.dart';
import 'home.dart';
import 'tracker.dart';
import 'analytics.dart';
import 'budgeting.dart';
import 'savingsGoal.dart';
import 'profile.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
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

  Map<String, Widget> _pages = {};
   
  @override
  void initState() {
    super.initState();
    _pages = {
    "Home": const Home(),
    "Tracker": const Tracker(),
    "Financial Analytics": const Analytics(),
    "Savings Goal": const SavingsGoal(),
    "Budgeting Tool": const Budgeting(),
  };
  }


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