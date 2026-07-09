import 'package:flutter/material.dart';
import 'story_player_screen.dart';

/// The very first thing your wife sees after tapping "Begin Journey":
/// a few lines fading in one at a time over a dark, starry background,
/// building anticipation before the story actually starts.
class StoryIntroScreen extends StatefulWidget {
  const StoryIntroScreen({super.key});

  @override
  State<StoryIntroScreen> createState() => _StoryIntroScreenState();
}

class _StoryIntroScreenState extends State<StoryIntroScreen> {
  int _lineIndex = 0;

  final List<String> _lines = const [
    'কিছু গল্প লেখা থাকে ভাগ্যে...',
    'কিছু গল্প লেখা হয় ভালোবাসায়...',
    'এই গল্পটা...',
    'হানিফ ❤️ সান্তনার',
  ];

  @override
  void initState() {
    super.initState();
    _playSequence();
  }

  Future<void> _playSequence() async {
    for (int i = 0; i < _lines.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1800));
      if (!mounted) return;
      setState(() => _lineIndex = i);
    }
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() => _lineIndex = _lines.length); // show the Start button
  }

  @override
  Widget build(BuildContext context) {
    final showButton = _lineIndex >= _lines.length;

    return Scaffold(
      backgroundColor: const Color(0xFF070312),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 900),
              child: showButton
                  ? Column(
                      key: const ValueKey('start'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'হানিফ ❤️ সান্তনা',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 36),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const StoryPlayerScreen()),
                            );
                          },
                          child: const Text('যাত্রা শুরু করি'),
                        ),
                      ],
                    )
                  : Text(
                      _lines[_lineIndex],
                      key: ValueKey(_lineIndex),
                      style: const TextStyle(color: Colors.white70, fontSize: 20, height: 1.6),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
