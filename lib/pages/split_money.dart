import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 768,
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream: _stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Text('Something went wrong: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No group yet'),
                );
              }

              List<SplitGroupCard> groupCards = snapshot.data!.docs
                  .map((doc) => SplitGroupCard(doc.id, groupName: doc['name']))
                  .toList();
              return ListView(
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorConstant.lightBlue,
        onPressed: addGroup,
        child: const Icon(
          Icons.group_add_outlined,
          size: 27,
          color: Colors.black,
        ),
      ),
    );
  }
}
