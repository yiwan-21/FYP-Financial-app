import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/home.dart';
import '../pages/tracker.dart';
import '../pages/analytics.dart';
import '../pages/budgeting.dart';
import '../pages/split_money.dart';
import '../pages/savings_goal.dart';
import '../pages/profile.dart';
import '../providers/user_provider.dart';
import '../providers/navigation_provider.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  void _onItemTapped(int index) {
    Provider.of<NavigationProvider>(context, listen: false)
        .setCurrentIndex(index);
  }

  Map<String, Widget> _pages = {};

  @override
  void initState() {
    super.initState();
    _pages = {
      "Home": const Home(),
      "Tracker": const Tracker(),
      "Financial Analytics": const Analytics(),
      "Split Money": const SplitMoney(),
      "Savings Goal": const SavingsGoal(),
      // "Budgeting Tool": const Budgeting(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
        builder: (context, navigationProvider, _) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title:
              Text(_pages.keys.elementAt(navigationProvider.getCurrentIndex)),
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
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    String? image = userProvider.profileImage;
                    if (image.isNotEmpty) {
                      return CircleAvatar(
                        radius: 12.0,
                        backgroundImage: NetworkImage(image),
                      );
                    } else {
                      return const CircleAvatar(
                        radius: 12.0,
                        child: Icon(
                          Icons.account_circle,
                          color: Colors.white,
                        ),
                      );
                    }
                  },
                ),
              );
            }),
            const SizedBox(width: 12),
          ],
        ),
        endDrawer: const Profile(),
        body: Center(
            child: _pages.values.elementAt(navigationProvider.getCurrentIndex)),
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
              icon: Icon(Icons.diversity_3),
              label: 'Split Money',
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
    });
  }
}
