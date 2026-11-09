import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/user_post.dart';
import '../services/social_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'premium_store_modal.dart';
import 'ui/ui.dart';

/// Instagram-style citizen feed section embedded on HomeScreen and ExploreScreen.
class InstagramFeedSection extends StatelessWidget {
  final int? maxPosts;
  final bool showStoriesRow;
  final bool preferGrid;

  const InstagramFeedSection({
    super.key,
    this.maxPosts,
    this.showStoriesRow = true,
    this.preferGrid = false,
  });

  static const List<_StoryUser> _stories = [
    _StoryUser(name: 'Your Story', isAdd: true),
    _StoryUser(name: 'Alex M.'),
    _StoryUser(name: 'Sarah K.'),
    _StoryUser(name: 'David R.'),
    _StoryUser(name: 'Falcon AI'),
    _StoryUser(name: 'Smart City'),
  ];

  @override
  Widget build(BuildContext context) {
    final social = context.watch<SocialService>();
    final allPosts = social.getAllPosts();
    final visiblePosts = maxPosts != null
        ? allPosts.take(maxPosts!).toList()
        : allPosts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with "+ Post" and "Open Feed" (Responsive Wrap for 360px)
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Citizen Community Feed',
                    style: AppTypography.title.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Live photos & updates posted by citizens worldwide',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    label: 'New Post',
                    icon: Icons.add_a_photo_outlined,
                    variant: AppButtonVariant.secondary,
                    onPressed: () => CreateInstagramPostModal.show(context),
                  ),
                  if (maxPosts != null) ...[
                    const SizedBox(width: AppSpace.xs),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FullInstagramFeedScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.dynamic_feed_rounded, size: 18),
                      label: const Text('Open Feed'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.md),

        // Instagram Stories Row
        if (showStoriesRow) ...[
          SizedBox(
            height: 86,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _stories.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpace.md),
              itemBuilder: (context, index) {
                final item = _stories[index];
                return GestureDetector(
                  onTap: () => CreateInstagramPostModal.show(context),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: item.isAdd
                                ? AppColors.outline(context)
                                : AppColors.primary(context),
                            width: 2.2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: item.isAdd
                              ? AppColors.surfaceMuted(context)
                              : AppColors.primary(context),
                          child: item.isAdd
                              ? Icon(
                                  Icons.add_rounded,
                                  color: AppColors.primary(context),
                                  size: 24,
                                )
                              : Text(
                                  item.name[0].toUpperCase(),
                                  style: AppTypography.subtitle.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        item.name,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpace.md),
        ],

        // Instagram Vertical Post Cards or Travel Grid with Map Route Paths
        if (preferGrid)
          _buildTravelGrid(context, visiblePosts)
        else
          ...visiblePosts.map(
            (post) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.lg),
              child: InstagramPostCard(post: post),
            ),
          ),
      ],
    );
  }

  Widget _buildTravelGrid(BuildContext context, List<UserPost> posts) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpace.sm,
            mainAxisSpacing: AppSpace.sm,
            childAspectRatio: 0.82,
          ),
          itemBuilder: (context, index) {
            final post = posts[index];
            return _TravelGridTile(post: post);
          },
        );
      },
    );
  }
}

class _TravelGridTile extends StatelessWidget {
  final UserPost post;

  const _TravelGridTile({required this.post});

