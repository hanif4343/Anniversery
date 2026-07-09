import 'package:hive_flutter/hive_flutter.dart';
import '../models/chapter.dart';
import '../models/moment.dart';

/// Central place for all local storage. Everything lives on the phone —
/// no internet, no cloud, no account needed. This matches your requirement
/// that photos/videos stay private and local.
class StorageService {
  static const String chapterBoxName = 'chapters';
  static const String momentBoxName = 'moments';
  static const String settingsBoxName = 'settings';

  late Box<Chapter> chapterBox;
  late Box<Moment> momentBox;
  late Box settingsBox;

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  /// Call this once in main() before runApp().
  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(ChapterAdapter());
    Hive.registerAdapter(MomentAdapter());

    chapterBox = await Hive.openBox<Chapter>(chapterBoxName);
    momentBox = await Hive.openBox<Moment>(momentBoxName);
    settingsBox = await Hive.openBox(settingsBoxName);

    // First-time setup: seed the default 18 chapters if nothing exists yet.
    if (chapterBox.isEmpty) {
      for (final chapter in defaultChapters()) {
        await chapterBox.put(chapter.id, chapter);
      }
    }
  }

  // ---------- Chapters ----------
  List<Chapter> getAllChapters() {
    final list = chapterBox.values.toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  Future<void> saveChapter(Chapter chapter) async {
    await chapterBox.put(chapter.id, chapter);
  }

  // ---------- Moments ----------
  List<Moment> getMomentsForChapter(String chapterId) {
    final list = momentBox.values
        .where((m) => m.chapterId == chapterId)
        .toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  List<Moment> getAllMomentsInStoryOrder() {
    final chapters = getAllChapters();
    final List<Moment> all = [];
    for (final ch in chapters) {
      all.addAll(getMomentsForChapter(ch.id));
    }
    return all;
  }

  Future<void> saveMoment(Moment moment) async {
    await momentBox.put(moment.id, moment);
  }

  Future<void> deleteMoment(String momentId) async {
    await momentBox.delete(momentId);
  }

  // ---------- Settings (e.g. creator PIN) ----------
  String? getCreatorPin() => settingsBox.get('creator_pin') as String?;

  Future<void> setCreatorPin(String pin) async {
    await settingsBox.put('creator_pin', pin);
  }

  bool get hasSetPin => getCreatorPin() != null;
}
