import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Oval outline around the camera. Dashed while detecting, dashes travel while
/// analysing, solid once matched or failed.
class ScanRing extends StatefulWidget {
  const ScanRing({
    super.key,
    required this.color,
    required this.dashed,
    required this.animate,
  });

  final Color color;
  final bool dashed;
  final bool animate;

  @override
  State<ScanRing> createState() => _ScanRingState();
}

class _ScanRingState extends State<ScanRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(ScanRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.animate) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
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
      builder: (context, _) => CustomPaint(
        size: Size.infinite,
        painter: _RingPainter(
          color: widget.color,
          dashed: widget.dashed,
          phase: _controller.value,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.color,
    required this.dashed,
    required this.phase,
  });

  final Color color;
  final bool dashed;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 5 / 250;
    final inset = paint.strokeWidth / 2;
    final path = Path()
      ..addOval(Rect.fromLTWH(inset, inset, size.width - 2 * inset,
          size.height - 2 * inset));

    if (!dashed) {
      canvas.drawPath(path, paint);
      return;
    }

    final dash = size.width * 14 / 250;
    final gap = size.width * 10 / 250;
    for (final metric in path.computeMetrics()) {
      var distance = phase * (dash + gap);
      // Start before zero so the dash pattern wraps cleanly.
      distance -= dash + gap;
      while (distance < metric.length) {
        final start = math.max(distance, 0.0);
        final end = math.min(distance + dash, metric.length);
        if (end > start) canvas.drawPath(metric.extractPath(start, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.color != color || old.dashed != dashed || old.phase != phase;
}
