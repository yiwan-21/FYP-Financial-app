import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';

import '../providers/show_case_provider.dart';

class ShowcaseFrame extends StatelessWidget {
  final GlobalKey showcaseKey;
  final String title;
  final String description;
  final Widget child;
  final double width;
  final double height;
  final bool showSkipTour;
  final TooltipPosition? tooltipPosition;

  const ShowcaseFrame({
    required this.showcaseKey,
    required this.title,
    required this.description,
    required this.child,
    required this.width,
    required this.height,
    this.showSkipTour = true,
    this.tooltipPosition,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Showcase.withWidget(
      key: showcaseKey,
      width: width,
      height: height,
      tooltipPosition: tooltipPosition,
      container: Container(
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
             Text(
              title,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            if (showSkipTour)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Provider.of<ShowcaseProvider>(context, listen: false).endAllTour(context);
                    ShowCaseWidget.of(context).dismiss();
                  },
                  child: const Text("Skip Tour"),
                ),
              ),
          ],
        ),
      ),
      child: child,
    );
  }
}

