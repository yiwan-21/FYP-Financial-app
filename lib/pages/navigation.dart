import 'dart:io';

import 'package:financial_app/providers/navigationProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  File? _profileImage;

  void _onItemTapped(int index) {
    Provider.of<NavigationProvider>(context, listen: false).setCurrentIndex(index);
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
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, _) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(_pages.keys.elementAt(navigationProvider.getCurrentIndex)),
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
          body: Center(child: _pages.values.elementAt(navigationProvider.getCurrentIndex)),
          bottomNavigationBar: BottomNavigationBar(
            showUnselectedLabels: true,
            selectedItemColor: Colors.pink,
            unselectedItemColor: Colors.black,
            currentIndex: navigationProvider.getCurrentIndex,
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
    );
  }
}