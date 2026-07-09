import 'package:flutter/material.dart';

/// A ring icon slides in from off-screen, settles in the center with a
/// small bounce, then fades out while the actual content fades in.
/// Meant for proposal / engagement moments.
class RingSlideEffect extends StatefulWidget {
  final Widget child;
  const RingSlideEffect({super.key, required this.child});

  @override
  State<RingSlideEffect> createState() => _RingSlideEffectState();
}

class _RingSlideEffectState extends State<RingSlideEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideX;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _ringScale;
  late final Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));

    _slideX = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -300.0, end: 20.0).chain(CurveTween(curve: Curves.easeOutBack)), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 20.0, end: 0.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.55)));

    _ringScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack)),
    );

    _ringOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 0.85)),
    );

    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.65, 1.0)),
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
          alignment: Alignment.center,
          children: [
            Opacity(opacity: _contentFade.value, child: widget.child),
            if (_ringOpacity.value > 0)
              Opacity(
                opacity: _ringOpacity.value,
                child: Transform.translate(
                  offset: Offset(_slideX.value, 0),
                  child: Transform.scale(
                    scale: _ringScale.value,
                    child: const Text('💍', style: TextStyle(fontSize: 72)),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
