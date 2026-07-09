import 'package:audioplayers/audioplayers.dart';

/// Manages all audio in Story Mode. Two independent players:
///  - [_musicPlayer]: chapter background music / moment music override,
///    loops continuously while a chapter/moment is on screen.
///  - [_voicePlayer]: plays your recorded voice notes on demand (one-shot),
///    ducking the background music down while it talks.
class AudioController {
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _voicePlayer = AudioPlayer();

  String? _currentMusicPath;
  bool muted = false;

  AudioController() {
    _musicPlayer.setReleaseMode(ReleaseMode.loop);
    _voicePlayer.setReleaseMode(ReleaseMode.release);
    _voicePlayer.onPlayerComplete.listen((_) => _restoreMusicVolume());
  }

  /// Switches background music only if the path actually changed
  /// (prevents restarting the same song every time a scene scrolls by).
  Future<void> playBackgroundMusic(String? path) async {
    if (muted || path == null) {
      if (path == null) {
        await _musicPlayer.stop();
        _currentMusicPath = null;
      }
      return;
    }
    if (_currentMusicPath == path) return; // already playing this one
    _currentMusicPath = path;
    await _musicPlayer.stop();
    await _musicPlayer.play(DeviceFileSource(path), volume: 0.55);
  }

  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
    _currentMusicPath = null;
  }

  Future<void> playVoiceNote(String path) async {
    if (muted) return;
    await _musicPlayer.setVolume(0.15); // duck the music down
    await _voicePlayer.stop();
    await _voicePlayer.play(DeviceFileSource(path), volume: 1.0);
  }

  Future<void> _restoreMusicVolume() async {
    await _musicPlayer.setVolume(0.55);
  }

  Future<void> toggleMute() async {
    muted = !muted;
    if (muted) {
      await _musicPlayer.setVolume(0);
      await _voicePlayer.setVolume(0);
    } else {
      await _musicPlayer.setVolume(0.55);
      await _voicePlayer.setVolume(1.0);
    }
  }

  void dispose() {
    _musicPlayer.dispose();
    _voicePlayer.dispose();
  }
}
