import 'dart:io';
import 'package:flutter/material.dart';

/// Small helper: shows the image, or a graceful placeholder if the file
/// is missing (e.g. moved/deleted from the phone after being added).
/// Without this, a single missing file would crash the whole scene.
Widget _safeImage(String path, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  final file = File(path);
  return Image.file(
    file,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (context, error, stackTrace) => Container(
      width: width,
      height: height,
      color: Colors.white10,
      child: const Icon(Icons.broken_image_outlined, color: Colors.white24),
    ),
  );
}

/// Renders a moment's photos according to its chosen layout style.
/// Day 4 will add entrance animation on top of whatever this returns;
/// for now this focuses on getting the layout itself right.
class PhotoLayout extends StatelessWidget {
  final List<String> photoPaths;
  final String layout; // single | collage | polaroid | stack

  const PhotoLayout({super.key, required this.photoPaths, required this.layout});

  @override
  Widget build(BuildContext context) {
    if (photoPaths.isEmpty) {
      return Container(
        height: 260,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.photo_outlined, color: Colors.white24, size: 48),
        ),
      );
    }

    switch (layout) {
      case 'collage':
        return _CollageLayout(photoPaths: photoPaths);
      case 'polaroid':
        return _PolaroidLayout(photoPaths: photoPaths);
      case 'stack':
        return _StackLayout(photoPaths: photoPaths);
      case 'single':
      default:
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: _safeImage(photoPaths.first, height: 320, width: double.infinity),
        );
    }
  }
}

class _CollageLayout extends StatelessWidget {
  final List<String> photoPaths;
  const _CollageLayout({required this.photoPaths});

  @override
  Widget build(BuildContext context) {
    final shown = photoPaths.take(4).toList();
    return GridView.count(
      crossAxisCount: shown.length == 1 ? 1 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      children: shown
          .map((p) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _safeImage(p),
              ))
          .toList(),
    );
  }
}

class _PolaroidLayout extends StatelessWidget {
  final List<String> photoPaths;
  const _PolaroidLayout({required this.photoPaths});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Transform.rotate(
          angle: -0.04,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 8)),
              ],
            ),
            child: _safeImage(photoPaths.first, height: 220, width: 220),
          ),
        ),
      ),
    );
  }
}

class _StackLayout extends StatelessWidget {
  final List<String> photoPaths;
  const _StackLayout({required this.photoPaths});

  @override
  Widget build(BuildContext context) {
    final shown = photoPaths.take(3).toList().reversed.toList();
    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = 0; i < shown.length; i++)
            Transform.rotate(
              angle: (i - shown.length / 2) * 0.06,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _safeImage(shown[i], height: 260, width: 220),
              ),
            ),
        ],
      ),
    );
  }
}
