import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../data/global_regions_data.dart';
import '../models/traveler_profile.dart';
import '../models/user_post.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/social_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/instagram_feed_section.dart';
import '../widgets/ui/ui.dart';

/// Global Citizen & Traveler Community Screen:
/// - Directory of citizens who logged in by their unique @username
/// - Life Journeys & Traveled Places with interactive OpenStreetMap route paths
/// - Real-time follow, connection, search, and journey creation
class CommunityHubScreen extends StatefulWidget {
  const CommunityHubScreen({super.key});

  @override
  State<CommunityHubScreen> createState() => _CommunityHubScreenState();
}

class _CommunityHubScreenState extends State<CommunityHubScreen> {
  String _searchQuery = '';
  String _activeFilter = 'All';
  bool _isGridView = true;

  static const List<String> _filters = [
    'All',
    'Logged In',
    'Top Travelers',
    'Map Routes',
    'Local Stewards',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncAuthUser();
    });
  }

  void _syncAuthUser() {
    final auth = context.read<AuthService>();
    final profile = context.read<ProfileService>();
    final social = context.read<SocialService>();

    final user = auth.currentUser;
    if (user != null) {
      final country = GlobalRegions.findCountry(auth.userCountry);
      social.syncCurrentUser(
        uid: user.id,
        username: user.username,
        displayName: profile.displayName.isNotEmpty
            ? profile.displayName
            : user.username,
        country: auth.userCountry,
        city: auth.userCity,
        countryFlag: country.flag,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final social = context.watch<SocialService>();
    final auth = context.watch<AuthService>();
    final travelers = social.getTravelersForCountry(auth.userCountry);
    final allPosts = social.getAllPosts(country: auth.userCountry);

    // Filter travelers by search query & filter
    final filteredTravelers = travelers.where((t) {
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchHandle = t.username.toLowerCase().contains(q);
        final matchName = t.displayName.toLowerCase().contains(q);
        final matchCity = t.city.toLowerCase().contains(q);
        final matchCountry = t.country.toLowerCase().contains(q);
        final matchBio = t.bio.toLowerCase().contains(q);
        if (!matchHandle && !matchName && !matchCity && !matchCountry && !matchBio) {
          return false;
        }
      }
      if (_activeFilter == 'Logged In') {
        return t.username.toLowerCase() == auth.currentUser?.username.toLowerCase();
      }
      if (_activeFilter == 'Top Travelers') {
        return t.placesTraveledCount >= 10;
      }
      if (_activeFilter == 'Local Stewards') {
        return t.country.toLowerCase() == auth.userCountry.toLowerCase();
      }
      return true;
    }).toList();

    // Filter journey posts
    final journeyPosts = allPosts.where((p) {
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = p.placeName.toLowerCase().contains(q);
        final matchCaption = (p.caption ?? '').toLowerCase().contains(q);
        final matchRoute = (p.routeSummary ?? '').toLowerCase().contains(q);
        final matchUser = p.userName.toLowerCase().contains(q) ||
            p.userHandle.toLowerCase().contains(q);
        if (!matchTitle && !matchCaption && !matchRoute && !matchUser) {
          return false;
        }
      }
      if (_activeFilter == 'Map Routes') {
        return p.routeSummary != null && p.routeSummary!.isNotEmpty;
      }
      return true;
    }).toList();

    return AppScaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateJourneyModal(context),
        backgroundColor: AppColors.primary(context),
        foregroundColor: AppColors.onPrimary(context),
        icon: const Icon(Icons.alt_route_rounded),
        label: const Text('Share Life Journey'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.lg,
          AppSpace.md,
          AppSpace.lg,
          AppSpace.xxl,
        ),
        children: [
          // Header
          _buildHeader(context, auth),
          const SizedBox(height: AppSpace.md),

          // Search Bar
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search @username, country, or traveled route...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: AppSpace.md),

          // Filter Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((f) {
                final isSelected = _activeFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpace.sm),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _activeFilter = f),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpace.lg),

          // Section 1: Citizens & Travelers Directory (Logged in by username)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Citizens & Global Travelers',
                      style: AppTypography.title.copyWith(
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${filteredTravelers.length} citizens active • Unique @username directory',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.sm),

          // Horizontal Directory of Citizens
          if (filteredTravelers.isEmpty)
            const EmptyState(
              icon: Icons.person_search_rounded,
              title: 'No citizens match your search',
              subtitle: 'Try searching by a different @username or location.',
            )
          else
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filteredTravelers.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpace.md),
                itemBuilder: (context, index) {
                  final traveler = filteredTravelers[index];
                  return _buildCitizenCard(context, traveler, auth);
                },
              ),
            ),
          const SizedBox(height: AppSpace.xl),

          // Section 2: Life Journeys & Map Paths (Instagram-Style Travel Grid)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Travel Moments & Map Paths',
                      style: AppTypography.title.copyWith(
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Traveled places shared with route lines & community stories',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Grid View',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.grid_view_rounded,
                      color: _isGridView
                          ? AppColors.primary(context)
                          : AppColors.textSecondary(context),
                    ),
                    onPressed: () => setState(() => _isGridView = true),
                  ),
                  IconButton(
                    tooltip: 'Feed View',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.view_agenda_outlined,
                      color: !_isGridView
                          ? AppColors.primary(context)
                          : AppColors.textSecondary(context),
                    ),
                    onPressed: () => setState(() => _isGridView = false),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),

          // Journey Grid or Feed
          if (journeyPosts.isEmpty)
            const EmptyState(
              icon: Icons.alt_route_rounded,
              title: 'No travel journeys yet',
              subtitle: 'Be the first citizen to share your traveled route!',
            )
          else if (_isGridView)
            _buildInstagramTravelGrid(context, journeyPosts)
          else
            ...journeyPosts.map(
              (post) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.lg),
                child: InstagramPostCard(post: post),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthService auth) {
    final country = GlobalRegions.findCountry(auth.userCountry);
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted(context),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.outline(context)),
          ),
          child: const Icon(
            Icons.people_alt_rounded,
            size: 22,
          ),
        ),
        const SizedBox(width: AppSpace.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Citizen Community',
                style: AppTypography.title.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${country.flag} ${auth.userCity}, ${country.name} • Global Network',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        StatusChip(
          label: 'GLOBAL',
          kind: StatusChipKind.info,
          icon: Icons.public_rounded,
        ),
      ],
    );
  }

  Widget _buildCitizenCard(
    BuildContext context,
    TravelerProfile traveler,
    AuthService auth,
  ) {
    final isMe = traveler.username.toLowerCase() ==
        auth.currentUser?.username.toLowerCase();
    final fg = AppColors.textPrimary(context);
    final muted = AppColors.textSecondary(context);

    return InkWell(
      onTap: () => _showCitizenPortfolioModal(context, traveler),
      borderRadius: AppRadius.lgBorder,
      child: Container(
        width: 172,
        padding: const EdgeInsets.all(AppSpace.md),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: AppRadius.lgBorder,
          border: Border.all(
            color: isMe
                ? AppColors.primary(context)
                : AppColors.outline(context),
            width: isMe ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar & Flag
            Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary(context),
                      child: Text(
                        traveler.displayName.isNotEmpty
                            ? traveler.displayName[0].toUpperCase()
                            : 'C',
                        style: AppTypography.subtitle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (traveler.isVerified)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(1.5),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.verified_rounded,
                            size: 13,
                            color: AppColors.primary(context),
                          ),
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted(context),
                    borderRadius: AppRadius.pillBorder,
                  ),
                  child: Text(
                    traveler.countryFlag,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.sm),

            // Handle & Name
            Text(
              '@${traveler.username}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyStrong.copyWith(
                color: fg,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${traveler.city}, ${traveler.country}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(color: muted),
            ),
            const Spacer(),

            // Life Journey Stats
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted(context),
                borderRadius: AppRadius.smBorder,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🗺️ ${traveler.placesTraveledCount} places',
                    style: AppTypography.caption.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    '📍 ${traveler.routesSharedCount} routes',
                    style: AppTypography.caption.copyWith(
                      color: muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstagramTravelGrid(
    BuildContext context,
    List<UserPost> posts,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth < 600 ? 2 : 3;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: AppSpace.sm,
            mainAxisSpacing: AppSpace.sm,
            childAspectRatio: 0.76,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return _buildInstagramGridCard(context, post);
          },
        );
      },
    );
  }

  Widget _buildInstagramGridCard(BuildContext context, UserPost post) {
    final photoUrl = post.photoUrls.isNotEmpty
        ? post.photoUrls.first
        : 'assets/cover.png';
    final hasRoute = post.routeSummary != null && post.routeSummary!.isNotEmpty;

    return InkWell(
      onTap: () => _showJourneyDetailModal(context, post),
      borderRadius: AppRadius.mdBorder,
      child: ClipRRect(
        borderRadius: AppRadius.mdBorder,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Traveled place photo
            _buildPostImage(photoUrl),

            // Top Gradient with user handle
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(AppSpace.xs + 2),
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
                      radius: 11,
                      backgroundColor: Colors.white,
                      child: Text(
                        post.userName.isNotEmpty
                            ? post.userName[0].toUpperCase()
                            : 'T',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        post.userHandle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Gradient with Map Path & Place Name
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(AppSpace.xs + 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.88),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasRoute)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        margin: const EdgeInsets.only(bottom: 2),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.85),
                          borderRadius: AppRadius.smBorder,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.alt_route_rounded,
                              size: 11,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                post.routeSummary!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      post.placeName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '❤️ ${post.likesCount}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                        if (post.distanceKm != null)
                          Text(
                            '${post.distanceKm} km',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
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

  // Interactive Life Journey & Map Path Viewer Modal
  void _showJourneyDetailModal(BuildContext context, UserPost post) {
    final lat = post.latitude ?? 7.3486;
    final lng = post.longitude ?? 81.8494;
    final coords = LatLng(lat, lng);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollCtrl) {
            return ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.all(AppSpace.lg),
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outline(ctx),
                      borderRadius: AppRadius.pillBorder,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.md),

                // User Info Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary(ctx),
                      child: Text(
                        post.userName.isNotEmpty
                            ? post.userName[0].toUpperCase()
                            : 'T',
                        style: AppTypography.subtitle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
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
                                style: AppTypography.subtitle.copyWith(
                                  color: AppColors.textPrimary(ctx),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.verified_rounded,
                                size: 14,
                                color: AppColors.primary(ctx),
                              ),
                            ],
                          ),
                          Text(
                            post.placeName,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary(ctx),
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusChip(
                      label: post.distanceKm != null
                          ? '${post.distanceKm} km route'
                          : 'Path Logged',
                      kind: StatusChipKind.resolved,
                      icon: Icons.alt_route_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.md),

                // Photo
                ClipRRect(
                  borderRadius: AppRadius.mdBorder,
                  child: SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: _buildPostImage(
                      post.photoUrls.isNotEmpty
                          ? post.photoUrls.first
                          : 'assets/cover.png',
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.md),

                // Route Path Banner
                if (post.routeSummary != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpace.md),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted(ctx),
                      borderRadius: AppRadius.mdBorder,
                      border: Border.all(color: AppColors.outline(ctx)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.map_rounded,
                              size: 16,
                              color: AppColors.primary(ctx),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'VERIFIED TRAVEL ROUTE PATH',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.primary(ctx),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          post.routeSummary!,
                          style: AppTypography.bodyStrong.copyWith(
                            color: AppColors.textPrimary(ctx),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.md),
                ],

                // Interactive Mini Map Path
                ClipRRect(
                  borderRadius: AppRadius.mdBorder,
                  child: SizedBox(
                    height: 180,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: coords,
                        initialZoom: 11.5,
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
                              point: coords,
                              width: 36,
                              height: 36,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary(ctx),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.md),

                // Caption / Story
                if (post.caption != null && post.caption!.isNotEmpty) ...[
                  Text(
                    'Traveler Story',
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppColors.textPrimary(ctx),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.caption!,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textPrimary(ctx),
                    ),
                  ),
                  const SizedBox(height: AppSpace.md),
                ],

                // Action Buttons (Like / Comment)
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Like (${post.likesCount})',
                        icon: Icons.favorite_rounded,
                        variant: AppButtonVariant.secondary,
                        onPressed: () {
                          ctx.read<SocialService>().togglePostLike(post.id);
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: AppButton(
                        label: 'Done',
                        variant: AppButtonVariant.primary,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Citizen Life Journey Portfolio Modal
  void _showCitizenPortfolioModal(BuildContext context, TravelerProfile traveler) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline(ctx),
                    borderRadius: AppRadius.pillBorder,
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary(ctx),
                    child: Text(
                      traveler.displayName.isNotEmpty
                          ? traveler.displayName[0].toUpperCase()
                          : 'C',
                      style: AppTypography.title.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          traveler.displayName,
                          style: AppTypography.title.copyWith(
                            color: AppColors.textPrimary(ctx),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '@${traveler.username} • ${traveler.countryFlag} ${traveler.city}, ${traveler.country}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary(ctx),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.md),
              Text(
                traveler.bio,
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimary(ctx),
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              Row(
                children: [
                  Expanded(
                    child: _buildPortfolioStat(
                      ctx,
                      '${traveler.placesTraveledCount}',
                      'Places Explored',
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: _buildPortfolioStat(
                      ctx,
                      '${traveler.routesSharedCount}',
                      'Map Routes',
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: _buildPortfolioStat(
                      ctx,
                      '${traveler.followersCount}',
                      'Followers',
                    ),
                  ),
                ],
              ),
              if (traveler.recentRoute != null) ...[
                const SizedBox(height: AppSpace.lg),
                Text(
                  'Signature Traveled Path',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(ctx),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(AppSpace.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted(ctx),
                    borderRadius: AppRadius.smBorder,
                    border: Border.all(color: AppColors.outline(ctx)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.alt_route_rounded,
                        color: AppColors.primary(ctx),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          traveler.recentRoute!,
                          style: AppTypography.bodyStrong.copyWith(
                            color: AppColors.textPrimary(ctx),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpace.xl),
              AppButton(
                label: 'Connect & Follow @${traveler.username}',
                icon: Icons.person_add_rounded,
                fullWidth: true,
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Connected with @${traveler.username}! You will receive their travel path updates.',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPortfolioStat(BuildContext context, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted(context),
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: AppColors.outline(context)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.title.copyWith(
              color: AppColors.primary(context),
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary(context),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // Create Traveled Journey with Map Path Modal
  void _showCreateJourneyModal(BuildContext context) {
    final placeCtrl = TextEditingController();
    final routeCtrl = TextEditingController();
    final distanceCtrl = TextEditingController();
    final captionCtrl = TextEditingController();
    String selectedPhoto = 'assets/central province/sigiriya.jpg';

    final samplePhotos = [
      'assets/central province/sigiriya.jpg',
      'assets/uva province/ella-rock.jpg',
      'assets/southern province/galle-fort.jpg',
      'assets/western province/lotus-tower.jpg',
      'assets/western province/galle-face.jpg',
      'assets/southern province/mirissa beach.jpg',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: AppSpace.lg,
                left: AppSpace.lg,
                right: AppSpace.lg,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpace.lg,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outline(ctx),
                          borderRadius: AppRadius.pillBorder,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpace.md),
                    Text(
                      'Share Traveled Place & Map Path',
                      style: AppTypography.title.copyWith(
                        color: AppColors.textPrimary(ctx),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Broadcast your journey to citizens worldwide on the Community Grid',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary(ctx),
                      ),
                    ),
                    const SizedBox(height: AppSpace.lg),

                    AppTextField(
                      controller: placeCtrl,
                      label: 'Traveled Landmark or Destination',
                      hint: 'e.g. Sigiriya Rock & Golden Cave Corridor',
                      isRequired: true,
                      prefixIcon: const Icon(Icons.place_outlined),
                    ),
                    const SizedBox(height: AppSpace.md),

                    AppTextField(
                      controller: routeCtrl,
                      label: 'Map Route Path (Waypoints)',
                      hint: 'e.g. Colombo ➔ Kandy ➔ Sigiriya',
                      isRequired: true,
                      prefixIcon: const Icon(Icons.alt_route_rounded),
                    ),
                    const SizedBox(height: AppSpace.md),

                    AppTextField(
                      controller: distanceCtrl,
                      label: 'Distance Traveled (km)',
                      hint: 'e.g. 92.4',
                      prefixIcon: const Icon(Icons.straighten_rounded),
                    ),
                    const SizedBox(height: AppSpace.md),

                    AppTextField(
                      controller: captionCtrl,
                      label: 'Journey Story & Travel Tips',
                      hint: 'Share what you experienced, recommended stops, and insights...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpace.md),

                    Text(
                      'Select Journey Photo',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary(ctx),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    SizedBox(
                      height: 72,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: samplePhotos.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpace.sm),
                        itemBuilder: (context, idx) {
                          final photo = samplePhotos[idx];
                          final isPicked = selectedPhoto == photo;
                          return GestureDetector(
                            onTap: () =>
                                setModalState(() => selectedPhoto = photo),
                            child: Container(
                              width: 72,
                              decoration: BoxDecoration(
                                borderRadius: AppRadius.smBorder,
                                border: Border.all(
                                  color: isPicked
                                      ? AppColors.primary(ctx)
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: AppRadius.smBorder,
                                child: Image.asset(photo, fit: BoxFit.cover),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpace.xl),

                    AppButton(
                      label: 'Publish Life Journey to Grid',
                      icon: Icons.send_rounded,
                      fullWidth: true,
                      onPressed: () {
                        if (placeCtrl.text.trim().isEmpty ||
                            routeCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please enter both the destination and route path.',
                              ),
                            ),
                          );
                          return;
                        }

                        final auth = context.read<AuthService>();
                        final social = context.read<SocialService>();
                        final distance = double.tryParse(distanceCtrl.text.trim());

                        social.addUserPost(
                          placeId: 'journey_${DateTime.now().millisecondsSinceEpoch}',
                          placeName: placeCtrl.text.trim(),
                          caption: captionCtrl.text.trim(),
                          photoUrls: [selectedPhoto],
                          routeSummary: routeCtrl.text.trim(),
                          routeStops: routeCtrl.text.split('➔').map((s) => s.trim()).toList(),
                          distanceKm: distance ?? 24.5,
                          country: auth.userCountry,
                          city: auth.userCity,
                        );

                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Life Journey published to the community grid! Visible to all citizens.',
                            ),
                            backgroundColor: AppColors.success(context),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

