import 'dart:math';

import 'package:flutter/material.dart';

/// Theme purple gradient used for transition and app background.
const _transitionGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF2A0B58),
    Color(0xFF1A1238),
    Color(0xFF120828), // Keep transition clearly purple, not near-black
  ],
);

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

/// Star field with subtle drift and twinkle driven by [progress] (0..1, repeating).
class AnimatedStarFieldPainter extends CustomPainter {
  const AnimatedStarFieldPainter({required this.progress});

  final double progress;

  static const _points = [
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

  @override
  void paint(Canvas canvas, Size size) {
    const dotBase = 0xFFB56BFF;
    const glowBase = 0xFFB56BFF;

    for (var i = 0; i < _points.length; i++) {
      final p = _points[i];
      if (p.dx > size.width || p.dy > size.height) continue;

      final t = progress * 2 * pi;
      final drift = Offset(2.5 * sin(t + i * 0.7), 2.5 * cos(t + i * 0.5));
      final pt = p + drift;
      final twinkle = 0.25 + 0.2 * sin(t * 1.3 + i * 0.9);

      final glowPaint = Paint()
        ..color = Color(glowBase).withOpacity(0.28 + twinkle * 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      final dotPaint = Paint()
        ..color = Color(dotBase).withOpacity(0.38 + twinkle * 0.32);

      canvas.drawCircle(pt, 3, glowPaint);
      canvas.drawCircle(pt, 1.6, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedStarFieldPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Full-screen purple gradient with animated moving stars for route transitions.
class TransitionBackground extends StatefulWidget {
  const TransitionBackground({super.key});

  @override
  State<TransitionBackground> createState() => _TransitionBackgroundState();
}

class _TransitionBackgroundState extends State<TransitionBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return SizedBox(
          width: size.width,
          height: size.height,
          child: Container(
            decoration: const BoxDecoration(gradient: _transitionGradient),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  size: size,
                  painter: AnimatedStarFieldPainter(progress: _controller.value),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
