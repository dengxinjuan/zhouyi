import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../widgets/star_field.dart';
import 'result_screen.dart';

class FormingScreen extends StatefulWidget {
  const FormingScreen({super.key});

  @override
  State<FormingScreen> createState() => _FormingScreenState();
}

class _FormingScreenState extends State<FormingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _hexController;
  late final AnimationController _particleController;
  late final AnimationController _textController;
  late final AnimationController _fadeOutController;

  @override
  void initState() {
    super.initState();
    _hexController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) {
        return;
      }
      _fadeOutController.forward();
    });

    _fadeOutController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 700),
            pageBuilder: (_, __, ___) => const ResultScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(child: const TransitionBackground()),
                  FadeTransition(opacity: animation, child: child),
                ],
              );
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _hexController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final base = min(size.width, size.height);
    final hexSize = base * 0.36;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1238), // Purple so fade-out shows purple, not black
      body: FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0).animate(
          CurvedAnimation(parent: _fadeOutController, curve: Curves.easeInOut),
        ),
        child: Container(
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
                AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: size,
                      painter: _FloatingParticlesPainter(
                        progress: _particleController.value,
                      ),
                    );
                  },
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
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _hexController,
                        builder: (context, child) {
                          final t = Curves.easeInOut.transform(
                            _hexController.value,
                          );
                          return ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: 6 * (1 - t),
                              sigmaY: 6 * (1 - t),
                            ),
                            child: CustomPaint(
                              size: Size(hexSize, hexSize * 0.8),
                              painter: _HexagramPainter(intensity: t),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 28),
                      FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _textController,
                          curve: Curves.easeOut,
                        ),
                        child: Column(
                          children: const [
                            Text(
                              '解卦',
                              style: TextStyle(
                                color: Color(0xFFE7D7C5),
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Hexagram: Forming',
                              style: TextStyle(
                                color: Color(0xFF9B8C7A),
                                fontSize: 14,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HexagramPainter extends CustomPainter {
  const _HexagramPainter({required this.intensity});

  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Color.lerp(
        const Color(0xFF3D2C1E),
        const Color(0xFFB58A55),
        intensity,
      )!
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final glowPaint = Paint()
      ..color = const Color(0xFFB58A55).withOpacity(0.25 + intensity * 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    final lineSpacing = size.height / 7;
    final startX = size.width * 0.12;
    final endX = size.width * 0.88;

    for (var i = 0; i < 6; i++) {
      final y = lineSpacing * (i + 1);
      canvas.drawLine(
        Offset(startX, y),
        Offset(endX, y),
        glowPaint,
      );
      canvas.drawLine(
        Offset(startX, y),
        Offset(endX, y),
        linePaint,
      );
    }

    final glowTop = lerpDouble(0, size.height, intensity)!;
    final glowRect = Rect.fromCenter(
      center: Offset(size.width / 2, glowTop),
      width: size.width * 0.9,
      height: size.height * 0.4,
    );
    final glowGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFFB58A55).withOpacity(0.35),
          Colors.transparent,
        ],
      ).createShader(glowRect);
    canvas.drawRect(glowRect, glowGradient);
    // TODO: refine glow pass timing and density.
  }

  @override
  bool shouldRepaint(covariant _HexagramPainter oldDelegate) {
    return oldDelegate.intensity != intensity;
  }
}

class _FloatingParticlesPainter extends CustomPainter {
  const _FloatingParticlesPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFB56BFF).withOpacity(0.18);
    final glow = Paint()
      ..color = const Color(0xFFB56BFF).withOpacity(0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    for (var i = 0; i < 18; i++) {
      final dx = (sin(i * 1.7 + progress * 2 * pi) * 0.08 + 0.5) * size.width;
      final dy = (cos(i * 1.3 + progress * 2 * pi) * 0.08 + 0.2) *
          size.height;
      final r = 1.4 + (i % 3) * 0.8;
      final point = Offset(dx, dy);
      canvas.drawCircle(point, r * 2.4, glow);
      canvas.drawCircle(point, r, paint);
    }
    // TODO: add variation to particle opacity for depth.
  }

  @override
  bool shouldRepaint(covariant _FloatingParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
