import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../constants/tour_example.dart';
import '../pages/add_goal.dart';
import '../constants/constant.dart';
import '../constants/route_name.dart';
import '../constants/style_constant.dart';
import '../components/goal.dart';
import '../components/showcase_frame.dart';
import '../providers/show_case_provider.dart';
import '../providers/total_goal_provider.dart';

class SavingsGoal extends StatefulWidget {
  const SavingsGoal({super.key});
  @override
  State<SavingsGoal> createState() => _SavingsGoalState();
}

class _SavingsGoalState extends State<SavingsGoal> {
  bool get _isMobile => Constant.isMobile(context);
  final List<GlobalKey> _webKeys = [
    GlobalKey(),
    GlobalKey(),
  ];
  final List<GlobalKey> _mobileKeys = [
    GlobalKey(),
    GlobalKey(),
  ];
  bool _showcasingWebView = false;
  bool _runningShowcase = false;

  @override
  void initState() {
    super.initState();
    ShowcaseProvider showcaseProvider = Provider.of<ShowcaseProvider>(context, listen: false);
    if (showcaseProvider.isFirstTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mobileKeys.add(showcaseProvider.navGroupKey);
        _webKeys.add(showcaseProvider.navGroupKey);
        if (_isMobile) {
          ShowCaseWidget.of(context).startShowCase(_mobileKeys);
          _showcasingWebView = false;
        } else {
          ShowCaseWidget.of(context).startShowCase(_webKeys);
          _showcasingWebView = true;
        }
        _runningShowcase = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ShowcaseProvider showcaseProvider = Provider.of<ShowcaseProvider>(context, listen: false);
    if (kIsWeb && showcaseProvider.isRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (_showcasingWebView && _isMobile) {
          // If the showcase is running on web and the user switches to mobile view
          await Future.delayed(const Duration(milliseconds: 200)).then((_) {
            ShowCaseWidget.of(context).startShowCase(_mobileKeys);
            _showcasingWebView = false;
          });
        } else if (!_showcasingWebView && !_isMobile) {
          // If the showcase is running on mobile and the user switches to web view
          ShowCaseWidget.of(context).startShowCase(_webKeys);
          _showcasingWebView = true;
        }
      });
    }
  }

  _navigateToAddGoal() {
    if (_isMobile && !kIsWeb) {
      Navigator.pushNamed(context, RouteName.addGoal);
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AddGoal();
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 768,
          ),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              _isMobile
                  ? const SizedBox(height: 20)
                  : Container(
                      alignment: Alignment.bottomRight,
                      margin: const EdgeInsets.only(top: 12, bottom: 12, right: 8),
                      child: ShowcaseFrame(
                        showcaseKey: _webKeys[0],
                        title: "Savings Goal",
                        description: "Add your goal here",
                        width: 250,
                        height: 100,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(150, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                          onPressed: _navigateToAddGoal,
                          child: const Text('Add Savings Goal'),
                        ),
                      ),
                    ),
              StreamBuilder<QuerySnapshot>(
                stream: Provider.of<TotalGoalProvider>(context, listen: false)
                    .getGoalsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!_runningShowcase) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No goal yet"));
                    }
                  }

                  List<Goal> goals = snapshot.data!.docs
                      .map((doc) => Goal.fromDocument(doc))
                      .toList();

                  return ShowcaseFrame(
                    showcaseKey: _isMobile? _mobileKeys[1] : _webKeys[1],
                    title: "Data Created",
                    description: "Tap here to view goal details and add the progress",
                    width: 300,
                    height: 100,
                    child: Wrap(
                      children: List.generate(
                        _runningShowcase ? 1 : goals.length, 
                        (index) {
                          if (_runningShowcase) {
                            return TourExample.goal;
                          }
                          return goals[index];
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isMobile
          ? ShowcaseFrame(
              showcaseKey: _mobileKeys[0],
              title: "Savings Goal",
              description: "Add your goal here",
              width: 200,
              height: 100,
              child: FloatingActionButton(
                backgroundColor: ColorConstant.lightBlue,
                onPressed: _navigateToAddGoal,
                child: const Icon(
                  Icons.add,
                  size: 27,
                  color: Colors.black,
                ),
              ),
            )
          : null,
    );
  }
}
