import 'package:flutter/material.dart';
import 'particle_overlay.dart';
import 'envelope_letter_effect.dart';
import 'ring_slide_effect.dart';
import 'camera_flash_effect.dart';
import 'page_turn_effect.dart';
import 'fireworks_effect.dart';

/// Single entry point used by StoryPlayerScreen: given a moment's
/// `entranceEffect` key (chosen in the Creator Mode dropdown), wraps
/// [child] with the matching animation. This is the only file
/// StoryPlayerScreen needs to import to get all effects.
class EntranceEffect extends StatelessWidget {
  final String effectKey;
  final Widget child;

  const EntranceEffect({super.key, required this.effectKey, required this.child});

  @override
  Widget build(BuildContext context) {
    switch (effectKey) {
      case 'envelope_letter':
        return EnvelopeLetterEffect(child: child);

      case 'ring_slide':
        return RingSlideEffect(child: child);

      case 'camera_flash':
        return CameraFlashEffect(child: child);

      case 'page_turn':
        return PageTurnEffect(child: child);

      case 'fireworks':
        return FireworksEffect(child: child);

      case 'rose_petal_fall':
        return Stack(children: [
          _FadeIn(child: child),
          const ParticleOverlay(emoji: '🌹', fromTop: true, count: 12),
        ]);

      case 'heart_float':
        return Stack(children: [
          _FadeIn(child: child),
          const ParticleOverlay(emoji: '❤️', fromTop: false, count: 10),
        ]);

      case 'golden_dust':
        return Stack(children: [
          _FadeIn(child: child),
          const ParticleOverlay(emoji: '✨', fromTop: true, count: 16, duration: Duration(seconds: 5)),
        ]);

      case 'zoom':
        return _ZoomIn(child: child);

      case 'fade':
      default:
        return _FadeIn(child: child);
    }
  }
}

class _FadeIn extends StatefulWidget {
  final Widget child;
  const _FadeIn({required this.child});

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _ZoomIn extends StatefulWidget {
  final Widget child;
  const _ZoomIn({required this.child});

  @override
  State<_ZoomIn> createState() => _ZoomInState();
}

class _ZoomInState extends State<_ZoomIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _scale = Tween<double>(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
