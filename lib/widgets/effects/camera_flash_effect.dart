import 'package:flutter/material.dart';

/// A quick white flash (like a camera going off) that fades away to
/// reveal the moment underneath. Good for candid/photo-heavy moments.
class CameraFlashEffect extends StatefulWidget {
  final Widget child;
  const CameraFlashEffect({super.key, required this.child});

  @override
  State<CameraFlashEffect> createState() => _CameraFlashEffectState();
}

class _CameraFlashEffectState extends State<CameraFlashEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _flashOpacity;
  late final Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

    _flashOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 85),
    ]).animate(_controller);

    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.15, 0.7)),
    );

    _controller.forward();
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
              child: Opacity(
                opacity: _flashOpacity.value,
                child: Container(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
