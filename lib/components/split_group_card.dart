import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/route_name.dart';
import '../providers/split_money_provider.dart';
import '../services/split_money_service.dart';

class SplitGroupCard extends StatefulWidget {
  final String groupID;
  final String groupName;

  const SplitGroupCard(this.groupID, {required this.groupName, super.key});

  SplitGroupCard.fromSnapshot(DocumentSnapshot doc, {super.key}) 
    : groupID = doc.id,
      groupName = doc['name'];

  @override
  State<SplitGroupCard> createState() => _SplitGroupCardState();
}

class _SplitGroupCardState extends State<SplitGroupCard> {
  void _initGroup() {
    Provider.of<SplitMoneyProvider>(context, listen: false).setNewSplitGroup(widget.groupID);
    Navigator.pushNamed(context, RouteName.splitMoneyGroup, arguments: {'id': widget.groupID}).then((_) {
      SplitMoneyService.resetGroupID();
      if (mounted && context.mounted) {
        setState(() {});
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: _initGroup,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FutureBuilder(
              future: SplitMoneyService.getGroupImage(widget.groupID), 
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.transparent,
                    backgroundImage: NetworkImage(snapshot.data as String),
                  );
                } else {
                  return const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.transparent,
                    backgroundImage: AssetImage('assets/images/group.png'),
                  );
                }
              },
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                Text(
                  widget.groupName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
