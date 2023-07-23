import 'package:flutter/material.dart';

class SplitGroupCard extends StatefulWidget {
  final String groupID;
  final String groupName;

  const SplitGroupCard(this.groupID, {required this.groupName, super.key});

  @override
  State<SplitGroupCard> createState() => _SplitGroupCardState();
}

class _SplitGroupCardState extends State<SplitGroupCard> {
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/group', arguments: {'id': widget.groupID});
        },
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
