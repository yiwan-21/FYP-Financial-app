import 'package:flutter/material.dart';

class AlertConfirmAction extends StatefulWidget {
  final String title;
  final String content;
  final String? cancelText;
  final String confirmText;
  final void Function() confirmAction;
  final void Function()? cancelAction;

  const AlertConfirmAction({required this.title, required this.content, this.cancelText, required this.confirmText, required this.confirmAction, this.cancelAction, super.key});

  @override
  State<AlertConfirmAction> createState() => _AlertConfirmActionState();
}

class _AlertConfirmActionState extends State<AlertConfirmAction> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Text(widget.content),
      actions: [
        widget.cancelText == null ? Container() :
        TextButton(
          onPressed: () {
            if (widget.cancelAction != null) {
              widget.cancelAction!();
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.cancelText!),
        ),
        TextButton(
          onPressed: widget.confirmAction,
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}
