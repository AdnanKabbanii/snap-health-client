import 'dart:math';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';

class ScoreRing extends StatelessWidget {
  final double score;
  final double size;
  final bool showLabel;
  final bool animate;

  const ScoreRing({
    super.key,
    required this.score,
    this.size = 80,
    this.showLabel = true,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = scoreToColor(score);
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: animate ? 0 : score, end: score),
        duration: const Duration(milliseconds: 900),
        curve: kCurveEmphasized,
        builder: (context, animated, _) {
          return CustomPaint(
            painter: _RingPainter(
              score: animated,
              color: color,
              trackColor: kSurfaceHighest,
              tickColor: kHairline,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    animated.toStringAsFixed(animated >= 9.95 || animated == animated.roundToDouble() ? 0 : 1),
                    style: kMono(size * 0.3, weight: FontWeight.w600, color: color).copyWith(height: 1),
                  ),
                  if (showLabel && size >= 90) ...[
                    SizedBox(height: size * 0.04),
                    Text(
                      scoreToLabel(score),
                      style: kMono(size * 0.075, weight: FontWeight.w500, letterSpacing: 1.8,
                          color: kOnSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double score;
  final Color color;
  final Color trackColor;
  final Color tickColor;

  _RingPainter({
    required this.score,
    required this.color,
    required this.trackColor,
    required this.tickColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final stroke = (size.width * 0.055).clamp(3.5, 9.0);
    final radius = size.width / 2 - stroke;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, track);

    final tick = Paint()
      ..color = tickColor
      ..strokeWidth = 1.2;
    for (var i = 0; i < 10; i++) {
      final angle = -pi / 2 + (i / 10) * 2 * pi;
      final outer = Offset(center.dx + (radius + stroke * 0.9) * cos(angle),
          center.dy + (radius + stroke * 0.9) * sin(angle));
      final inner = Offset(center.dx + (radius + stroke * 0.35) * cos(angle),
          center.dy + (radius + stroke * 0.35) * sin(angle));
      canvas.drawLine(inner, outer, tick);
    }

    final sweep = (score / 10) * 2 * pi;
    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, sweep, false, arc);

    if (score > 0.1) {
      final endAngle = -pi / 2 + sweep;
      final dot = Offset(center.dx + radius * cos(endAngle), center.dy + radius * sin(endAngle));
      canvas.drawCircle(dot, stroke * 0.62, Paint()..color = color);
      canvas.drawCircle(
        dot,
        stroke * 1.4,
        Paint()
          ..color = color.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.score != score || old.color != color;
}
