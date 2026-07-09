import 'dart:math';
import 'package:flutter/material.dart';

/// A celebratory burst effect: several small "explosions" of sparkle
/// emoji radiating outward, layered with the content fading in.
/// Meant for the Anniversary / ending scene.
class FireworksEffect extends StatefulWidget {
  final Widget child;
  const FireworksEffect({super.key, required this.child});

  @override
  State<FireworksEffect> createState() => _FireworksEffectState();
}

class _Burst {
  final Offset center; // fractional 0..1
  final double delay;
  final Color color;
  _Burst(this.center, this.delay, this.color);
}

class _FireworksEffectState extends State<FireworksEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _contentFade;
  final List<_Burst> _bursts = [
    _Burst(const Offset(0.25, 0.3), 0.0, const Color(0xFFFFD54F)),
    _Burst(const Offset(0.75, 0.25), 0.2, const Color(0xFFEC407A)),
    _Burst(const Offset(0.5, 0.45), 0.4, const Color(0xFF64B5F6)),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..forward();
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.1, 0.6)),
    );
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
      builder: (context, _) {
        return Stack(
          children: [
            Opacity(opacity: _contentFade.value, child: widget.child),
            IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: _bursts.map((b) {
                      final t = ((_controller.value - b.delay) / 0.5).clamp(0.0, 1.0);
                      return _BurstParticles(
                        center: Offset(b.center.dx * constraints.maxWidth, b.center.dy * constraints.maxHeight),
                        progress: t,
                        color: b.color,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BurstParticles extends StatelessWidget {
  final Offset center;
  final double progress; // 0..1
  final Color color;
  const _BurstParticles({required this.center, required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    const particleCount = 10;
    final opacity = progress < 0.15 ? progress / 0.15 : (1 - progress);
    return Stack(
      children: List.generate(particleCount, (i) {
        final angle = (2 * pi / particleCount) * i;
        final radius = 70 * progress;
        final dx = center.dx + cos(angle) * radius;
        final dy = center.dy + sin(angle) * radius;
        return Positioned(
          left: dx,
          top: dy,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        );
      }),
    );
  }
}
