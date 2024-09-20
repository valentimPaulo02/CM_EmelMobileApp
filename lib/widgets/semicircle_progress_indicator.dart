import 'dart:math' as math;

import 'package:flutter/material.dart';

class SemicircleProgressIndicator extends StatelessWidget {
  final double? progress; // Progress value between 0.0 and 1.0
  final double size; // Size of the widget
  final Color primaryColor;
  final Color backgroundColor;
  final Color textColor;
  final double strokeWidth;

  const SemicircleProgressIndicator({
    super.key,
    required this.progress,
    this.size = 50.0,
    required this.primaryColor,
    required this.backgroundColor,
    required this.textColor,
    this.strokeWidth = 4,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size / 2), // Half-circle size
      painter: _SemicircleProgressPainter(
        progress: progress,
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
        textColor: textColor,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

class _SemicircleProgressPainter extends CustomPainter {
  final double? progress;
  final Color primaryColor;
  final Color backgroundColor;
  final Color textColor;
  final double strokeWidth;

  _SemicircleProgressPainter({
    required this.progress,
    required this.primaryColor,
    required this.backgroundColor,
    required this.textColor,
    this.strokeWidth = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    Paint progressPaint = Paint()
      ..color = primaryColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Draw background
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height * 2),
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    // Draw progress
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height * 2),
      math.pi,
      progress != null ? math.pi * progress! : 0,
      false,
      progressPaint,
    );

    // Draw text
    final percentageText =
        progress != null ? '${(progress! * 100).toInt()}%' : ' - %';
    final textStyle = TextStyle(
      color: textColor,
      fontSize: size.width / 3.85,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: percentageText,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) + (strokeWidth / 2),
    );
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
