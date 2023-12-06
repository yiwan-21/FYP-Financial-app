import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../pages/home.dart';
import '../pages/tracker.dart';
import '../pages/analytics.dart';
import '../pages/budgeting.dart';
import '../pages/split_money.dart';
import '../pages/notification.dart';
import '../pages/savings_goal.dart';
import '../pages/bill.dart';
import '../pages/debt.dart';
import '../pages/profile.dart';
import '../constants/constant.dart';
import '../constants/style_constant.dart';
import '../components/showcase_frame.dart';
import '../providers/show_case_provider.dart';
import '../providers/user_provider.dart';
import '../providers/navigation_provider.dart';
import '../services/budget_service.dart';
import '../services/transaction_service.dart';
import '../services/debt_service.dart';

class Navigation extends StatefulWidget {
  static final GlobalKey<ConvexAppBarState> appBarKey =
      GlobalKey<ConvexAppBarState>();
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  Map<String, Widget> _pages = {};
  List<dynamic> _options = [];

  void _onItemTapped(int index) {
    NavigationProvider navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    if (index == 4) {
      // Index of "More" tab
      navigationProvider.toggleMoreTab(); // Toggle the state of the More tab
    } else {
      navigationProvider.setIndex(index, index);
    }
  }

  @override
  void initState() {
    super.initState();
    _pages = {
      "Split Money": const SplitMoney(),
      "Savings Goal": const SavingsGoal(),
      "Home": const Home(),
      "Tracker": const Tracker(),
      "Debt": const Debt(),
      "Bill": const Bill(),
      "Budgeting Tool": const Budgeting(),
      "Financial Analytics": const Analytics(),
    };
    _options = [
      // using Showcase for it's scaleAnimationDuration attribute
      Showcase(
        key: Provider.of<ShowcaseProvider>(context, listen: false).navDebtKey,
        title: "Go to Debt page",
        titleTextStyle: const TextStyle(
          fontSize: 18,
        ),
        titlePadding: const EdgeInsets.only(top: 10, bottom: 8),
        description: "Click here to go to Debt page",
        descTextStyle: const TextStyle(
          fontSize: 14,
        ),
        descriptionPadding: const EdgeInsets.only(bottom: 10),
        scaleAnimationDuration: const Duration(milliseconds: 10),
        showArrow: false,
        child: const FloatButton(title: 'Debt', icon: Icons.money),
      ),
      // using Showcase for it's scaleAnimationDuration attribute
      Showcase(
        key: Provider.of<ShowcaseProvider>(context, listen: false).navBillKey,
        title: "Go to Bill page",
        titleTextStyle: const TextStyle(
          fontSize: 18,
        ),
        titlePadding: const EdgeInsets.only(top: 10, bottom: 8),
        description: "Click here to go to Bill page",
        descTextStyle: const TextStyle(
          fontSize: 14,
        ),
        descriptionPadding: const EdgeInsets.only(bottom: 10),
        scaleAnimationDuration: const Duration(milliseconds: 10),
        showArrow: false,
        child: const FloatButton(title: 'Bill', icon: Icons.water_drop),
      ),
      // using Showcase for it's scaleAnimationDuration attribute
      Showcase(
        key: Provider.of<ShowcaseProvider>(context, listen: false).navBudgetingKey,
        title: "Go to Budgeting page",
        titleTextStyle: const TextStyle(
          fontSize: 18,
        ),
        titlePadding: const EdgeInsets.only(top: 10, bottom: 8),
        description: "Click here to go to Budgeting page",
        descTextStyle: const TextStyle(
          fontSize: 14,
        ),
        descriptionPadding: const EdgeInsets.only(bottom: 10),
        scaleAnimationDuration: const Duration(milliseconds: 10),
        showArrow: false,
        child: const FloatButton(title: 'Budgeting', icon: Icons.account_balance_wallet),
      ),
      const FloatButton(title: 'Analytics', icon: Icons.align_vertical_bottom_outlined),
    ];
    
    // tracker cron job deletion on app launch 
    TransactionService.resetTransactions();
    // check budgeting reset on app launch
    BudgetService.resetBudget();
    // check debt reset on app launch
    DebtService.resetDebt();
  }

