import 'dart:io';
import 'package:flutter/material.dart';
import '../models/moment.dart';
import '../services/storage_service.dart';
import '../services/media_service.dart';

class MomentEditorScreen extends StatefulWidget {
  final String chapterId;
  final Moment? existingMoment;

  const MomentEditorScreen({super.key, required this.chapterId, this.existingMoment});

  @override
  State<MomentEditorScreen> createState() => _MomentEditorScreenState();
}

class _MomentEditorScreenState extends State<MomentEditorScreen> {
  final _storage = StorageService();
  final _media = MediaService();

  late String _momentId;
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _descController = TextEditingController();

  List<String> _photoPaths = [];
  String? _videoPath;
  String? _musicPath;
  String? _voicePath;
  String _entranceEffect = 'fade';
  String _photoLayout = 'single';
  bool _isAiIllustration = false;

  bool _isRecording = false;
  bool _isSaving = false;

  bool get _isEditing => widget.existingMoment != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingMoment;
    if (existing != null) {
      _momentId = existing.id;
      _titleController.text = existing.title;
      _dateController.text = existing.dateLabel ?? '';
      _descController.text = existing.description ?? '';
      _photoPaths = List.from(existing.photoPaths);
      _videoPath = existing.videoPath;
      _musicPath = existing.musicOverridePath;
      _voicePath = existing.voiceNotePath;
      _entranceEffect = existing.entranceEffect;
      _photoLayout = existing.photoLayout;
      _isAiIllustration = existing.isAiIllustration;
    } else {
      // Stable ID for this moment, used from the start so media files can
      // be saved into a folder named after it even before the first Save.
      _momentId = 'moment_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  Future<void> _pickPhotos() async {
    final paths = await _media.pickPhotos(_momentId);
    setState(() => _photoPaths.addAll(paths));
  }

  Future<void> _pickVideo() async {
    final path = await _media.pickVideo(_momentId);
    if (path != null) setState(() => _videoPath = path);
  }

