import 'package:hive/hive.dart';

part 'chapter.g.dart';

/// A Chapter is a big stage of the story — e.g. "প্রথম পরিচয়", "প্রপোজাল",
/// "বিয়ে", "Pregnancy", "Hospital", "Anniversary".
/// Each Chapter contains many Moments (see moment.dart).
@HiveType(typeId: 0)
class Chapter extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title; // e.g. "প্রপোজাল"

  @HiveField(2)
  String? subtitle; // small caption under the title

  @HiveField(3)
  int order; // controls the sequence in the journey

  @HiveField(4)
  String backgroundKey; // which background theme to use, e.g. "rose_garden"

  @HiveField(5)
  String? chapterMusicPath; // background music for this whole chapter

  @HiveField(6)
  String iconEmoji; // simple icon shown on the Road-of-Love map, e.g. "❤️"

  Chapter({
    required this.id,
    required this.title,
    this.subtitle,
    required this.order,
    this.backgroundKey = 'default',
    this.chapterMusicPath,
    this.iconEmoji = '❤️',
  });
}

/// The default 18 chapters based on the story you described.
/// You can add/remove/reorder these later from Creator Mode —
/// this list is just the starting point so you don't start from zero.
List<Chapter> defaultChapters() {
  final titles = <String>[
    'শুরু — ২০১৭',
    'প্রথম পরিচয়',
    'বন্ধুত্ব',
    'ভালো লাগা',
    'প্রপোজাল',
    'বাগদান',
    'বিয়ে',
    'প্রথম দিনগুলো',
    'খুনসুটি',
    'প্রথম ভ্রমণ',
    'সুসংবাদ — Pregnancy',
    'অপেক্ষার দিনগুলো',
    'হাসপাতাল',
    'আমাদের ছেলে',
    '৫ মাস বয়স',
    'প্রথম খাবার',
    'হাঁটতে শেখা',
    'Anniversary — ২০২৬',
  ];
  return List.generate(
    titles.length,
    (i) => Chapter(id: 'chapter_$i', title: titles[i], order: i),
  );
}
