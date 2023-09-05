import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vmath;
import 'dart:math' as math;

import '../constants/route_name.dart';

class BudgetCard extends StatefulWidget {
  final String category;
  final double amount;
  final double usedAmount;

  const BudgetCard(this.category, this.amount, this.usedAmount, {super.key});

  @override
  State<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<BudgetCard> {
  double _progress = 0;
  @override
  void initState() {
    super.initState();
    //TODO: progress
    _progress = widget.usedAmount / widget.amount;
  }

  void _detail() {
    Navigator.pushNamed(context, RouteName.budgetDetail);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _detail,
      child: Container(
        color: Colors.white,
        padding:
            const EdgeInsets.only(top: 30, bottom: 25, right: 70, left: 30),
        margin: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'RM ${widget.amount}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            //circular progress here
            CustomPaint(
              painter: CustomCircularProgress(
                value: _progress,
              ),
              child: Text(
                '${(_progress * 100).toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomCircularProgress extends CustomPainter {
  final double value;

  CustomCircularProgress({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 5;
    double radius = 60;
    final startAngle = vmath.radians(180);
    final sweepAngle = vmath.radians(180);
    final center = Offset(size.width / 2, size.height * 1.6);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.black12
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth,
    );
    canvas.saveLayer(
      Rect.fromCenter(center: center, width: 200, height: 200),
      Paint(),
    );

    Gradient gradient = SweepGradient(
      startAngle: 1.25 * math.pi / 2,
      endAngle: 5.5 * math.pi / 2,
      tileMode: TileMode.repeated,
      colors: value == 1
          ? <Color>[Colors.red, Colors.pink]
          : <Color>[Colors.yellow, Colors.orange, Colors.red, Colors.pink],
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * value,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..shader = gradient
            .createShader(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
        ..strokeWidth = strokeWidth,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
