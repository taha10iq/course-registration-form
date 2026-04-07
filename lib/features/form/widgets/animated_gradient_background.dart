import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final progress = _controller.value;
        return Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.pageGradient),
            ),
            CustomPaint(
              painter: _TechGridPainter(progress: progress),
            ),
            _GlowOrb(
              size: 320,
              alignment: const Alignment(-1.12, -0.94),
              color: AppColors.neonBlue,
              offset: Offset(
                24 * math.sin(progress * math.pi * 2),
                18 * math.cos(progress * math.pi * 2),
              ),
            ),
            _GlowOrb(
              size: 280,
              alignment: const Alignment(1.05, -0.2),
              color: AppColors.neonPurple,
              offset: Offset(
                -20 * math.cos(progress * math.pi * 2),
                22 * math.sin(progress * math.pi * 2),
              ),
            ),
            _GlowOrb(
              size: 260,
              alignment: const Alignment(0.4, 1.1),
              color: AppColors.neonGreen,
              offset: Offset(
                16 * math.sin(progress * math.pi * 4),
                -14 * math.cos(progress * math.pi * 2),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.12),
                    AppColors.background.withValues(alpha: 0.58),
                  ],
                ),
              ),
            ),
            child ?? const SizedBox.shrink(),
          ],
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.alignment,
    required this.color,
    required this.offset,
  });

  final double size;
  final Alignment alignment;
  final Color color;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: IgnorePointer(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.24),
                  color.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.42, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TechGridPainter extends CustomPainter {
  const _TechGridPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.neonBlue.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    const cell = 42.0;
    for (double x = -cell; x <= size.width + cell; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = -cell; y <= size.height + cell; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final scanTop = (size.height + 120) * progress - 120;
    final scanRect = Rect.fromLTWH(0, scanTop, size.width, 120);
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.neonGreen.withValues(alpha: 0.14),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(scanRect);
    canvas.drawRect(scanRect, scanPaint);

    final circuitPaint = Paint()
      ..color = AppColors.neonPurple.withValues(alpha: 0.16)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final circuitPath = Path()
      ..moveTo(size.width * 0.08, size.height * 0.22)
      ..lineTo(size.width * 0.28, size.height * 0.22)
      ..lineTo(size.width * 0.36, size.height * 0.33)
      ..lineTo(size.width * 0.76, size.height * 0.33)
      ..lineTo(size.width * 0.88, size.height * 0.16);
    canvas.drawPath(circuitPath, circuitPaint);

    final nodes = [
      Offset(size.width * 0.28, size.height * 0.22),
      Offset(size.width * 0.36, size.height * 0.33),
      Offset(size.width * 0.76, size.height * 0.33),
      Offset(size.width * 0.88, size.height * 0.16),
    ];

    for (final node in nodes) {
      canvas.drawCircle(
        node,
        10,
        Paint()..color = AppColors.neonBlue.withValues(alpha: 0.06),
      );
      canvas.drawCircle(
        node,
        3,
        Paint()..color = AppColors.neonBlue.withValues(alpha: 0.2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TechGridPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