  Widget _showMoreMenu(NavigationProvider navigationProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: lightRed,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          _options.length,
          (index) {
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                int newIndex = index + 4;
                navigationProvider.setIndex(4, newIndex);
              },
              child: _options[index],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ShowcaseProvider showcaseProvider = Provider.of<ShowcaseProvider>(context, listen: false);
    return Consumer<NavigationProvider>(
      builder: (context, navigationProvider, _) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(_pages.keys.elementAt(navigationProvider.pageIndex)),
            actions: [
              const NotificationMenu(),
              if(!Constant.isMobile(context))
              const SizedBox(width: 18),
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
                          radius: Constant.isMobile(context)? 12.0 : 20.0,
                          backgroundColor: Colors.transparent,
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
              SizedBox(width: Constant.isMobile(context)? 12 : 20),
            ],
          ),
          endDrawer: const Profile(),
          body: Stack(
            children: [
              Center(
                child: _pages.values.elementAt(navigationProvider.pageIndex),
              ),
              if (showcaseProvider.isRunning && navigationProvider.isMoreTabActive)
                Positioned(
                  right: Constant.isMobile(context)? MediaQuery.of(context).size.width*0.02 : MediaQuery.of(context).size.width*0.05,
                  bottom: 28,
                  child: _showMoreMenu(navigationProvider)
                ),
            ],
          ),
          bottomNavigationBar: ConvexAppBar(
            key: Navigation.appBarKey,
            backgroundColor: lightRed,
            color: Colors.white,
            items: const [
              TabItem(icon: Icons.diversity_3, title: 'Group'),
              TabItem(icon: Icons.star, title: 'Goal'),
              TabItem(icon: Icons.home, title: 'Home'),
              TabItem(icon: Icons.attach_money, title: 'Tracker'),
              TabItem(icon: Icons.more_horiz, title: 'More'),
            ],
            chipBuilder: _ChipBuilder(),
            initialActiveIndex: navigationProvider.navIndex,
            onTap: _onItemTapped,
            curve: Curves.easeInOut,
          ),
          floatingActionButton: !showcaseProvider.isRunning && navigationProvider.isMoreTabActive
              ? Padding(
                  padding: EdgeInsets.only(bottom: 10.0, right: Constant.isMobile(context)? 0 : MediaQuery.of(context).size.width*0.05 ),
                  child: _showMoreMenu(navigationProvider)
              )
              : null,
        );
      },
    );
  }
}

class FloatButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? color;

  const FloatButton(
      {super.key, required this.title, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color ?? Colors.white,
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipBuilder extends ChipBuilder {
  @override
  Widget build(BuildContext context, Widget child, int index, bool active) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        child,
        // Showcase Group navigation icon
        if (index == 0)
          ShowcaseFrame(
            showcaseKey: Provider.of<ShowcaseProvider>(context, listen: false).navGroupKey,
            title: "Split Money",
            description: "Click here to go to Split Money page",
            width: 300,
            height: 100,
            showSkipTour: false,
            child: Container(),
          ),
          
        // Showcase Goal navigation icon
        if (index == 1)
          ShowcaseFrame(
            showcaseKey: Provider.of<ShowcaseProvider>(context, listen: false).navGoalKey,
            title: "Goal",
            description: "Click here to go to Goal page",
            width: 250,
            height: 100,
            showSkipTour: false,
            child: Container(),
          ),
        
        // Showcase Home navigation icon
        if (index == 2)
          ShowcaseFrame(
            showcaseKey: Provider.of<ShowcaseProvider>(context, listen: false).endTourKey, 
            title: "Click to end the tour",
            description: "You can start using this app!", 
            width: 250,
            height: 100,
            showSkipTour: false,
            child: Container(),
        ),

        // Showcase Tracker navigation icon
        if (index == 3)
          ShowcaseFrame(
            showcaseKey: Provider.of<ShowcaseProvider>(context, listen: false).navTrackerKey,
            title: "Tracker",
            description: "Click here to navigate to Tracker page",
            width: 300,
            height: 100,
            showSkipTour: false,
            child: Container(),
          ),

        // Showcase More navigation icon
        if (index == 4)
          ShowcaseFrame(
            showcaseKey: Provider.of<ShowcaseProvider>(context, listen: false).navMoreKey,
            title: "More",
            description: "Click here to show more options",
            width: 250,
            height: 100,
            showSkipTour: false,
            child: Container(),
          ),
      ],
    );
  }
}
