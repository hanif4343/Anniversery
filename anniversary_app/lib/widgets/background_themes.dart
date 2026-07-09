import 'package:flutter/material.dart';

/// Maps a Chapter's `backgroundKey` to a gradient. This is a placeholder —
/// Day 4 will replace these with real background images/animations, but
/// having distinct colors per chapter already makes Story Mode feel
/// intentional instead of flat, and nothing here needs to change when
/// we upgrade it later (same keys, richer rendering).
const Map<String, List<Color>> backgroundGradients = {
  'default': [Color(0xFF120821), Color(0xFF2A1245)],
  'rose_garden': [Color(0xFF3B0B2E), Color(0xFF6B1E42)],
  'moon_night': [Color(0xFF0A0F2C), Color(0xFF1B2A5E)],
  'sunset': [Color(0xFF3A1B3F), Color(0xFFB1546B)],
  'wedding_hall': [Color(0xFF2E1A0A), Color(0xFF6E3E1E)],
  'hospital': [Color(0xFF10202A), Color(0xFF1E3A4C)],
  'nursery': [Color(0xFF122A1E), Color(0xFF275038)],
  'golden': [Color(0xFF3A2A0A), Color(0xFF7A5A1E)],
};

List<Color> gradientFor(String key) => backgroundGradients[key] ?? backgroundGradients['default']!;
