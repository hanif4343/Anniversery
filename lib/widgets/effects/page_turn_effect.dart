import 'dart:math';
import 'package:flutter/material.dart';

/// Simulates a book-page-turn: the content rotates in around the Y axis
/// as if a page is flipping open. Good as the "Love Journey Book" feel
/// you wanted between chapters.
class PageTurnEffect extends StatefulWidget {
  final Widget child;
  const PageTurnEffect({super.key, required this.child});

  @override
  State<PageTurnEffect> createState() => _PageTurnEffectState();
}

class _PageTurnEffectState extends State<PageTurnEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _angle;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _angle = Tween<double>(begin: pi / 2, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1.0)),
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
        return Opacity(
          opacity: _fade.value,
          child: Transform(
            alignment: Alignment.centerLeft,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateY(_angle.value),
            child: widget.child,
          ),
        );
      },
    );
  }
}
