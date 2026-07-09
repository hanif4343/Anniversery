import 'package:flutter/material.dart';
import 'creator_lock_screen.dart';
import 'story_intro_screen.dart';

/// The very first screen. Cinematic dark background with the couple's
/// names and two entry points: the private editing mode, and the
/// story experience your wife will actually see.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D0620), Color(0xFF2A1245), Color(0xFF3D1635)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('❤️', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  const Text(
                    'Hanif  ❤️  Santona',
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w300),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '17 July 2026 — 4th Anniversary',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(220, 48)),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StoryIntroScreen()),
                      );
                    },
                    child: const Text('Begin Journey'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CreatorLockScreen()),
                      );
                    },
                    child: const Text('Creator Mode', style: TextStyle(color: Colors.white54)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
