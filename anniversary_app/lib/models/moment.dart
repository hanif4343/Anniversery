import 'package:hive/hive.dart';

part 'moment.g.dart';

/// A Moment is ONE scene inside a Chapter.
/// Example: inside the "প্রপোজাল" chapter you might have moments like
/// "চিঠি লেখা", "আংটি কেনা", "সেই বিকেল" — each with its own photo/video,
/// short text, and entrance effect.
///
/// This is intentionally flexible: you can create as many Moments as you
/// want (30 or 150 — the app doesn't care, it's just a list).
@HiveType(typeId: 1)
class Moment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String chapterId; // links back to a Chapter

  @HiveField(2)
  int order; // position within the chapter

  @HiveField(3)
  String? dateLabel; // e.g. "১ অক্টোবর ২০১৭" (free text, not strict date)

  @HiveField(4)
  String title;

  @HiveField(5)
  String? description; // the emotional caption/story text

  @HiveField(6)
  List<String> photoPaths; // local file paths, can be multiple (collage)

  @HiveField(7)
  String? videoPath;

  @HiveField(8)
  String? musicOverridePath; // if this moment needs different music than chapter default

  @HiveField(9)
  String? voiceNotePath; // your recorded voice for this moment

  @HiveField(10)
  String entranceEffect; // key into the effect library, e.g. "envelope_letter", "ring_slide"

  @HiveField(11)
  String photoLayout; // "single" | "collage" | "polaroid" | "stack"

  @HiveField(12)
  bool isAiIllustration; // true if photoPaths point to an AI-generated image instead of a real photo

  Moment({
    required this.id,
    required this.chapterId,
    required this.order,
    this.dateLabel,
    required this.title,
    this.description,
    List<String>? photoPaths,
    this.videoPath,
    this.musicOverridePath,
    this.voiceNotePath,
    this.entranceEffect = 'fade',
    this.photoLayout = 'single',
    this.isAiIllustration = false,
  }) : photoPaths = photoPaths ?? [];
}

/// The effect library keys you can assign to a Moment's `entranceEffect`.
/// Day 4 of the plan will implement the actual animation widgets for these.
const List<String> effectLibraryKeys = [
  'fade',
  'zoom',
  'envelope_letter',   // envelope opens, letter slides out
  'ring_slide',        // ring animation sliding in and settling
  'rose_petal_fall',
  'heart_float',
  'page_turn',
  'camera_flash',
  'golden_dust',
  'fireworks',
];
