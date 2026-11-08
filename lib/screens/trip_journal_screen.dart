import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripJournalScreen extends StatefulWidget {
  const TripJournalScreen({super.key});

  @override
  State<TripJournalScreen> createState() => _TripJournalScreenState();
}

class _TripJournalScreenState extends State<TripJournalScreen> {
  static const String _prefsKey = 'trip_journal_stories_v2';
  final ImagePicker _picker = ImagePicker();

  bool _isTimelineMode = true;
  bool _isLoading = true;
  List<_JournalStory> _stories = [];

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];

    if (raw.isEmpty) {
      _stories = _seedStories();
      await _saveStories();
    } else {
      _stories = raw
          .map(
            (row) =>
                _JournalStory.fromJson(jsonDecode(row) as Map<String, dynamic>),
          )
          .toList();
    }

    _stories.sort((a, b) => b.date.compareTo(a.date));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _saveStories() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _stories.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_prefsKey, encoded);
  }

  List<_JournalStory> _seedStories() {
    return [
      _JournalStory(
        id: 'seed_sigiriya',
        title: 'Sunrise at Sigiriya',
        description:
            'Started the climb before sunrise and reached the summit just as the sky turned orange. The wind at the top and the view over the forest were unforgettable.',
        date: DateTime.now().subtract(const Duration(days: 10)),
        latitude: 7.9570,
        longitude: 80.7603,
        imageOne: 'asset:assets/images/sigiriya.jpg',
        imageTwo: 'asset:assets/home cover.png',
      ),
      _JournalStory(
        id: 'seed_kandy',
        title: 'Evening in Kandy',
        description:
            'Walked around Kandy Lake and visited the temple area at sunset. The city lights reflecting on the water made the whole place feel peaceful.',
        date: DateTime.now().subtract(const Duration(days: 6)),
        latitude: 7.2936,
        longitude: 80.6413,
        imageOne: 'asset:assets/central province/temple of tooth.jpg',
        imageTwo: 'asset:assets/home cover.png',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0B111A);
    const card = Color(0xFF121B2A);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFFEAF1FF),
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Trip Journal',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEAF1FF),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _openCreateStorySheet,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2BC0E4), Color(0xFF8A7CFF)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _toggleItem(
                              active: _isTimelineMode,
                              icon: Icons.timeline,
                              label: 'Timeline',
                              onTap: () =>
                                  setState(() => _isTimelineMode = true),
                            ),
                          ),
                          Expanded(
                            child: _toggleItem(
                              active: !_isTimelineMode,
                              icon: Icons.auto_stories,
                              label: 'Story',
                              onTap: () =>
                                  setState(() => _isTimelineMode = false),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _stories.isEmpty
                        ? const Center(
                            child: Text(
                              'No stories yet. Tap + to create your first one.',
                              style: TextStyle(color: Color(0xFFB8C1D1)),
                            ),
                          )
                        : (_isTimelineMode
                              ? _buildTimeline()
                              : _buildStoryPager()),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _toggleItem({
    required bool active,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1E2A40) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? const Color(0xFF2BC0E4) : const Color(0xFF9AA8BF),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: active
                    ? const Color(0xFFEAF1FF)
                    : const Color(0xFF9AA8BF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _stories.length,
      itemBuilder: (context, index) {
        final story = _stories[index];
        final isLast = index == _stories.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2BC0E4),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 190,
                    color: const Color(0xFF2BC0E4).withValues(alpha: 0.35),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(child: _storyCard(story)),
          ],
        );
      },
    );
  }

  Widget _buildStoryPager() {
    return PageView.builder(
      itemCount: _stories.length,
      controller: PageController(viewportFraction: 0.9),
      itemBuilder: (context, index) {
        final story = _stories[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: _storyCard(story, compact: false),
        );
      },
    );
  }

  Widget _storyCard(_JournalStory story, {bool compact = true}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF121B2A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                SizedBox(
                  height: compact ? 165 : 220,
                  width: double.infinity,
                  child: _storyImage(story.imageOne, fit: BoxFit.cover),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _storyImage(story.imageTwo, fit: BoxFit.cover),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        story.title,
                        style: const TextStyle(
                          color: Color(0xFFEAF1FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF263751),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        _fmtDate(story.date),
                        style: const TextStyle(
                          color: Color(0xFFB8C1D1),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Color(0xFFB8C1D1),
                        size: 20,
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _openCreateStorySheet(existing: story);
                        } else if (value == 'delete') {
                          _deleteStory(story.id);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_outlined, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline, size: 18),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  story.description,
                  maxLines: compact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFC7D3E6), height: 1.5),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      color: Color(0xFF2BC0E4),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${story.latitude.toStringAsFixed(4)}, ${story.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(
                        color: Color(0xFF9FB0C8),
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _openFullStory(story),
                      child: const Text('See more'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _storyImage(String source, {BoxFit fit = BoxFit.cover}) {
    if (source.startsWith('asset:')) {
      return Image.asset(
        source.replaceFirst('asset:', ''),
        fit: fit,
        errorBuilder: (_, __, ___) => _imageFallback(),
      );
    }
    if (source.startsWith('b64:')) {
      try {
        final bytes = base64Decode(source.replaceFirst('b64:', ''));
        return Image.memory(bytes, fit: fit);
      } catch (_) {
        return _imageFallback();
      }
    }
    return _imageFallback();
  }

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFF1E2A40),
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported, color: Color(0xFF9FB0C8)),
    );
  }

  void _openFullStory(_JournalStory story) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _StoryDetailPage(story: story)),
    );
  }

  String _fmtDate(DateTime date) {
    final m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${m[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<String?> _pickImageBase64() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 65,
      maxWidth: 1200,
    );
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    return 'b64:${base64Encode(bytes)}';
  }

  Future<void> _deleteStory(String storyId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete story?'),
        content: const Text('This story will be removed from your journal.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    _stories.removeWhere((s) => s.id == storyId);
    await _saveStories();
    if (!mounted) return;
    setState(() {});
  }

  void _openCreateStorySheet({_JournalStory? existing}) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final descController = TextEditingController(
      text: existing?.description ?? '',
    );
    DateTime selectedDate = existing?.date ?? DateTime.now();
    LatLng selectedLocation = existing == null
        ? const LatLng(7.8731, 80.7718)
        : LatLng(existing.latitude, existing.longitude);
    String? imageOne = existing?.imageOne;
    String? imageTwo = existing?.imageTwo;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.90,
              decoration: const BoxDecoration(
                color: Color(0xFF0F1625),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      const Text(
                        'Create Your Story',
                        style: TextStyle(
                          color: Color(0xFFEAF1FF),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: titleController,
                        style: const TextStyle(color: Color(0xFFEAF1FF)),
                        decoration: _inputDeco('Story title / place name'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: descController,
                        maxLines: 4,
                        style: const TextStyle(color: Color(0xFFEAF1FF)),
                        decoration: _inputDeco('Write your experience...'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await _pickImageBase64();
                                if (picked == null) return;
                                setSheetState(() => imageOne = picked);
                              },
                              icon: const Icon(Icons.photo_outlined),
                              label: Text(
                                imageOne == null ? 'Image 1' : 'Image 1 added',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final picked = await _pickImageBase64();
                                if (picked == null) return;
                                setSheetState(() => imageTwo = picked);
                              },
                              icon: const Icon(Icons.photo_library_outlined),
                              label: Text(
                                imageTwo == null ? 'Image 2' : 'Image 2 added',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF2BC0E4),
                        ),
                        title: const Text(
                          'Story date',
                          style: TextStyle(color: Color(0xFFEAF1FF)),
                        ),
                        subtitle: Text(
                          _fmtDate(selectedDate),
                          style: const TextStyle(color: Color(0xFFB8C1D1)),
                        ),
                        trailing: TextButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2015),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (picked == null) return;
                            setSheetState(() => selectedDate = picked);
                          },
                          child: const Text('Change'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap map to mark exact place',
                        style: TextStyle(
                          color: Color(0xFFEAF1FF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: selectedLocation,
                            initialZoom: 7,
                            onTap: (_, point) =>
                                setSheetState(() => selectedLocation = point),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName:
                                  'com.smartcity.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: selectedLocation,
                                  width: 38,
                                  height: 38,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF8A7CFF),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.place,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          final title = titleController.text.trim();
                          final desc = descController.text.trim();
                          if (title.isEmpty ||
                              desc.isEmpty ||
                              imageOne == null ||
                              imageTwo == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Add title, note, and 2 images.'),
                              ),
                            );
                            return;
                          }

                          final story = _JournalStory(
                            id:
                                existing?.id ??
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            title: title,
                            description: desc,
                            date: selectedDate,
                            latitude: selectedLocation.latitude,
                            longitude: selectedLocation.longitude,
                            imageOne: imageOne!,
                            imageTwo: imageTwo!,
                          );

                          if (existing == null) {
                            _stories.insert(0, story);
                          } else {
                            final index = _stories.indexWhere(
                              (s) => s.id == existing.id,
                            );
                            if (index >= 0) {
                              _stories[index] = story;
                            } else {
                              _stories.insert(0, story);
                            }
                          }
                          _stories.sort((a, b) => b.date.compareTo(a.date));
                          await _saveStories();
                          if (!mounted) return;
                          if (!context.mounted) return;
                          setState(() {});
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2BC0E4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          existing == null ? 'Save Story' : 'Update Story',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF8EA0BC)),
      filled: true,
      fillColor: const Color(0xFF121B2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF2BC0E4)),
      ),
    );
  }
}

