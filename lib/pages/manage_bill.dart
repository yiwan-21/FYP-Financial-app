import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../forms/bill_form.dart';
import '../constants/constant.dart';
import '../constants/style_constant.dart';
import '../components/alert_confirm_action.dart';
import '../services/bill_service.dart';

class ManageBill extends StatefulWidget {
  final bool isEditing;
  final String? id;
  final String? title;
  final double? amount;
  final DateTime? date;
  final bool? fixed;

  const ManageBill(this.isEditing,
      {this.id, this.title, this.amount, this.date, this.fixed, super.key});

  @override
  State<ManageBill> createState() => _ManageBillState();
}

class _ManageBillState extends State<ManageBill> {
  void _deleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertConfirmAction(
          title: 'Delete Bill',
          content: 'Are you sure you want to delete this bill?',
          cancelText: 'Cancel',
          confirmText: 'Delete',
          confirmAction: _deleteBill,
        );
      },
    );
  }

  Future<void> _deleteBill() async {
    await BillService.deleteBill(widget.id!).then((_) {
      // close dialog
      Navigator.pop(context);
      // back to bill page
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (Constant.isMobile(context) && !kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: widget.isEditing
              ? const Text('Edit Bill')
              : const Text('Add Bill'),
          actions: [
            if (widget.isEditing)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _deleteDialog,
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(12, 24, 12, 0),
          child: BillForm(
            isEditing: widget.isEditing,
            id: widget.id,
            title: widget.title,
            amount: widget.amount,
            date: widget.date,
            fixed: widget.fixed,
          ),
        ),
      );
    } else {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget.isEditing ? const Text('Edit Bill') : const Text('Add Bill'),
            if (widget.isEditing)
              IconButton(
                iconSize: 30,
                splashRadius: 30,
                color: lightRed,
                icon: const Icon(Icons.delete),
                onPressed: _deleteDialog,
              ),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: BillForm(
            isEditing: widget.isEditing,
            id: widget.id,
            title: widget.title,
            amount: widget.amount,
            date: widget.date,
            fixed: widget.fixed,
          ),
        ),
      );
    }
  }
}
