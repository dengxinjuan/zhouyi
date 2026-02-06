import 'package:flutter/material.dart';

class StarFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = const Color(0xFFB56BFF).withOpacity(0.35);
    final glowPaint = Paint()
      ..color = const Color(0xFFB56BFF).withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    const points = [
      Offset(40, 120),
      Offset(120, 180),
      Offset(260, 140),
      Offset(320, 220),
      Offset(80, 320),
      Offset(240, 360),
      Offset(300, 420),
      Offset(60, 520),
      Offset(180, 560),
      Offset(280, 600),
      Offset(100, 700),
      Offset(240, 740),
    ];

    for (final point in points) {
      if (point.dx > size.width || point.dy > size.height) {
        continue;
      }
      canvas.drawCircle(point, 3, glowPaint);
      canvas.drawCircle(point, 1.6, dotPaint);
    }
    // TODO: add more subtle particles or a noise texture for polish.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
