import 'package:flutter/material.dart';
import 'dart:io';
import '../models/chapter.dart';
import '../models/moment.dart';
import '../services/storage_service.dart';
import '../services/media_service.dart';
import 'moment_editor_screen.dart';
import 'story_player_screen.dart';

class ChapterMomentsScreen extends StatefulWidget {
  final Chapter chapter;
  const ChapterMomentsScreen({super.key, required this.chapter});

  @override
  State<ChapterMomentsScreen> createState() => _ChapterMomentsScreenState();
}

class _ChapterMomentsScreenState extends State<ChapterMomentsScreen> {
  final _storage = StorageService();
  final _media = MediaService();

  void _refresh() => setState(() {});

  void _openEditor({Moment? existing}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MomentEditorScreen(
          chapterId: widget.chapter.id,
          existingMoment: existing,
        ),
      ),
    );
    _refresh(); // reload list after coming back, in case something changed
  }

  Future<void> _pickChapterMusic() async {
    final path = await _media.pickChapterMusic(widget.chapter.id);
    if (path != null) {
      widget.chapter.chapterMusicPath = path;
      await _storage.saveChapter(widget.chapter);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('এই chapter এর ব্যাকগ্রাউন্ড মিউজিক সেট হয়েছে')),
        );
      }
    }
  }

  Future<void> _clearChapterMusic() async {
    widget.chapter.chapterMusicPath = null;
    await _storage.saveChapter(widget.chapter);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final moments = _storage.getMomentsForChapter(widget.chapter.id);
    final hasMusic = widget.chapter.chapterMusicPath != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapter.title),
        actions: [
          if (moments.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.play_circle_outline),
              tooltip: 'এই chapter টা Story Mode এ প্রিভিউ করুন',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => StoryPlayerScreen(startChapterId: widget.chapter.id),
                  ),
                );
              },
            ),
          IconButton(
            icon: Icon(hasMusic ? Icons.music_note : Icons.music_off, color: hasMusic ? Colors.pinkAccent : null),
            tooltip: hasMusic ? 'Chapter মিউজিক পরিবর্তন/মুছুন' : 'Chapter এর ব্যাকগ্রাউন্ড মিউজিক সেট করুন',
            onPressed: () {
              if (hasMusic) {
                showModalBottomSheet(
                  context: context,
                  builder: (ctx) => SafeArea(
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.swap_horiz),
                          title: const Text('মিউজিক পরিবর্তন করুন'),
                          onTap: () {
                            Navigator.pop(ctx);
                            _pickChapterMusic();
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete_outline),
                          title: const Text('মিউজিক মুছে ফেলুন'),
                          onTap: () {
                            Navigator.pop(ctx);
                            _clearChapterMusic();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                _pickChapterMusic();
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('নতুন মোমেন্ট'),
      ),
      body: moments.isEmpty
          ? const Center(child: Text('এখনো কোনো মোমেন্ট যোগ হয়নি — নিচের বাটনে চাপুন'))
          : ReorderableListView.builder(
              itemCount: moments.length,
              onReorder: (oldIndex, newIndex) async {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = moments.removeAt(oldIndex);
                moments.insert(newIndex, item);
                for (int i = 0; i < moments.length; i++) {
                  moments[i].order = i;
                  await _storage.saveMoment(moments[i]);
                }
                _refresh();
              },
              itemBuilder: (context, index) {
                final m = moments[index];
                return Dismissible(
                  key: ValueKey(m.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('মুছে ফেলবেন?'),
                        content: Text('"${m.title}" মোমেন্টটা মুছে যাবে।'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('না')),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('হ্যাঁ, মুছে দাও')),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) async {
                    await _storage.deleteMoment(m.id);
                    _refresh();
                  },
                  child: ListTile(
                    leading: m.photoPaths.isNotEmpty
                        ? CircleAvatar(backgroundImage: FileImage(File(m.photoPaths.first)))
                        : const CircleAvatar(child: Icon(Icons.image_not_supported, size: 18)),
                    title: Text(m.title),
                    subtitle: Text(m.dateLabel ?? ''),
                    onTap: () => _openEditor(existing: m),
                  ),
                );
              },
            ),
    );
  }
}
