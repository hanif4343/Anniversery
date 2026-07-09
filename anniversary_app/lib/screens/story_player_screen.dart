import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/moment.dart';
import '../services/storage_service.dart';
import '../services/audio_controller.dart';
import '../widgets/photo_layout.dart';
import '../widgets/video_moment_player.dart';
import '../widgets/background_themes.dart';
import '../widgets/effects/entrance_effect.dart';

/// Flattens every chapter's moments into one ordered sequence, then plays
/// through them as a swipeable, fading cinematic experience. This is the
/// screen your wife actually spends her time in.
class StoryPlayerScreen extends StatefulWidget {
  final String? startChapterId;
  const StoryPlayerScreen({super.key, this.startChapterId});

  @override
  State<StoryPlayerScreen> createState() => _StoryPlayerScreenState();
}

class _SceneItem {
  final Chapter chapter;
  final Moment moment;
  _SceneItem(this.chapter, this.moment);
}

class _StoryPlayerScreenState extends State<StoryPlayerScreen> {
  final _storage = StorageService();
  final _audio = AudioController();
  late final List<_SceneItem> _scenes;
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _scenes = _buildSceneList();
    int initialPage = 0;
    if (widget.startChapterId != null) {
      final idx = _scenes.indexWhere((s) => s.chapter.id == widget.startChapterId);
      if (idx != -1) initialPage = idx;
    }
    _currentIndex = initialPage;
    _pageController = PageController(initialPage: initialPage);
    if (_scenes.isNotEmpty) {
      // Start music for the very first scene.
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateMusicForCurrentScene());
    }
  }

  List<_SceneItem> _buildSceneList() {
    final chapters = _storage.getAllChapters();
    final List<_SceneItem> scenes = [];
    for (final chapter in chapters) {
      final moments = _storage.getMomentsForChapter(chapter.id);
      for (final moment in moments) {
        scenes.add(_SceneItem(chapter, moment));
      }
    }
    return scenes;
  }

  void _updateMusicForCurrentScene() {
    final scene = _scenes[_currentIndex];
    // A moment's own music (if set) takes priority; otherwise fall back
    // to the chapter's background music.
    final path = scene.moment.musicOverridePath ?? scene.chapter.chapterMusicPath;
    _audio.playBackgroundMusic(path);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_scenes.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0620),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'এখনো কোনো মোমেন্ট যোগ করা হয়নি।\nCreator Mode থেকে যোগ করুন।',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final currentScene = _scenes[_currentIndex];

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _scenes.length,
            onPageChanged: (i) {
              setState(() => _currentIndex = i);
              _updateMusicForCurrentScene();
            },
            itemBuilder: (context, index) => _SceneView(
              scene: _scenes[index],
              audio: _audio,
            ),
          ),
          // Top progress + chapter label
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            children: List.generate(_scenes.length, (i) {
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: i <= _currentIndex ? Colors.white : Colors.white24,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            _audio.muted ? Icons.volume_off : Icons.volume_up,
                            color: Colors.white70,
                            size: 20,
                          ),
                          onPressed: () async {
                            await _audio.toggleMute();
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentScene.chapter.title,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One full-screen scene: background gradient (by chapter), photo/video,
/// title, date, description, and a voice-note play button if one was
/// recorded — wrapped with whichever entrance effect was chosen in
/// Creator Mode.
class _SceneView extends StatelessWidget {
  final _SceneItem scene;
  final AudioController audio;
  const _SceneView({required this.scene, required this.audio});

  @override
  Widget build(BuildContext context) {
    final moment = scene.moment;
    final chapter = scene.chapter;
    final colors = gradientFor(chapter.backgroundKey);

    final content = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 70, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (moment.videoPath != null)
            VideoMomentPlayer(videoPath: moment.videoPath!)
          else
            PhotoLayout(photoPaths: moment.photoPaths, layout: moment.photoLayout),
          const SizedBox(height: 20),
          if (moment.dateLabel != null)
            Text(
              moment.dateLabel!,
              style: const TextStyle(color: Colors.white54, fontSize: 13, letterSpacing: 1),
            ),
          const SizedBox(height: 6),
          Text(
            moment.title,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500),
          ),
          if (moment.description != null) ...[
            const SizedBox(height: 12),
            Text(
              moment.description!,
              style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
            ),
          ],
          if (moment.voiceNotePath != null) ...[
            const SizedBox(height: 18),
            _VoiceNoteButton(path: moment.voiceNotePath!, audio: audio),
          ],
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: SafeArea(
        // Key forces a fresh animation state each time a different moment scrolls in.
        child: EntranceEffect(
          key: ValueKey(moment.id),
          effectKey: moment.entranceEffect,
          child: content,
        ),
      ),
    );
  }
}

class _VoiceNoteButton extends StatefulWidget {
  final String path;
  final AudioController audio;
  const _VoiceNoteButton({required this.path, required this.audio});

  @override
  State<_VoiceNoteButton> createState() => _VoiceNoteButtonState();
}

class _VoiceNoteButtonState extends State<_VoiceNoteButton> {
  bool _playing = false;

  Future<void> _play() async {
    setState(() => _playing = true);
    await widget.audio.playVoiceNote(widget.path);
    // Simple heuristic: re-enable the button after a moment; the icon is
    // just a visual cue, actual audio stops itself when finished.
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _playing = false);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _play,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_playing ? Icons.graphic_eq : Icons.play_arrow, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            const Text('আমার কণ্ঠে শুনুন', style: TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