  Widget _buildPostImage(String url) {
    if (url.startsWith('data:image')) {
      try {
        final commaIdx = url.indexOf(',');
        final bytes = base64Decode(url.substring(commaIdx + 1));
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {}
    }
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset('assets/cover.png', fit: BoxFit.cover),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          Image.asset('assets/cover.png', fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    final handle = post.userHandle.isNotEmpty
        ? (post.userHandle.startsWith('@') ? post.userHandle : '@${post.userHandle}')
        : '@${post.authorName.toLowerCase().replaceAll(' ', '_')}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FullInstagramFeedScreen(),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: AppRadius.mdBorder,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            _buildPostImage(post.imageUrl),

            // Top scrim gradient + Author Handle
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 9,
                      backgroundColor: Colors.white24,
                      backgroundImage: (post.authorAvatar.isNotEmpty &&
                              !post.authorAvatar.startsWith('data:'))
                          ? NetworkImage(post.authorAvatar)
                          : null,
                      child: post.authorAvatar.isEmpty
                          ? Text(
                              post.authorName.isNotEmpty
                                  ? post.authorName[0].toUpperCase()
                                  : 'U',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        handle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Middle: Map Route Path Badge (if route exists)
            if (post.routeSummary != null && post.routeSummary!.isNotEmpty)
              Positioned(
                left: 6,
                right: 6,
                bottom: 34,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: AppRadius.smBorder,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.route_rounded,
                        size: 11,
                        color: Colors.cyanAccent,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          post.routeSummary!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (post.distanceKm != null && post.distanceKm! > 0) ...[
                        const SizedBox(width: 2),
                        Text(
                          '${post.distanceKm!.round()}km',
                          style: AppTypography.caption.copyWith(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            // Bottom gradient + Location / Likes
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        post.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.favorite_rounded,
                          size: 11,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${post.likes}',
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryUser {
  final String name;
  final bool isAdd;
  const _StoryUser({required this.name, this.isAdd = false});
}

class InstagramPostCard extends StatelessWidget {
  final UserPost post;

  const InstagramPostCard({super.key, required this.post});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildPostPhoto(BuildContext context, String url) {
    if (url.startsWith('data:image')) {
      try {
        final commaIdx = url.indexOf(',');
        final bytes = base64Decode(url.substring(commaIdx + 1));
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {}
    }
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/cover.png',
          fit: BoxFit.cover,
        ),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/cover.png',
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final social = context.watch<SocialService>();
    final uid = social.currentUserId;
    final isLiked = post.likedBy.contains(uid);
    final isSaved = social.isPostSaved(post.id);
    final photoUrl = post.photoUrls.isNotEmpty
        ? post.photoUrls.first
        : 'assets/cover.png';

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Instagram Post Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.md,
              vertical: AppSpace.sm + 2,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primary(context),
                  child: Text(
                    post.userName.isNotEmpty
                        ? post.userName[0].toUpperCase()
                        : 'C',
                    style: AppTypography.bodyStrong.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.userHandle,
                            style: AppTypography.bodyStrong.copyWith(
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: AppSpace.xs),
                          Icon(
                            Icons.verified_rounded,
                            size: 15,
                            color: AppColors.primary(context),
                          ),
                        ],
                      ),
                      Text(
                        post.placeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _timeAgo(post.createdAt),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),

          // 2. Post Photo with Traveled Map Path Badge
          GestureDetector(
            onDoubleTap: () => social.togglePostLike(post.id),
            child: Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 290,
                  child: _buildPostPhoto(context, photoUrl),
                ),
                if (post.routeSummary != null && post.routeSummary!.isNotEmpty)
                  Positioned(
                    bottom: AppSpace.sm,
                    left: AppSpace.sm,
                    right: AppSpace.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.sm,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.82),
                        borderRadius: AppRadius.smBorder,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.alt_route_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '🗺️ ${post.routeSummary!}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (post.distanceKm != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary(context),
                                borderRadius: AppRadius.pillBorder,
                              ),
                              child: Text(
                                '${post.distanceKm} km',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // 3. Action Bar (Like, Comment, Boost, Save)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.sm,
              AppSpace.xs,
              AppSpace.sm,
              0,
            ),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Like post',
                  onPressed: () => social.togglePostLike(post.id),
                  icon: Icon(
                    isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isLiked
                        ? AppColors.danger(context)
                        : AppColors.textPrimary(context),
                    size: 26,
                  ),
                ),
                IconButton(
                  tooltip: 'Comments',
                  onPressed: () => _showCommentsSheet(context, post),
                  icon: Icon(
                    Icons.mode_comment_outlined,
                    color: AppColors.textPrimary(context),
                    size: 24,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => PremiumStoreModal.show(context),
                  icon: Icon(
                    Icons.rocket_launch_outlined,
                    size: 16,
                    color: AppColors.warning(context),
                  ),
                  label: const Text('Boost'),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Save post',
                  onPressed: () => social.toggleSavePost(post),
                  icon: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    color: AppColors.textPrimary(context),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // 4. Likes count, @username + Caption, Comments Link
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.md,
              0,
              AppSpace.md,
              AppSpace.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Liked by ${post.likesCount} citizens',
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                if (post.caption != null && post.caption!.isNotEmpty) ...[
                  const SizedBox(height: AppSpace.xs),
                  RichText(
                    text: TextSpan(
                      style: AppTypography.body.copyWith(
                        color: AppColors.textPrimary(context),
                      ),
                      children: [
                        TextSpan(
                          text: '@${post.userName} ',
                          style: AppTypography.bodyStrong.copyWith(
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        TextSpan(text: post.caption!),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpace.xs),
                GestureDetector(
                  onTap: () => _showCommentsSheet(context, post),
                  child: Text(
                    post.commentsCount > 0
                        ? 'View all ${post.commentsCount} comments'
                        : 'Add a comment...',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentsSheet(BuildContext context, UserPost post) {
    final commentCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final social = ctx.watch<SocialService>();
        final comments = social.getCommentsForPlace(post.id);
        return Padding(
          padding: EdgeInsets.only(
            top: AppSpace.lg,
            left: AppSpace.lg,
            right: AppSpace.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpace.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Comments (${post.commentsCount})',
                    style: AppTypography.title.copyWith(
                      color: AppColors.textPrimary(ctx),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.sm),
              if (comments.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
                  child: Text(
                    'Be the first citizen to comment on @${post.userName}\'s post!',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary(ctx),
                    ),
                  ),
                )
              else
                ...comments.take(5).map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.primary(ctx),
                              child: Text(
                                c.userName.isNotEmpty
                                    ? c.userName[0].toUpperCase()
                                    : 'C',
                                style: AppTypography.caption.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpace.sm),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: AppTypography.body.copyWith(
                                    color: AppColors.textPrimary(ctx),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '@${c.userName} ',
                                      style: AppTypography.bodyStrong.copyWith(
                                        color: AppColors.textPrimary(ctx),
                                      ),
                                    ),
                                    TextSpan(text: c.text),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              const SizedBox(height: AppSpace.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment...',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  AppButton(
                    label: 'Post',
                    onPressed: () {
                      if (commentCtrl.text.trim().isEmpty) return;
                      social.addPostComment(
                        postId: post.id,
                        text: commentCtrl.text.trim(),
                      );
                      commentCtrl.clear();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Modal allowing any user to create & publish an Instagram-style post.
class CreateInstagramPostModal extends StatefulWidget {
  const CreateInstagramPostModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const CreateInstagramPostModal(),
    );
  }

  @override
  State<CreateInstagramPostModal> createState() =>
      _CreateInstagramPostModalState();
}

class _CreateInstagramPostModalState extends State<CreateInstagramPostModal> {
  final TextEditingController _captionCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController(
    text: 'Global Smart Hub',
  );
  String _selectedPhotoUrl = 'assets/western province/galle-face.jpg';

  static const List<String> _presetPhotos = [
    'assets/western province/galle-face.jpg',
    'assets/southern province/mirissa beach.jpg',
    'assets/central province/sigiriya.jpg',
    'assets/cover.png',
  ];

  @override
  void dispose() {
    _captionCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    try {
      final social = context.read<SocialService>();
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 82,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final urls = await social.uploadPostImages([bytes]);
      if (urls.isNotEmpty && mounted) {
        setState(() => _selectedPhotoUrl = urls.first);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final social = context.watch<SocialService>();

    return Padding(
      padding: EdgeInsets.only(
        top: AppSpace.lg,
        left: AppSpace.lg,
        right: AppSpace.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpace.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Create Citizen Feed Post',
                style: AppTypography.title.copyWith(
                  color: AppColors.textPrimary(context),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          AppButton(
            label: 'Upload Photo from Device Gallery',
            icon: Icons.photo_library_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: _pickFromGallery,
          ),
          const SizedBox(height: AppSpace.sm),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _presetPhotos.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpace.sm),
              itemBuilder: (context, idx) {
                final asset = _presetPhotos[idx];
                final isSelected = _selectedPhotoUrl == asset;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPhotoUrl = asset),
                  child: Container(
                    width: 90,
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.smBorder,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary(context)
                            : AppColors.outline(context),
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(asset, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpace.md),
          AppTextField(
            controller: _locationCtrl,
            label: 'Location Tag',
            hint: 'e.g. Colombo, Kandy, London, Dubai...',
          ),
          const SizedBox(height: AppSpace.md),
          AppTextField(
            controller: _captionCtrl,
            label: 'Caption',
            hint: 'Share what is happening in your neighborhood...',
            maxLines: 3,
          ),
          const SizedBox(height: AppSpace.lg),
          AppButton(
            label: 'Share to Citizen Feed',
            icon: Icons.send_rounded,
            fullWidth: true,
            onPressed: () async {
              await social.addUserPost(
                placeId: 'nintavur_feed',
                placeName: _locationCtrl.text.trim().isEmpty
                    ? 'Nintavur Smart City'
                    : _locationCtrl.text.trim(),
                caption: _captionCtrl.text.trim().isEmpty
                    ? 'Sharing a live update from Nintavur Smart City! #SmartCity'
                    : _captionCtrl.text.trim(),
                photoUrls: [_selectedPhotoUrl],
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your post is now live on the Citizen Feed!'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Full-page Instagram-style Citizen Feed Screen.
class FullInstagramFeedScreen extends StatelessWidget {
  const FullInstagramFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Citizen Feed'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpace.md),
            child: AppButton(
              label: 'New Post',
              icon: Icons.add_a_photo_outlined,
              onPressed: () => CreateInstagramPostModal.show(context),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: AppSpace.pagePadding,
        children: const [
          InstagramFeedSection(showStoriesRow: true),
        ],
      ),
    );
  }
}
