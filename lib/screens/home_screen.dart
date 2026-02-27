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
    with TickerProviderStateMixin {
  late final AnimationController _rotation;
  late final AnimationController _counterRotation;

  @override
  void initState() {
    super.initState();
    _rotation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
    _counterRotation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _rotation.dispose();
    _counterRotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final base = min(size.width, size.height);
    final ringSize = base * 0.65;
    final taijiSize = ringSize * 0.48;

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
              // Star field background
              CustomPaint(
                size: size,
                painter: StarFieldPainter(),
              ),

              // Sound toggle button
              Positioned(
                top: 24,
                right: 20,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF6A4B1F)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.volume_off_rounded,
                    color: Color(0xFFB98A2F),
                  ),
                ),
              ),

              // Header
              Positioned(
                top: size.height * 0.08,
                left: 0,
                right: 0,
                child: const Column(
                  children: [
                    Text(
                      '易占未来',
                      textAlign: TextAlign.center,
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
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF9B8C7A),
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // Bagua ring + Yin-Yang — vertically centered
              Positioned.fill(
                child: Center(
                  child: SizedBox(
                    width: ringSize,
                    height: ringSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Bagua ring (clockwise, slow)
                        RotationTransition(
                          turns: _rotation,
                          child: CustomPaint(
                            size: Size.square(ringSize),
                            painter: _BaguaSymbolPainter(),
                          ),
                        ),
                        // Inner Yin-Yang (counter-clockwise)
                        RotationTransition(
                          turns: Tween(begin: 0.0, end: -1.0)
                              .animate(_counterRotation),
                          child: CustomPaint(
                            size: Size.square(taijiSize),
                            painter: _TaijiPainter(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Start button
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
                  child: const Column(
                    children: [
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

// Draws the outer Bagua ring with the 8 proper trigrams (实线/broken lines).
class _BaguaSymbolPainter extends CustomPainter {
  // The 8 trigrams in "Earlier Heaven" sequence, starting from top (South)
  // and going clockwise. Each inner list is [top-line, mid-line, bottom-line].
  // true = solid Yang (─────), false = broken Yin (── ──)
  static const List<List<bool>> _trigrams = [
    [true, true, true],    // ☰ Qian  (Heaven)   — top
    [false, false, false], // ☷ Kun   (Earth)
    [true, false, false],  // ☳ Zhen  (Thunder)
    [false, true, false],  // ☵ Kan   (Water)
    [false, false, true],  // ☶ Gen   (Mountain)
    [false, true, true],   // ☴ Xun   (Wind)
    [true, false, true],   // ☲ Li    (Fire)
    [true, true, false],   // ☱ Dui   (Lake)
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // Ambient glow behind the ring
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFB58A55).withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );

    // Outer ring border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFD4A574).withOpacity(0.35)
        ..strokeWidth = 1.5,
    );

    // Inner ring border (demarcates the trigram zone from the Taiji center)
    canvas.drawCircle(
      center,
      radius * 0.60,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFD4A574).withOpacity(0.18)
        ..strokeWidth = 1.0,
    );

    // Trigram dimensions, relative to radius so they scale with the widget
    final trigramRadius = radius * 0.80; // distance from center to trigram midpoint
    final solidHalf = radius * 0.13;     // half-length of a solid (Yang) line
    final brokenHalf = radius * 0.05;    // half-length of each broken (Yin) segment
    final lineSpacing = radius * 0.065;  // gap between the 3 stacked lines

    final linePaint = Paint()
      ..color = const Color(0xFFD3A73A).withOpacity(0.88)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 8; i++) {
      // Angle: start at top (-π/2) and step clockwise
      final angle = (pi * 2 / 8) * i - pi / 2;

      canvas.save();
      canvas.translate(
        center.dx + cos(angle) * trigramRadius,
        center.dy + sin(angle) * trigramRadius,
      );
      // Rotate so the trigram lines are perpendicular to the radius,
      // with the top of the trigram facing outward from the center.
      canvas.rotate(angle + pi / 2);

      final trigram = _trigrams[i];
      for (var j = 0; j < 3; j++) {
        // j=0 → outermost line  (negative local-Y = away from center)
        // j=1 → middle line
        // j=2 → innermost line  (positive local-Y = toward center)
        final yOffset = (j - 1) * lineSpacing;

        if (trigram[j]) {
          // Solid Yang line
          canvas.drawLine(
            Offset(-solidHalf, yOffset),
            Offset(solidHalf, yOffset),
            linePaint,
          );
        } else {
          // Broken Yin line (two segments with gap)
          canvas.drawLine(
            Offset(-solidHalf, yOffset),
            Offset(-brokenHalf, yOffset),
            linePaint,
          );
          canvas.drawLine(
            Offset(brokenHalf, yOffset),
            Offset(solidHalf, yOffset),
            linePaint,
          );
        }
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Traditional Yin-Yang (Taiji) symbol, drawn at the center of the Bagua ring.
class _TaijiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final smallRadius = radius / 2;

    // Glow halo
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFFB58A55).withOpacity(0.40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    final darkPaint = Paint()..color = const Color(0xFF1E1A2A);
    final lightPaint = Paint()..color = const Color(0xFFE7D7C5);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Light (Yang) half — right side
    canvas.drawArc(rect, -pi / 2, pi, true, lightPaint);
    // Dark (Yin) half — left side
    canvas.drawArc(rect, pi / 2, pi, true, darkPaint);

    // Small dark circle inside the light half
    canvas.drawCircle(
      Offset(center.dx, center.dy - smallRadius),
      smallRadius,
      darkPaint,
    );
    // Small light circle inside the dark half
    canvas.drawCircle(
      Offset(center.dx, center.dy + smallRadius),
      smallRadius,
      lightPaint,
    );

    // Contrasting dots
    canvas.drawCircle(
      Offset(center.dx, center.dy - smallRadius),
      radius / 9,
      lightPaint,
    );
    canvas.drawCircle(
      Offset(center.dx, center.dy + smallRadius),
      radius / 9,
      darkPaint,
    );

    // Outer border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFB58A55)
        ..strokeWidth = 1.8,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
