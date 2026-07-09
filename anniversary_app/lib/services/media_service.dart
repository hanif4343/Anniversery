import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Photos picked from the gallery live in a temporary cache location that
/// the OS can clear at any time. This service copies every picked file
/// into the app's own permanent folder (`app_documents/moments/<id>/...`)
/// so nothing disappears later. Everything stays on the phone — no upload.
class MediaService {
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();

  Future<Directory> _momentFolder(String momentId) async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}/moments/$momentId');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> _copyIntoMomentFolder(String momentId, File source, String fileName) async {
    final dir = await _momentFolder(momentId);
    final destPath = '${dir.path}/$fileName';
    final copied = await source.copy(destPath);
    return copied.path;
  }

  /// Pick one or more photos from the gallery. Returns permanent local paths.
  Future<List<String>> pickPhotos(String momentId) async {
    final List<XFile> picked = await _imagePicker.pickMultiImage(imageQuality: 85);
    final List<String> savedPaths = [];
    for (final xfile in picked) {
      final ext = xfile.path.split('.').last;
      final name = 'photo_${DateTime.now().millisecondsSinceEpoch}_${savedPaths.length}.$ext';
      final saved = await _copyIntoMomentFolder(momentId, File(xfile.path), name);
      savedPaths.add(saved);
    }
    return savedPaths;
  }

  /// Pick a single video from the gallery.
  Future<String?> pickVideo(String momentId) async {
    final XFile? picked = await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (picked == null) return null;
    final ext = picked.path.split('.').last;
    final name = 'video_${DateTime.now().millisecondsSinceEpoch}.$ext';
    return _copyIntoMomentFolder(momentId, File(picked.path), name);
  }

  /// Pick a music/audio file (e.g. mp3) from device storage.
  Future<String?> pickMusic(String momentId) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result == null || result.files.single.path == null) return null;
    final source = File(result.files.single.path!);
    final ext = result.files.single.name.split('.').last;
    final name = 'music_${DateTime.now().millisecondsSinceEpoch}.$ext';
    return _copyIntoMomentFolder(momentId, source, name);
  }

  Future<Directory> _chapterFolder(String chapterId) async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}/chapters/$chapterId');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Pick a background music file for an entire Chapter (plays on loop
  /// while the user is anywhere inside that chapter in Story Mode).
  Future<String?> pickChapterMusic(String chapterId) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result == null || result.files.single.path == null) return null;
    final source = File(result.files.single.path!);
    final ext = result.files.single.name.split('.').last;
    final name = 'chapter_music_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final dir = await _chapterFolder(chapterId);
    final destPath = '${dir.path}/$name';
    final copied = await source.copy(destPath);
    return copied.path;
  }

  /// Voice recording: call [startRecording] then [stopRecording] later.
  Future<void> startRecording(String momentId) async {
    if (await _recorder.hasPermission()) {
      final dir = await _momentFolder(momentId);
      final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(), path: path);
    }
  }

  /// Returns the saved voice file path, or null if nothing was recorded.
  Future<String?> stopRecording() async {
    return _recorder.stop();
  }

  Future<bool> isRecording() => _recorder.isRecording();
}
