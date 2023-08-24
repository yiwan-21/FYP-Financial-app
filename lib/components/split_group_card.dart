import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/route_name.dart';
import '../providers/split_money_provider.dart';
import '../services/split_money_service.dart';

class SplitGroupCard extends StatefulWidget {
  final String groupID;
  final String groupName;

  const SplitGroupCard(this.groupID, {required this.groupName, super.key});

  @override
  State<SplitGroupCard> createState() => _SplitGroupCardState();
}

class _SplitGroupCardState extends State<SplitGroupCard> {
  void _initGroup() {
    Provider.of<SplitMoneyProvider>(context, listen: false).setNewSplitGroup(widget.groupID);
    Navigator.pushNamed(context, RouteName.splitMoneyGroup).then((_) {
      SplitMoneyService.resetGroupID();
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
            const Icon(
              Icons.diversity_3,
              size: 55,
              color: Colors.black,
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
