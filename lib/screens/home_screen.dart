import 'dart:math';

import 'package:flutter/material.dart';

import '../widgets/star_field.dart';
import 'shake_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotation;

  @override
  void initState() {
    super.initState();
    _rotation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final base = min(size.width, size.height);
    final ringSize = base * 0.62;
    final taijiSize = ringSize * 0.58;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2A0B58),
              Color(0xFF1A1238),
              Color(0xFF090811),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              CustomPaint(
                size: size,
                painter: StarFieldPainter(),
              ),
              Positioned(
                top: 24,
                right: 20,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF6A4B1F)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.volume_off_rounded,
                    color: Color(0xFFB98A2F),
                  ),
                ),
              ),
              Positioned(
                top: size.height * 0.08,
                left: 0,
                right: 0,
                child: Column(
                  children: const [
                    Text(
                      '易占未来',
                      style: TextStyle(
                        color: Color(0xFFD8C09A),
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'I Ching & Fortune',
                      style: TextStyle(
                        color: Color(0xFF9B8C7A),
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: size.height * 0.28,
                left: 0,
                right: 0,
                child: Center(
                  child: RotationTransition(
                    turns: _rotation,
                    child: CustomPaint(
                      size: Size.square(ringSize),
                      painter: _BaguaRingPainter(),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: size.height * 0.34,
                left: 0,
                right: 0,
                child: Center(
                  child: CustomPaint(
                    size: Size.square(taijiSize),
                    painter: _TaijiPainter(),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 64,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ShakeScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF6A4B1F)),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        '开始占卜',
                        style: TextStyle(
                          color: Color(0xFFD8C09A),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Start Divination',
                        style: TextStyle(
                          color: Color(0xFF9B8C7A),
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaijiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFFB58A55)
      ..strokeWidth = 2;
    final darkPaint = Paint()..color = const Color(0xFF1E1A2A);
    final lightPaint = Paint()..color = const Color(0xFFE7D7C5);
    final glowPaint = Paint()
      ..color = const Color(0xFFB58A55).withOpacity(0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawCircle(center, radius, glowPaint);
    canvas.drawCircle(center, radius, outerPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -pi / 2, pi, true, lightPaint);
    canvas.drawArc(rect, pi / 2, pi, true, darkPaint);

    final smallRadius = radius / 2;
    canvas.drawCircle(
      Offset(center.dx, center.dy - smallRadius),
      smallRadius,
      darkPaint,
    );
    canvas.drawCircle(
      Offset(center.dx, center.dy + smallRadius),
      smallRadius,
      lightPaint,
    );

    canvas.drawCircle(
      Offset(center.dx, center.dy - smallRadius),
      radius / 10,
      lightPaint,
    );
    canvas.drawCircle(
      Offset(center.dx, center.dy + smallRadius),
      radius / 10,
      darkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BaguaRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF5B3F1E)
      ..strokeWidth = 1.2;
    final glowPaint = Paint()
      ..color = const Color(0xFFB58A55).withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    canvas.drawCircle(center, radius, glowPaint);
    canvas.drawCircle(center, radius, ringPaint);

    final barPaint = Paint()
      ..color = const Color(0xFFD3A73A)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 8; i++) {
      final angle = (pi * 2 / 8) * i - pi / 2;
      final offset = Offset(cos(angle), sin(angle));
      final outer = center + offset * (radius * 0.92);
      final inner = center + offset * (radius * 0.78);
      final spacing = Offset(-offset.dy, offset.dx) * 4;
      canvas.drawLine(inner - spacing, outer - spacing, barPaint);
      canvas.drawLine(inner, outer, barPaint);
      canvas.drawLine(inner + spacing, outer + spacing, barPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
