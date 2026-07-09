import 'package:flutter/material.dart';

/// Plays an envelope that opens and a "letter" sliding out, then reveals
/// [child] underneath. Good for proposal / love-letter style moments.
class EnvelopeLetterEffect extends StatefulWidget {
  final Widget child;
  const EnvelopeLetterEffect({super.key, required this.child});

  @override
  State<EnvelopeLetterEffect> createState() => _EnvelopeLetterEffectState();
}

class _EnvelopeLetterEffectState extends State<EnvelopeLetterEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _flapAngle;
  late final Animation<double> _letterRise;
  late final Animation<double> _envelopeFade;
  late final Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));

    _flapAngle = Tween<double>(begin: 0, end: -3.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.35, curve: Curves.easeOut)),
    );
    _letterRise = Tween<double>(begin: 0, end: -120).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.7, curve: Curves.easeOut)),
    );
    _envelopeFade = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.55, 0.75, curve: Curves.easeOut)),
    );
    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.65, 1.0, curve: Curves.easeOut)),
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
            if (_envelopeFade.value > 0)
              Opacity(
                opacity: _envelopeFade.value,
                child: Center(
                  child: SizedBox(
                    height: 160,
                    width: 220,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        // Envelope body
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: 220,
                            height: 130,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4E9DD),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10)],
                            ),
                          ),
                        ),
                        // Letter sliding up out of the envelope
                        Positioned(
                          bottom: 30 - _letterRise.value * -1 + _letterRise.value,
                          child: Transform.translate(
                            offset: Offset(0, _letterRise.value),
                            child: Container(
                              width: 170,
                              height: 110,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                              ),
                              child: const Icon(Icons.favorite, color: Color(0xFFB1546B), size: 28),
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                        // Envelope flap (triangle) that opens
                        Positioned(
                          top: 30,
                          child: Transform(
                            alignment: Alignment.topCenter,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateX(_flapAngle.value),
                            child: ClipPath(
                              clipper: _TriangleClipper(),
                              child: Container(width: 220, height: 70, color: const Color(0xFFE7D4BE)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
