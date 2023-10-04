import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../components/split_group_request.dart';
import '../constants/constant.dart';
import '../constants/style_constant.dart';
import '../components/manage_group.dart';
import '../components/split_group_card.dart';
import '../services/split_money_service.dart';

class SplitMoney extends StatefulWidget {
  const SplitMoney({super.key});

  @override
  State<SplitMoney> createState() => _SplitMoneyState();
}

class _SplitMoneyState extends State<SplitMoney> {
  final Stream<QuerySnapshot> _stream = SplitMoneyService.getGroupStream();

  bool get _topDownAlign {
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
            mainAxisAlignment:
                _topDownAlign ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Column(
                  children: [
                    if (!_topDownAlign)
                      Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.all(10),
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
                    Flexible(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _stream,
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
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text('No group yet'),
                            );
                          }

                          List<SplitGroupCard> groupCards = snapshot.data!.docs
                              .map((doc) => SplitGroupCard(doc.id,
                                  groupName: doc['name']))
                              .toList();
                          return ListView(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            children: List.generate(
                              groupCards.length,
                              (index) {
                                return groupCards[index];
                              },
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
          ? FloatingActionButton(
              backgroundColor: ColorConstant.lightBlue,
              onPressed: addGroup,
              child: const Icon(
                Icons.group_add_outlined,
                size: 27,
                color: Colors.black,
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
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return SplitGroupRequest(
                      'Testing 123 123 123 123 Group $index', 'inviter 1');
                },
              ),
            ),
        ],
      ),
    );
  }
}
