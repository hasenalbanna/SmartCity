import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/comment.dart';
import '../models/user_post.dart';
import '../services/location_service.dart';
import '../services/social_service.dart';

class CommunityFeedScreen extends StatelessWidget {
  const CommunityFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B111A),
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            _composer(context),
            Expanded(
              child: Consumer<SocialService>(
                builder: (context, socialService, _) {
                  final posts = socialService.getAlgorithmAlignedPosts();

                  if (posts.isEmpty) {
                    return const Center(
                      child: Text(
                        'No traveler uploads yet.\nBe the first to share a photo with location.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFFB8C1D1)),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return _PostCard(post: posts[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121B2A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFEAF1FF)),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Traveler Uploads',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEAF1FF),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            color: const Color(0xFF87CEEB),
            onPressed: () => _openCreatePost(context),
          ),
        ],
      ),
    );
  }

  Widget _composer(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121B2A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openCreatePost(context),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF87CEEB).withValues(alpha: 0.15),
              child: const Icon(Icons.person, color: Color(0xFF87CEEB)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A253A),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  'Upload image + location + caption',
                  style: const TextStyle(color: Color(0xFFB8C1D1)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCreatePost(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CreatePostSheet(),
    );
  }
}

class _PostCard extends StatelessWidget {
  final UserPost post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final social = context.watch<SocialService>();
    final isLiked = post.isLikedBy(social.currentUserId);
    final isSaved = social.isPostSaved(post.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF121B2A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(
                    0xFF87CEEB,
                  ).withValues(alpha: 0.15),
                  child: Text(
                    post.userName.isEmpty
                        ? '?'
                        : post.userName[0].toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEAF1FF),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEAF1FF),
                        ),
                      ),
                      Text(
                        post.placeName,
                        style: const TextStyle(
                          color: Color(0xFFB8C1D1),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  timeago.format(post.createdAt),
                  style: const TextStyle(color: Color(0xFF9AA8BF), fontSize: 11),
                ),
              ],
            ),
          ),
          if (post.photoUrls.isNotEmpty)
            AspectRatio(
              aspectRatio: 1,
              child: post.photoUrls.length == 1
                  ? Image.network(post.photoUrls.first, fit: BoxFit.cover)
                  : PageView.builder(
                      itemCount: post.photoUrls.length,
                      itemBuilder: (context, index) => Image.network(
                        post.photoUrls[index],
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => social.togglePostLike(post.id),
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : const Color(0xFFC7D3E6),
                        ),
                      ),
                      Text(
                        '${post.likesCount}',
                        style: const TextStyle(color: Color(0xFFC7D3E6)),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _openComments(context, post.id),
                        icon: const Icon(
                          Icons.chat_bubble_outline,
                          color: Color(0xFFC7D3E6),
                        ),
                      ),
                      Text(
                        '${post.commentsCount}',
                        style: const TextStyle(color: Color(0xFFC7D3E6)),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => Share.share(
                          'Check this traveler post at ${post.placeName}: ${post.caption ?? ''}',
                        ),
                        icon: const Icon(
                          Icons.share_outlined,
                          color: Color(0xFFC7D3E6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => social.toggleSavePost(post),
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved
                              ? const Color(0xFF87CEEB)
                              : const Color(0xFFC7D3E6),
                        ),
                      ),
                    ],
                  ),
                ),
                if ((post.caption ?? '').trim().isNotEmpty)
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${post.userName} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: post.caption!.trim(),
                          style: const TextStyle(color: Color(0xFFD9E3F3)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openComments(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PostCommentsSheet(postId: postId),
    );
  }
}

class _PostCommentsSheet extends StatefulWidget {
  final String postId;

  const _PostCommentsSheet({required this.postId});

  @override
  State<_PostCommentsSheet> createState() => _PostCommentsSheetState();
}

