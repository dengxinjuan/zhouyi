import 'dart:math';

import 'package:flutter/material.dart';

import '../data/hexagram_data.dart';
import '../models/hexagram.dart';
import '../widgets/star_field.dart';
import 'formed_screen.dart';

class ShakeScreen extends StatefulWidget {
  const ShakeScreen({super.key});

  @override
  State<ShakeScreen> createState() => _ShakeScreenState();
}

class _ShakeScreenState extends State<ShakeScreen>
    with TickerProviderStateMixin {
  static const int _maxCount = 6;
  int _count = 0;
  late final AnimationController _pulse;
  AnimationController? _coinOrbit;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _ensureCoinOrbit();
  }

  @override
  void dispose() {
    _pulse.dispose();
    _coinOrbit?.dispose();
    super.dispose();
  }

  void _ensureCoinOrbit() {
    _coinOrbit ??= AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  Future<void> _increment() async {
    if (_count >= _maxCount) {
      if (!mounted) return;
      final list = await loadHexagrams();
      if (!mounted) return;
      final hexagram = getRandomHexagram(list);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 700),
          pageBuilder: (_, __, ___) => FormingScreen(hexagram: hexagram),
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
      return;
    }
    setState(() {
      _count += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    _ensureCoinOrbit();
    final size = MediaQuery.sizeOf(context);
    final base = min(size.width, size.height);
    final ringSize = base * 0.42;
    final coinOrbitSize = ringSize * 1.15;
    final coinOrbit = _coinOrbit!;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _increment,
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
                      Icons.volume_up_rounded,
                      color: Color(0xFFB98A2F),
                    ),
                  ),
                ),
                Positioned(
                  top: size.height * 0.10,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: const [
                      Text(
                        '占卜问事',
                        style: TextStyle(
                          color: Color(0xFFC9B596),
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '连摇铜钱6次…',
                        style: TextStyle(
                          color: Color(0xFF8C8274),
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: size.height * 0.36,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: const [
                      Text(
                        '摇一摇卦象',
                        style: TextStyle(
                          color: Color(0xFFE7D7C5),
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Shake to Cast',
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
                  top: size.height * 0.32,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, child) {
                      final t = Curves.easeInOut.transform(_pulse.value);
                      return Center(
                        child: Transform.scale(
                          scale: 0.94 + t * 0.08,
                          child: CustomPaint(
                            size: Size.square(ringSize),
                            painter: _EnergyRingPainter(intensity: t),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: size.height * 0.30,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([coinOrbit, _pulse]),
                    builder: (context, child) {
                      return Center(
                        child: CustomPaint(
                          size: Size.square(coinOrbitSize),
                          painter: _CoinOrbitPainter(
                            rotation: coinOrbit.value,
                            pulse: Curves.easeInOut.transform(_pulse.value),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: size.height * 0.20,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        '$_count / $_maxCount',
                        style: const TextStyle(
                          color: Color(0xFFB9A891),
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SingleLineProgress(count: _count, maxCount: _maxCount),
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

class _EnergyRingPainter extends CustomPainter {
  const _EnergyRingPainter({required this.intensity});

  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFFB58A55).withOpacity(0.35 + intensity * 0.25)
      ..strokeWidth = 2;
    final glowPaint = Paint()
      ..color = const Color(0xFFB56BFF).withOpacity(0.12 + intensity * 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);

    canvas.drawCircle(center, radius, glowPaint);
    canvas.drawCircle(center, radius * 0.72, glowPaint);
    canvas.drawCircle(center, radius, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _EnergyRingPainter oldDelegate) {
    return oldDelegate.intensity != intensity;
  }
}

class _SingleLineProgress extends StatelessWidget {
  const _SingleLineProgress({required this.count, required this.maxCount});

  final int count;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    final progress = maxCount == 0 ? 0.0 : count / maxCount;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              width: 180,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2334),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              width: 180 * progress.clamp(0.0, 1.0),
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFB58A55),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB58A55).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CoinOrbitPainter extends CustomPainter {
  const _CoinOrbitPainter({required this.rotation, required this.pulse});

  final double rotation;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final coinRadius = radius * 0.12;
    final holeSize = coinRadius * 0.55;
    final coinPaint = Paint()..color = const Color(0xFFB88211);
    final coinShadow = Paint()
      ..color = const Color(0xFF6A4B1F).withOpacity(0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final holePaint = Paint()..color = const Color(0xFF3A2A18);

    for (var i = 0; i < 6; i++) {
      final angle = rotation * pi * 2 + (pi * 2 / 6) * i - pi / 2;
      final wobble = sin((rotation * pi * 2) + i) * (radius * 0.12) * pulse;
      final currentRadius = radius + wobble;
      final offset = Offset(cos(angle), sin(angle)) * currentRadius;
      final coinCenter = center + offset;

      canvas.drawCircle(coinCenter, coinRadius + 1.5, coinShadow);
      canvas.drawCircle(coinCenter, coinRadius, coinPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: coinCenter,
            width: holeSize,
            height: holeSize,
          ),
          const Radius.circular(2),
        ),
        holePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CoinOrbitPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.pulse != pulse;
  }
}
