import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../components/split_group_request.dart';
import '../constants/constant.dart';
import '../constants/style_constant.dart';
import '../constants/tour_example.dart';
import '../components/manage_group.dart';
import '../components/split_group_card.dart';
import '../components/showcase_frame.dart';
import '../firebase_instance.dart';
import '../providers/show_case_provider.dart';
import '../providers/split_money_provider.dart';
import '../services/split_money_service.dart';
import '../services/user_service.dart';

class SplitMoney extends StatefulWidget {
  const SplitMoney({super.key});

  @override
  State<SplitMoney> createState() => _SplitMoneyState();
}

class _SplitMoneyState extends State<SplitMoney> {
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
        _mobileKeys.add(showcaseProvider.navMoreKey);
        _mobileKeys.add(showcaseProvider.navBudgetingKey);
        _webKeys.add(showcaseProvider.navMoreKey);
        _webKeys.add(showcaseProvider.navBudgetingKey);
        if (_topDownAlign) {
          ShowCaseWidget.of(context).startShowCase(_mobileKeys);
          _showcasingWebView = false;
        } else {
          ShowCaseWidget.of(context).startShowCase(_webKeys);
          _showcasingWebView = true;
        }
        setState(() {
          _runningShowcase = true;
        });
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ShowcaseProvider showcaseProvider = Provider.of<ShowcaseProvider>(context, listen: false);
    if (kIsWeb && showcaseProvider.isRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (_showcasingWebView && _topDownAlign) {
          // If the showcase is running on web and the user switches to mobile view
          await Future.delayed(const Duration(milliseconds: 200)).then((_) {
            ShowCaseWidget.of(context).startShowCase(_mobileKeys);
            _showcasingWebView = false;
          });
        } else if (!_showcasingWebView && !_topDownAlign) {
          // If the showcase is running on mobile and the user switches to web view
          ShowCaseWidget.of(context).startShowCase(_webKeys);
          _showcasingWebView = true;
        }
      });
    }
  }
  
  bool get _topDownAlign {
    // true: mobile, false: web
    return Constant.isMobile(context) || Constant.isTablet(context);
  }

  void addGroup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const ManageGroup(false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: _topDownAlign ? Alignment.bottomCenter : Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768 * (3 / 2)),
          child: Flex(
            direction: _topDownAlign ? Axis.vertical : Axis.horizontal,
            verticalDirection: VerticalDirection.up,
            mainAxisAlignment: _topDownAlign ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Column(
                  children: [
                    if (!_topDownAlign)
                      // webview
                      Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.all(10),
                        child: ShowcaseFrame(
                          showcaseKey: _webKeys[0],
                          title: "Split Money",
                          description: "Add your group for money splitting",
                          width: 300,
                          height: 100,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              fixedSize: const Size(100, 40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            onPressed: addGroup,
                            child: const Text('Add Group'),
                          ),
                        ),
                      ),
                    Flexible(
                      child: Consumer<SplitMoneyProvider>(
                        builder: (context, splitMoneyProvider, _) {
                          List<SplitGroupCard> groupCards = splitMoneyProvider.groups;
                          if (!_runningShowcase) {
                            if (groupCards.isEmpty) {
                              return const Center(
                                child: Text('No group yet'),
                              );
                            }
                          }
                          return ShowcaseFrame(
                            showcaseKey: _topDownAlign? _mobileKeys[1] : _webKeys[1],
                            title: "Data Created",
                            description: "Tap here to view group details and add group expense",
                            width: _topDownAlign? 300: 400,
                            height: 100,
                            child: ListView(
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              children: List.generate(
                                _runningShowcase ? 1 : groupCards.length,
                                (index) {
                                  if (_runningShowcase) {
                                    return TourExample.group;
                                  }
                                  return groupCards[index];
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 2),
              Flexible(
                flex: _topDownAlign ? 0 : 1,
                child: const GroupRequest(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _topDownAlign
          // mobileview
          ? ShowcaseFrame(
              showcaseKey: _mobileKeys[0],
              title: "Split Money",
              description: "Add your group for money splitting",
              width: 300,
              height: 100,
              child: FloatingActionButton(
                backgroundColor: ColorConstant.lightBlue,
                onPressed: addGroup,
                child: const Icon(
                  Icons.group_add_outlined,
                  size: 27,
                  color: Colors.black,
                ),
              ),
            )
          : null,
    );
  }
}

class GroupRequest extends StatefulWidget {
  const GroupRequest({super.key});

  @override
  State<GroupRequest> createState() => _GroupRequestState();
}

class _GroupRequestState extends State<GroupRequest> {
  bool _expanded = true;
  final Stream<QuerySnapshot> _stream = SplitMoneyService.getGroupRequestStream();

  bool get _topDownAlign {
    return Constant.isMobile(context) || Constant.isTablet(context);
  }

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      height: _expanded
          ? (_topDownAlign ? 200 : MediaQuery.of(context).size.height)
          : 50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            visualDensity: VisualDensity.compact,
            onTap: _toggleExpanded,
            enabled: _topDownAlign,
            horizontalTitleGap: 0,
            title: Text(
              'Group Requests',
              style: TextStyle(
                color: Colors.black,
                fontWeight: _topDownAlign ? FontWeight.normal : FontWeight.bold,
                fontSize: _topDownAlign ? 16 : 18,
              ),
            ),
            leading: _topDownAlign
                ? _expanded
                    ? const Icon(Icons.keyboard_arrow_down)
                    : const Icon(Icons.keyboard_arrow_right)
                : const Icon(Icons.mail),
          ),
          if (_expanded)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: _stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      debugPrint('Something went wrong in all group requests: ${snapshot.error}');
                      return const Text('');
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text('No group request yet'),
                      );
                    }

                    final String uid = FirebaseInstance.auth.currentUser!.uid;
                    List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
                    docs.retainWhere((doc) => List<Map>.from(doc['requests']).any((obj) {
                              return obj['to'] == uid;
                            }));

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text('No group request yet'),
                      );
                    }

                    List<Future<SplitGroupRequest>> groupRequests = docs
                      .map((doc) async {
                      List<Map> req = List<Map>.from(doc['requests']);
                      String from = req.firstWhere((obj) => obj['to'] == uid)['from'];
                      return await UserService.getNameByID(from).then((name) {
                        return SplitGroupRequest(doc.id, doc['name'], name);
                      });
                    }).toList();
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: groupRequests.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder(
                          future: groupRequests[index],
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting ) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              debugPrint('Something went wrong in filter group Requests: ${snapshot.error}');
                              return const Text('');
                            }
                            return snapshot.data!;
                          },
                        );
                      },
                    );
                  },
              ),
            ),
        ],
      ),
    );
  }
}
