import 'package:flutter/material.dart';

import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' as vmath;

class CustomCircularProgress extends CustomPainter {
  final double value;
  final double strokeWidth;
  final double radius;
  final double startAngle;
  final double sweepAngle;
  final double heightMultiply;
  final double widthMultiply;
  final List<Color> colors;

  CustomCircularProgress({
    required this.value, 
    required this.strokeWidth,
    required this.radius, 
    required this.startAngle, 
    required this.sweepAngle, 
    required this.heightMultiply,
    required this.widthMultiply,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = this.strokeWidth;
    double radius = this.radius;
    final double startAngle = vmath.radians(this.startAngle);
    final double sweepAngle = vmath.radians(this.sweepAngle);
    final Offset center = Offset(size.width / widthMultiply, size.height * heightMultiply);
    final List<Color> colors = this.colors;
    
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
      // radius * 5 to make sure the circle won't be clipped
      Rect.fromCenter(center: center, width: radius * 5, height: radius * 5),
      Paint(),
    );
    debugPrint('startAngle: $startAngle, sweepAngle: $sweepAngle');

    Gradient gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: sweepAngle + startAngle,
      tileMode: TileMode.mirror,
      colors: colors,
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