import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/style_constant.dart';
import '../forms/debt_form.dart';
import '../constants/constant.dart';
import '../components/alert_confirm_action.dart';
import '../services/debt_service.dart';

class ManageDebt extends StatefulWidget {
  final bool isEditing;
  final String? id;
  final String? title;
  final double? amount;
  final double? interest;
  final int? year;
  final int? month;

  const ManageDebt(this.isEditing,
      {this.id,
      this.title,
      this.amount,
      this.interest,
      this.year,
      this.month,
      super.key});

  @override
  State<ManageDebt> createState() => _ManageDebtState();
}

class _ManageDebtState extends State<ManageDebt> {
  void _deleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertConfirmAction(
          title: 'Delete Debt',
          content: 'Are you sure you want to delete this Debt?',
          cancelText: 'Cancel',
          confirmText: 'Delete',
          confirmAction: _deleteDebt,
        );
      },
    );
  }

  Future<void> _deleteDebt() async {
    await DebtService.deleteDebt(widget.id!).then((_) {
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
              ? const Text('Edit Debt')
              : const Text('Add Debt'),
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
          child: DebtForm(
            isEditing: widget.isEditing,
            id: widget.id,
            title: widget.title,
            amount: widget.amount,
            interest: widget.interest,
            year: widget.year,
            month: widget.month,
          ),
        ),
      );
    } else {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            widget.isEditing ? const Text('Edit Debt') : const Text('Add Debt'),
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
          width: 500,
          child: DebtForm(
            isEditing: widget.isEditing,
            id: widget.id,
            title: widget.title,
            amount: widget.amount,
            interest: widget.interest,
            year: widget.year,
            month: widget.month,
          ),
        ),
      );
    }
  }
}
