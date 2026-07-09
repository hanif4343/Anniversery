import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../services/storage_service.dart';
import 'chapter_moments_screen.dart';
import 'story_player_screen.dart';

/// The editing dashboard. Lists all chapters with a progress summary at
/// top, and a shortcut to preview the whole story from the beginning —
/// useful during Day 6/7 testing without having to go back to Home.
class CreatorHomeScreen extends StatefulWidget {
  const CreatorHomeScreen({super.key});

  @override
  State<CreatorHomeScreen> createState() => _CreatorHomeScreenState();
}

class _CreatorHomeScreenState extends State<CreatorHomeScreen> {
  final _storage = StorageService();

  @override
  Widget build(BuildContext context) {
    final chapters = _storage.getAllChapters();
    final totalMoments = _storage.getAllMomentsInStoryOrder().length;
    final chaptersWithContent = chapters.where((c) => _storage.getMomentsForChapter(c.id).isNotEmpty).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Creator Mode — অধ্যায়সমূহ'),
        actions: [
          if (totalMoments > 0)
            IconButton(
              icon: const Icon(Icons.play_circle_outline),
              tooltip: 'পুরো Story Mode প্রিভিউ করুন',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StoryPlayerScreen()),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white.withOpacity(0.04),
            child: Text(
              'মোট $totalMoments টি মোমেন্ট • $chaptersWithContent/${chapters.length} টি chapter এ কনটেন্ট আছে',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                final Chapter chapter = chapters[index];
                final momentCount = _storage.getMomentsForChapter(chapter.id).length;
                return ListTile(
                  leading: Text(chapter.iconEmoji, style: const TextStyle(fontSize: 22)),
                  title: Text(chapter.title),
                  subtitle: Text(
                    momentCount == 0 ? 'এখনো খালি' : '$momentCount টি মোমেন্ট',
                    style: TextStyle(color: momentCount == 0 ? Colors.orangeAccent.withOpacity(0.8) : null),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ChapterMomentsScreen(chapter: chapter)),
                    );
                    setState(() {}); // refresh moment counts after returning
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
