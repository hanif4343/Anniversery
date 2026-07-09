import 'dart:math';
import 'package:flutter/material.dart';

/// A reusable overlay that animates a handful of emoji particles falling
/// or floating across the screen. Used by rose_petal_fall, heart_float,
/// golden_dust, and as a layer inside fireworks. Runs once for
/// [duration] then stays invisible (so it doesn't distract while reading).
class ParticleOverlay extends StatefulWidget {
  final String emoji;
  final int count;
  final Duration duration;
  final bool fromTop; // true = falls from top, false = floats up from bottom

  const ParticleOverlay({
    super.key,
    required this.emoji,
    this.count = 14,
    this.duration = const Duration(seconds: 4),
    this.fromTop = true,
  });

  @override
  State<ParticleOverlay> createState() => _ParticleOverlayState();
}

class _Particle {
  final double startX;
  final double delay; // 0..1 fraction of total duration
  final double size;
  final double drift; // horizontal sway amount
  _Particle(this.startX, this.delay, this.size, this.drift);
}

class _ParticleOverlayState extends State<ParticleOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    _particles = List.generate(widget.count, (_) {
      return _Particle(
        rng.nextDouble(), // startX 0..1
        rng.nextDouble() * 0.6, // staggered start
        14 + rng.nextDouble() * 14, // size 14..28
        (rng.nextDouble() - 0.5) * 60, // drift -30..30
      );
    });
    _controller = AnimationController(vsync: this, duration: widget.duration)..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: _particles.map((p) {
                  // progress for this particular particle, accounting for its delay
                  double t = ((_controller.value - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
                  final travel = widget.fromTop
                      ? Tween<double>(begin: -30, end: constraints.maxHeight + 30).transform(t)
                      : Tween<double>(begin: constraints.maxHeight + 30, end: -30).transform(t);
                  final opacity = (t < 0.1) ? t / 0.1 : (t > 0.85 ? (1 - t) / 0.15 : 1.0);
                  final x = p.startX * constraints.maxWidth + sin(t * pi * 2) * p.drift;
                  return Positioned(
                    left: x,
                    top: widget.fromTop ? travel : null,
                    bottom: widget.fromTop ? null : travel,
                    child: Opacity(
                      opacity: opacity.clamp(0.0, 1.0),
                      child: Text(widget.emoji, style: TextStyle(fontSize: p.size)),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
