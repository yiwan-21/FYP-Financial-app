import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/constant.dart';
import '../forms/goal_form.dart';

class AddGoal extends StatefulWidget {
  const AddGoal({super.key});

  @override
  State<AddGoal> createState() => _AddGoalState();
}

class _AddGoalState extends State<AddGoal> {
  bool _pinned = false;

  @override
  Widget build(BuildContext context) {
    if (Constant.isMobile(context) && !kIsWeb) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Add Goal'),
            actions: [
              IconButton(
                icon: Icon(
                  _pinned ? Icons.push_pin : Icons.push_pin_outlined,
                  semanticLabel: _pinned ? 'Unpin' : 'Pin',
                ),
                onPressed: () {
                  setState(() {
                    _pinned = !_pinned;
                  });
                },
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(12, 24, 12, 0),
            child: GoalForm(pinned: _pinned),
          ));
    } else {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Add Goal'),
            IconButton(
              icon: Icon(
                _pinned ? Icons.push_pin : Icons.push_pin_outlined,
                semanticLabel: _pinned ? 'Unpin' : 'Pin',
              ),
              onPressed: () {
                setState(() {
                  _pinned = !_pinned;
                });
              },
            )
          ],
        ),
        content: SizedBox(
          width: 400,
          child: GoalForm(pinned: _pinned),
        ),
      );
    }
  }
}
