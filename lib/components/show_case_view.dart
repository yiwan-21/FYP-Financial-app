import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

class ShowCaseView extends StatelessWidget {
  final GlobalKey globalKey;
  final String title;
  final String description;
  final Widget child;

  const ShowCaseView({
    Key? key,
    required this.globalKey,
    required this.title,
    required this.description,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Showcase(
        key: globalKey,
        title: title,
        description: description,
        child: child);
  }
}