class _PostCommentsSheetState extends State<_PostCommentsSheet> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final social = context.read<SocialService>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF121B2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Comments',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFFEAF1FF),
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<List<Comment>>(
              stream: social.streamCommentsForPost(widget.postId),
              builder: (context, snapshot) {
                final comments = snapshot.data ?? [];
                if (comments.isEmpty) {
                  return const Center(
                    child: Text(
                      'No comments yet.',
                      style: TextStyle(color: Color(0xFFB8C1D1)),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final c = comments[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        c.userName,
                        style: const TextStyle(color: Color(0xFFEAF1FF)),
                      ),
                      subtitle: Text(
                        c.text,
                        style: const TextStyle(color: Color(0xFFC7D3E6)),
                      ),
                      trailing: Text(
                        timeago.format(c.createdAt),
                        style: const TextStyle(
                          color: Color(0xFF9AA8BF),
                          fontSize: 11,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              12,
              8,
              12,
              MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Add a comment',
                      filled: true,
                      fillColor: const Color(0xFF1A253A),
                      hintStyle: const TextStyle(color: Color(0xFF9AA8BF)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Color(0xFFEAF1FF)),
                    onSubmitted: (_) => _submit(context),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF87CEEB),
                  child: IconButton(
                    onPressed: () => _submit(context),
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await context.read<SocialService>().addPostComment(
      postId: widget.postId,
      text: text,
    );
  }
}

class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet();

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<Uint8List> _selectedPhotos = [];
  bool _isPosting = false;

  final List<Map<String, String>> _suggestedPlaces = const [
    {'id': 'sigiriya', 'name': 'Sigiriya Rock Fortress'},
    {'id': 'kandy', 'name': 'Kandy'},
    {'id': 'galle', 'name': 'Galle Fort'},
    {'id': 'ella', 'name': 'Ella'},
    {'id': 'mirissa', 'name': 'Mirissa Beach'},
  ];

  String? _selectedPlaceId;
  String? _selectedPlaceName;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await _picker.pickMultiImage();
    if (images.isEmpty) return;
    for (final x in images) {
      _selectedPhotos.add(await x.readAsBytes());
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _takePhoto() async {
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image == null) return;
    _selectedPhotos.add(await image.readAsBytes());
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _submitPost() async {
    if (_selectedPhotos.isEmpty || _selectedPlaceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one photo and location.')),
      );
      return;
    }

    setState(() => _isPosting = true);

    final socialService = context.read<SocialService>();
    final location = LocationService.getLocationForPlace(_selectedPlaceId!);

    final photoUrls = await socialService.uploadPostImages(_selectedPhotos);

    await socialService.addUserPost(
      placeId: _selectedPlaceId!,
      placeName: _selectedPlaceName!,
      caption: _captionController.text.trim(),
      photoUrls: photoUrls,
      latitude: location?['lat'],
      longitude: location?['lng'],
    );

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Post shared successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF121B2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Create Post',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEAF1FF),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isPosting ? null : _submitPost,
                  child: _isPosting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Share'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Photos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEAF1FF),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _actionTile(
                          Icons.add_photo_alternate,
                          'Gallery',
                          _pickImages,
                        ),
                        const SizedBox(width: 10),
                        _actionTile(Icons.camera_alt, 'Camera', _takePhoto),
                        const SizedBox(width: 10),
                        ..._selectedPhotos.asMap().entries.map((entry) {
                          final index = entry.key;
                          final bytes = entry.value;
                          return Stack(
                            children: [
                              Container(
                                width: 120,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: MemoryImage(bytes),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 14,
                                child: InkWell(
                                  onTap: () {
                                    setState(
                                      () => _selectedPhotos.removeAt(index),
                                    );
                                  },
                                  child: const CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEAF1FF),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestedPlaces.map((place) {
                      final isSelected = _selectedPlaceId == place['id'];
                      return ChoiceChip(
                        selected: isSelected,
                        label: Text(place['name']!),
                        onSelected: (_) {
                          setState(() {
                            _selectedPlaceId = place['id'];
                            _selectedPlaceName = place['name'];
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Caption',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEAF1FF),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _captionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Write a caption...',
                      filled: true,
                      fillColor: const Color(0xFF1A253A),
                      hintStyle: const TextStyle(color: Color(0xFF9AA8BF)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Color(0xFFEAF1FF)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: const Color(0xFF1A253A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: const Color(0xFF87CEEB)),
            const SizedBox(height: 6),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(color: Color(0xFFEAF1FF))),
          ],
        ),
      ),
    );
  }
}
