import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated ring / arc progress indicator used in the session screen.
/// Displays the current count vs. target as a circular arc with a glow
/// effect and animated counter text in the centre.
class RingProgressWidget extends StatelessWidget {
  final int current;
  final int target;
  final double size;
  final double strokeWidth;
  final Color? color;

  const RingProgressWidget({
    super.key,
    required this.current,
    required this.target,
    this.size = 260,
    this.strokeWidth = 14,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.colorScheme.primary;
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress,
              strokeWidth: strokeWidth,
              bgColor: progressColor.withAlpha(40),
              fgColor: progressColor,
            ),
          ),
          // Counter text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: current),
                duration: const Duration(milliseconds: 350),
                builder: (_, value, __) => Text(
                  '$value',
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ),
              Text(
                'of $target',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color bgColor;
  final Color fgColor;

  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.bgColor,
    required this.fgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: centre, radius: radius);

    // Background circle
    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(centre, radius, bgPaint);

    // Foreground arc
    if (progress > 0) {
      final fgPaint = Paint()
        ..color = fgColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      // Optional glow
      final glowPaint = Paint()
        ..color = fgColor.withAlpha(60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(rect, startAngle, sweepAngle, false, glowPaint);
      canvas.drawArc(rect, startAngle, sweepAngle, false, fgPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.fgColor != fgColor;
}
