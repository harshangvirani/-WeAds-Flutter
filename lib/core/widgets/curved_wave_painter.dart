import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CurvedWavePainter extends CustomPainter {
  final Color color;
  final double percentPlayed;
  final bool isBackground;
  final bool isStraight;

  CurvedWavePainter({
    required this.color,
    required this.percentPlayed,
    this.isBackground = false,
    this.isStraight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double centerY = size.height / 2;
    final double waveWidth = 80.0;
    const double waveHeight = 6.0;
    final double totalWidth = size.width;
    final double playedWidth = totalWidth * percentPlayed;

    path.moveTo(0, centerY);

    for (double i = 0; i <= playedWidth; i += 1) {
      double relativeX = i * (2 * math.pi / waveWidth);
      double y = centerY - (math.sin(isStraight ? 0 : relativeX) * waveHeight);
      path.lineTo(i, y);
    }

    if (isBackground) {
      path.lineTo(playedWidth, centerY);

      path.lineTo(totalWidth, centerY);
    }

    canvas.drawPath(path, paint);

    if (!isBackground && percentPlayed > 0 && percentPlayed < 1.0) {
      double relativeX = playedWidth * (2 * math.pi / waveWidth);
      double dotY = centerY - (math.sin(relativeX) * waveHeight);
      canvas.drawCircle(Offset(playedWidth, dotY), 4.r, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(CurvedWavePainter oldDelegate) =>
      oldDelegate.percentPlayed != percentPlayed;
}