  Future<void> _pickMusic() async {
    final path = await _media.pickMusic(_momentId);
    if (path != null) setState(() => _musicPath = path);
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _media.stopRecording();
      setState(() {
        _isRecording = false;
        if (path != null) _voicePath = path;
      });
    } else {
      await _media.startRecording(_momentId);
      setState(() => _isRecording = true);
    }
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('একটা টাইটেল দিন')),
      );
      return;
    }
    setState(() => _isSaving = true);

    final existingMoments = _storage.getMomentsForChapter(widget.chapterId);
    final order = widget.existingMoment?.order ?? existingMoments.length;

    final moment = Moment(
      id: _momentId,
      chapterId: widget.chapterId,
      order: order,
      dateLabel: _dateController.text.trim().isEmpty ? null : _dateController.text.trim(),
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      photoPaths: _photoPaths,
      videoPath: _videoPath,
      musicOverridePath: _musicPath,
      voiceNotePath: _voicePath,
      entranceEffect: _entranceEffect,
      photoLayout: _photoLayout,
      isAiIllustration: _isAiIllustration,
    );

    await _storage.saveMoment(moment);
    setState(() => _isSaving = false);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('মুছে ফেলবেন?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('না')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('হ্যাঁ')),
        ],
      ),
    );
    if (confirm == true) {
      await _storage.deleteMoment(_momentId);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'মোমেন্ট এডিট করুন' : 'নতুন মোমেন্ট'),
        actions: [
          if (_isEditing)
            IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'টাইটেল (যেমন: "প্রথম দেখা")'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dateController,
            decoration: const InputDecoration(labelText: 'তারিখ (যেমন: "১ অক্টোবর ২০১৭") — অপশনাল'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'গল্প / ক্যাপশন',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),

          // ---------- Photos ----------
          _SectionLabel('ছবি (${_photoPaths.length} টা)'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < _photoPaths.length; i++)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(_photoPaths[i]), width: 80, height: 80, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: IconButton(
                        icon: const Icon(Icons.cancel, size: 18, color: Colors.redAccent),
                        onPressed: () => setState(() => _photoPaths.removeAt(i)),
                      ),
                    ),
                  ],
                ),
              InkWell(
                onTap: _pickPhotos,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add_a_photo_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _isAiIllustration,
            title: const Text('এইগুলো AI-generated ইলাস্ট্রেশন (আসল ছবি না)'),
            onChanged: (v) => setState(() => _isAiIllustration = v ?? false),
          ),

          const SizedBox(height: 12),
          _SectionLabel('ছবির লেআউট'),
          DropdownButton<String>(
            value: _photoLayout,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'single', child: Text('একটা বড় ছবি')),
              DropdownMenuItem(value: 'collage', child: Text('কোলাজ')),
              DropdownMenuItem(value: 'polaroid', child: Text('Polaroid স্টাইল')),
              DropdownMenuItem(value: 'stack', child: Text('স্ট্যাক')),
            ],
            onChanged: (v) => setState(() => _photoLayout = v ?? 'single'),
          ),

          const SizedBox(height: 20),
          // ---------- Video ----------
          _SectionLabel('ভিডিও'),
          Row(
            children: [
              Expanded(
                child: Text(
                  _videoPath == null ? 'কোনো ভিডিও যোগ করা হয়নি' : _videoPath!.split('/').last,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(onPressed: _pickVideo, child: const Text('বাছাই করুন')),
              if (_videoPath != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _videoPath = null),
                ),
            ],
          ),

          const SizedBox(height: 12),
          // ---------- Music ----------
          _SectionLabel('এই মোমেন্টের বিশেষ মিউজিক (অপশনাল)'),
          Row(
            children: [
              Expanded(
                child: Text(
                  _musicPath == null ? 'Chapter এর ডিফল্ট মিউজিক ব্যবহার হবে' : _musicPath!.split('/').last,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(onPressed: _pickMusic, child: const Text('বাছাই করুন')),
              if (_musicPath != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _musicPath = null),
                ),
            ],
          ),

          const SizedBox(height: 12),
          // ---------- Voice ----------
          _SectionLabel('নিজের কণ্ঠে ভয়েস নোট (অপশনাল)'),
          Row(
            children: [
              IconButton(
                icon: Icon(_isRecording ? Icons.stop_circle : Icons.mic, color: _isRecording ? Colors.redAccent : null),
                onPressed: _toggleRecording,
              ),
              Expanded(
                child: Text(
                  _isRecording
                      ? 'রেকর্ড হচ্ছে... থামাতে বোতাম চাপুন'
                      : (_voicePath == null ? 'কোনো ভয়েস রেকর্ড করা হয়নি' : 'ভয়েস রেকর্ড করা আছে ✓'),
                ),
              ),
              if (_voicePath != null && !_isRecording)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _voicePath = null),
                ),
            ],
          ),

          const SizedBox(height: 20),
          _SectionLabel('এন্ট্রি ইফেক্ট (এই দৃশ্যটা কীভাবে শুরু হবে)'),
          DropdownButton<String>(
            value: _entranceEffect,
            isExpanded: true,
            items: effectLibraryKeys
                .map((key) => DropdownMenuItem(value: key, child: Text(_effectLabel(key))))
                .toList(),
            onChanged: (v) => setState(() => _entranceEffect = v ?? 'fade'),
          ),

          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('সেভ করুন'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _effectLabel(String key) {
    const labels = {
      'fade': 'সাধারণ Fade',
      'zoom': 'Zoom In',
      'envelope_letter': '💌 খাম খুলে চিঠি বের হওয়া',
      'ring_slide': '💍 আংটি স্লাইড',
      'rose_petal_fall': '🌹 গোলাপ পাপড়ি ঝরা',
      'heart_float': '❤️ হার্ট ভাসা',
      'page_turn': '📖 পাতা উল্টানো',
      'camera_flash': '📸 ক্যামেরা ফ্ল্যাশ',
      'golden_dust': '✨ Golden Dust',
      'fireworks': '🎆 আতশবাজি',
    };
    return labels[key] ?? key;
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white70)),
    );
  }
}
