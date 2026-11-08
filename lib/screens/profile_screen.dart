import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/payment_service.dart';
import '../services/profile_service.dart';
import '../services/social_service.dart';
import '../widgets/liquid_background.dart';
import 'chat_list_screen.dart';
import 'community_feed_screen.dart';
import 'customize_profile_screen.dart';
import 'login_screen.dart';
import 'trip_summary_screen.dart';
import '../services/trip_history_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileService>();
    final auth = context.watch<AuthService>();
    final social = context.watch<SocialService>();
    final payment = context.watch<PaymentService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? const Color(0xFFEAF1FF)
        : const Color(0xFF10233D);
    final mutedColor = isDark
        ? const Color(0xFFB8C1D1)
        : const Color(0xFF74829B);
    final primaryColor = isDark
        ? const Color(0xFFEAF1FF)
        : const Color(0xFF111111);

    final effectiveName = profile.displayName.trim().isNotEmpty
        ? profile.displayName.trim()
        : (auth.currentUser?.username ?? 'Traveler');
    final effectiveBio = profile.bio.trim().isNotEmpty
        ? profile.bio.trim()
        : 'Traveler';
    final myPosts = social
        .getAllPosts()
        .where((p) => p.userId == social.currentUserId)
        .toList(growable: false);
    final myBookings = payment.getUserBookings(social.currentUserId);
    final reviewsCount = social.comments
        .where((c) => c.userId == social.currentUserId)
        .length;

    return Scaffold(
      body: LiquidBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
            child: Column(
              children: [
                _buildTopBar(context),
                const SizedBox(height: 14),
                _buildHeroSection(
                  context: context,
                  profile: profile,
                  isDark: isDark,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  primaryColor: primaryColor,
                  effectiveName: effectiveName,
                  effectiveBio: effectiveBio,
                  tripsCount: myBookings.length,
                  reviewsCount: reviewsCount,
                  uploadsCount: myPosts.length,
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'ACCOUNT MENU',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 11,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _menuItem(
                  context: context,
                  isDark: isDark,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  primaryColor: primaryColor,
                  icon: Icons.chat_bubble_outline,
                  title: 'Realtime Chat',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChatListScreen()),
                    );
                  },
                ),
                _menuItem(
                  context: context,
                  isDark: isDark,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  primaryColor: primaryColor,
                  icon: Icons.tune,
                  title: 'Customize Profile',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomizeProfileScreen(),
                      ),
                    );
                  },
                ),
                _menuItem(
                  context: context,
                  isDark: isDark,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  primaryColor: primaryColor,
                  icon: Icons.add_a_photo_outlined,
                  title: 'Upload Photo',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CommunityFeedScreen(),
                      ),
                    );
                  },
                ),
                _menuItem(
                  context: context,
                  isDark: isDark,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  primaryColor: primaryColor,
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  accentColor: const Color(0xFFE5484D),
                  onTap: () async {
                    await context.read<AuthService>().logout();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Saved Items Cards
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Navigate to Saved Trips
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.directions_car, color: primaryColor, size: 28),
                              const SizedBox(height: 12),
                              Text('Saved Trips', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                              Text('3 planned trips', style: TextStyle(color: mutedColor, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Navigate to Saved Places
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.favorite, color: const Color(0xFFE5484D), size: 28),
                              const SizedBox(height: 12),
                              Text('Saved Places', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                              Text('12 locations', style: TextStyle(color: mutedColor, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Trip History Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trip History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildTripHistoryGrid(context),
                
                const SizedBox(height: 32),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Photos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '${context.watch<SocialService>().getAllPosts().where((p) => p.userId == context.watch<SocialService>().currentUserId).length} posts',
                      style: TextStyle(
                        color: mutedColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildInstagramGrid(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? const Color(0xFFEAF1FF)
        : const Color(0xFF10233D);
    return Row(
      children: [
        _circleBtn(
          context,
          Icons.arrow_back_ios_new,
          onTap: () => Navigator.maybePop(context),
        ),
        Expanded(
          child: Center(
            child: Text(
              'Profile',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: textColor,
              ),
            ),
          ),
        ),
        _circleBtn(
          context,
          Icons.settings,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomizeProfileScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _circleBtn(
    BuildContext context,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? const Color(0xFFEAF1FF)
        : const Color(0xFF10233D);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.09)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.16) : Colors.white,
          ),
        ),
        child: Icon(icon, size: 17, color: textColor),
      ),
    );
  }

  Widget _buildHeroSection({
    required BuildContext context,
    required ProfileService profile,
    required bool isDark,
    required Color textColor,
    required Color mutedColor,
    required Color primaryColor,
    required String effectiveName,
    required String effectiveBio,
    required int tripsCount,
    required int reviewsCount,
    required int uploadsCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.16)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          _buildAvatar(context, profile),
          const SizedBox(height: 12),
          Text(
            effectiveName,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: textColor,
              height: 1.0,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            effectiveBio,
            style: TextStyle(
              color: mutedColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Member since ${profile.memberSince.year}',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildStats(
            tripsCount: tripsCount,
            reviewsCount: reviewsCount,
            uploadsCount: uploadsCount,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, ProfileService profile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Container(
          width: 124,
          height: 124,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: profile.avatarBytes != null
                ? Image.memory(profile.avatarBytes!, fit: BoxFit.cover)
                : Container(
                    color: const Color(0xFF1E293B),
                    child: const Icon(
                      Icons.person,
                      size: 56,
                      color: Color(0xFFEAF1FF),
                    ),
                  ),
          ),
        ),
        Positioned(
          right: 6,
          bottom: 6,
          child: GestureDetector(
            onTap: () async {
              final ok = await context
                  .read<ProfileService>()
                  .pickAvatarFromGallery();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok ? 'Profile photo updated' : 'No photo selected',
                  ),
                ),
              );
            },
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isDark ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.edit,
                size: 14,
                color: isDark ? Colors.black : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats({
    required int tripsCount,
    required int reviewsCount,
    required int uploadsCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _Stat(title: '$tripsCount', label: 'Trips'),
        ),
        Expanded(
          child: _Stat(title: '$reviewsCount', label: 'Reviews'),
        ),
        Expanded(
          child: _Stat(title: '$uploadsCount', label: 'Uploads'),
        ),
      ],
    );
  }

  Widget _menuItem({
    required BuildContext context,
    required bool isDark,
    required Color textColor,
    required Color mutedColor,
    required Color primaryColor,
    required IconData icon,
    required String title,
    Color? accentColor,
    required VoidCallback onTap,
  }) {
    final tone = accentColor ?? primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.14) : Colors.white,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : const Color(0xFFEAF2F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: tone),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: accentColor == null ? textColor : tone,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: mutedColor),
          ],
        ),
      ),
    );
  }

  Widget _buildInstagramGrid(BuildContext context) {
    final social = context.watch<SocialService>();
    final myPosts = social
        .getAllPosts()
        .where((p) => p.userId == social.currentUserId)
        .toList(growable: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? const Color(0xFFEAF1FF)
        : const Color(0xFF10233D);
    final mutedColor = isDark
        ? const Color(0xFFB8C1D1)
        : const Color(0xFF74829B);
    if (myPosts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.14)
                : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Icon(Icons.photo_library_outlined, color: mutedColor, size: 36),
            const SizedBox(height: 8),
            Text(
              'No uploads yet',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CommunityFeedScreen(),
                  ),
                );
              },
              child: const Text('Upload your first photo'),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: myPosts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        final post = myPosts[index];
        final imageUrl = post.photoUrls.isEmpty ? '' : post.photoUrls.first;
        if (imageUrl.isEmpty) {
          return Container(color: const Color(0xFFEAF2F6));
        }
        return GestureDetector(
          onTap: () {},
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300],
              child: Icon(Icons.broken_image, color: isDark ? Colors.white54 : Colors.grey),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTripHistoryGrid(BuildContext context) {
    final tripHistory = context.watch<TripHistoryService>();
    final trips = tripHistory.trips;
    
    if (trips.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: const Text('No trips recorded yet.', style: TextStyle(color: Colors.grey)),
      );
    }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: trips.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        final trip = trips[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TripSummaryScreen(trip: trip)),
            );
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                trip.mapPreviewUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.map, color: Colors.grey),
                ),
              ),
              Positioned(
                bottom: 4,
                left: 4,
                child: Icon(
                  trip.vehicle == 'Car' ? Icons.directions_car :
                  trip.vehicle == 'Train' ? Icons.directions_transit :
                  trip.vehicle == 'Flight' ? Icons.flight :
                  trip.vehicle == 'Bus' ? Icons.directions_bus : Icons.local_shipping,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final String title;
  final String label;

  const _Stat({required this.title, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? const Color(0xFFEAF1FF)
        : const Color(0xFF10233D);
    final mutedColor = isDark
        ? const Color(0xFFB8C1D1)
        : const Color(0xFF74829B);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: mutedColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