class _StoryDetailPage extends StatelessWidget {
  final _JournalStory story;

  const _StoryDetailPage({required this.story});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B111A),
      appBar: AppBar(
        title: const Text('Full Story'),
        backgroundColor: const Color(0xFF121B2A),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            story.title,
            style: const TextStyle(
              color: Color(0xFFEAF1FF),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${story.date.year}-${story.date.month.toString().padLeft(2, '0')}-${story.date.day.toString().padLeft(2, '0')}',
            style: const TextStyle(color: Color(0xFFB8C1D1)),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 16 / 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _StoryImageRenderer(source: story.imageOne),
            ),
          ),
          const SizedBox(height: 10),
          AspectRatio(
            aspectRatio: 16 / 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _StoryImageRenderer(source: story.imageTwo),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            story.description,
            style: const TextStyle(
              color: Color(0xFFC7D3E6),
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            clipBehavior: Clip.antiAlias,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(story.latitude, story.longitude),
                initialZoom: 11,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.smartcity.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(story.latitude, story.longitude),
                      width: 36,
                      height: 36,
                      child: const Icon(
                        Icons.place,
                        color: Color(0xFF8A7CFF),
                        size: 34,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryImageRenderer extends StatelessWidget {
  final String source;

  const _StoryImageRenderer({required this.source});

  @override
  Widget build(BuildContext context) {
    if (source.startsWith('asset:')) {
      return Image.asset(
        source.replaceFirst('asset:', ''),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    if (source.startsWith('b64:')) {
      try {
        final Uint8List bytes = base64Decode(source.replaceFirst('b64:', ''));
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        return _fallback();
      }
    }

    return _fallback();
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFF1E2A40),
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported, color: Color(0xFF9FB0C8)),
    );
  }
}

class _JournalStory {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final double latitude;
  final double longitude;
  final String imageOne;
  final String imageTwo;

  const _JournalStory({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.imageOne,
    required this.imageTwo,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'date': date.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'imageOne': imageOne,
    'imageTwo': imageTwo,
  };

  factory _JournalStory.fromJson(Map<String, dynamic> json) {
    return _JournalStory(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      date:
          DateTime.tryParse((json['date'] ?? '').toString()) ?? DateTime.now(),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 7.8731,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 80.7718,
      imageOne: (json['imageOne'] ?? '').toString(),
      imageTwo: (json['imageTwo'] ?? '').toString(),
    );
  }
}
