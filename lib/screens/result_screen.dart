import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/hexagram.dart';
import '../widgets/star_field.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.hexagram});

  final Hexagram hexagram;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _lineController;
  late final Animation<double> _hexScale;
  late final Animation<double> _hexOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<double> _buttonOpacity;
  late final List<Animation<double>> _lineProgress;
  late final int _randomLineIndex;

  @override
  void initState() {
    super.initState();
    _randomLineIndex = 1 + Random().nextInt(6);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _hexScale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.67, curve: Curves.easeOutCubic),
      ),
    );
    _hexOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.67, curve: Curves.easeOutCubic),
      ),
    );
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.17, 0.61, curve: Curves.easeOut),
      ),
    );
    _buttonOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.33, 0.77, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _lineProgress = List.generate(6, (index) {
      final start = index * 0.1;
      final end = start + 0.33;
      return CurvedAnimation(
        parent: _lineController,
        curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut),
      );
    });
    _lineController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _lineController.dispose();
    super.dispose();
  }

  List<Widget> _buildRandomLineBlock() {
    final key = '$_randomLineIndex';
    final classicalLine =
        widget.hexagram.classical.linesCn[key]?.trim() ?? '';
    final modernLine =
        widget.hexagram.modern.linesExplainedEn[key]?.trim() ?? '';
    if (classicalLine.isEmpty && modernLine.isEmpty) return [];

    return [
      const SizedBox(height: 16),
      Text(
        'Line $_randomLineIndex',
        style: const TextStyle(
          color: Color(0xFF9B8C7A),
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
      if (classicalLine.isNotEmpty) ...[
        const SizedBox(height: 6),
        Text(
          classicalLine,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFB9A891),
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
      if (modernLine.isNotEmpty) ...[
        const SizedBox(height: 6),
        Text(
          modernLine,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF9B8C7A),
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final base = size.shortestSide;
    final hexWidth = base * 0.38;

    return Scaffold(
      backgroundColor: const Color(0xFF090811),
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
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _hexOpacity,
                      child: ScaleTransition(
                        scale: _hexScale,
                          child: AnimatedBuilder(
                          animation: _lineController,
                          builder: (context, child) {
                            return _HexagramView(
                              width: hexWidth,
                              lines: widget.hexagram.lines,
                              lineProgress: _lineProgress,
                              glowPass: _lineController.value,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        children: [
                          Text(
                            widget.hexagram.nameCn,
                            style: const TextStyle(
                              color: Color(0xFFE7D7C5),
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hexagram: ${widget.hexagram.nameEn}',
                            style: const TextStyle(
                              color: Color(0xFF9B8C7A),
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.hexagram.classical.judgmentCn,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFB9A891),
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.hexagram.modern.summaryEn,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF9B8C7A),
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                          ..._buildRandomLineBlock(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeTransition(
                      opacity: _buttonOpacity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF6A4B1F)),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 64,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          'ASK AGAIN',
                          style: TextStyle(
                            color: Color(0xFFB9A891),
                            fontSize: 14,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HexagramView extends StatelessWidget {
  const _HexagramView({
    required this.width,
    required this.lines,
    required this.lineProgress,
    required this.glowPass,
  });

  final double width;
  final List<bool> lines;
  final List<Animation<double>> lineProgress;
  final double glowPass;

  @override
  Widget build(BuildContext context) {
    final height = width * 0.72;

    return CustomPaint(
      size: Size(width, height),
      painter: _HexagramGlowPainter(
        lines: lines,
        lineProgress: lineProgress,
        glowPass: glowPass,
      ),
    );
  }
}

class _HexagramGlowPainter extends CustomPainter {
  _HexagramGlowPainter({
    required this.lines,
    required this.lineProgress,
    required this.glowPass,
  }) : super(repaint: lineProgress.isEmpty ? null : Listenable.merge(lineProgress));

  final List<bool> lines;
  final List<Animation<double>> lineProgress;
  final double glowPass;

  @override
  void paint(Canvas canvas, Size size) {
    final lineCount = lines.length.clamp(0, 6);
    final lineHeight = size.height * 0.10;
    final gap = size.height * 0.06;
    final brokenGap = size.width * 0.16;
    final color = const Color(0xFFB58A55);

    final totalHeight =
        (lineHeight * lineCount) + (gap * (lineCount - 1));
    final startY = (size.height - totalHeight) / 2;

    for (var i = 0; i < lineCount; i++) {
      final isSolid = lines[lineCount - 1 - i];
      final progress = lineProgress[i].value;
      final opacity = lerpDouble(0.4, 1.0, progress)!;
      final glowOpacity = lerpDouble(0.12, 0.45, progress)!;
      final glowPaint = Paint()
        ..color = color.withOpacity(glowOpacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      final linePaint = Paint()..color = color.withOpacity(opacity);
      final y = startY + i * (lineHeight + gap);
      final rect = Rect.fromLTWH(0, y, size.width, lineHeight);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(lineHeight / 2)),
        glowPaint,
      );

      if (isSolid) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(lineHeight / 2)),
          linePaint,
        );
      } else {
        final partWidth = (size.width - brokenGap) / 2;
        final leftRect = Rect.fromLTWH(0, y, partWidth, lineHeight);
        final rightRect = Rect.fromLTWH(
          partWidth + brokenGap,
          y,
          partWidth,
          lineHeight,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(leftRect, Radius.circular(lineHeight / 2)),
          linePaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rightRect, Radius.circular(lineHeight / 2)),
          linePaint,
        );
      }
    }

    final passCenter = lerpDouble(
      size.height * 0.85,
      size.height * 0.15,
      glowPass,
    )!;
    final glowBand = Rect.fromCenter(
      center: Offset(size.width / 2, passCenter),
      width: size.width * 0.9,
      height: size.height * 0.45,
    );
    final bandPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          color.withOpacity(0.22),
          Colors.transparent,
        ],
      ).createShader(glowBand);
    canvas.drawRect(glowBand, bandPaint);
  }

  @override
  bool shouldRepaint(covariant _HexagramGlowPainter oldDelegate) {
    return oldDelegate.glowPass != glowPass;
  }
}
