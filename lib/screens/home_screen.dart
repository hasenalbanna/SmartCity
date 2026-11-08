import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../data/sri_lanka_places.dart';
import '../services/profile_service.dart';
import '../services/social_service.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../services/theme_service.dart';
import '../widgets/liquid_background.dart';
import '../widgets/app_top_utilities.dart';
import '../widgets/water_glow_card.dart';
import 'chat_list_screen.dart';
import 'community_feed_screen.dart';
import 'explore_screen.dart';
import 'itinerary_screen.dart';
import 'map_screen.dart';
import 'notifications_screen.dart';
import 'place_detail_screen.dart';
import 'profile_screen.dart';
import 'saved_screen.dart';
import 'schedule_calendar_screen.dart';
import 'sim_recommendation_screen.dart';
import 'trip_journal_screen.dart';
import 'world_clock_screen.dart';
import 'hotel_booking_screen.dart';
import 'ai_travel_planner_screen.dart';
import 'settings_screen.dart';
import 'community_issues_screen.dart';
import 'smart_bus_tracking_screen.dart';
import 'drive_setup_screen.dart' as drive_setup_screen;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionTitleColor = isDark
        ? const Color(0xFFEAF1FF)
        : const Color(0xFF2D3436);

    return Scaffold(
      drawer: _buildFeatureDrawer(context, isDark),
      body: LiquidBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppTopUtilities(),

                _animatedSection(
                  delayMs: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: SizedBox(
                      height: 188,
                      child: _buildCurrentWeatherCard(context, isDark),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Ultra-Minimalist Header
                _animatedSection(
                  delayMs: 70,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Builder(
                              builder: (scaffoldContext) => GestureDetector(
                                onTap: () =>
                                    Scaffold.of(scaffoldContext).openDrawer(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.12)
                                          : Colors.black.withValues(
                                              alpha: 0.08,
                                            ),
                                    ),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Icon(
                                    Icons.menu,
                                    size: 20,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Provider.of<ThemeService>(
                                      context,
                                      listen: false,
                                    ).toggleTheme();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.12,
                                              )
                                            : Colors.black.withValues(
                                                alpha: 0.08,
                                              ),
                                      ),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Icon(
                                      isDark
                                          ? Icons.light_mode
                                          : Icons.dark_mode,
                                      size: 18,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.05),
                                  backgroundImage: _headerAvatarProvider(
                                    context,
                                  ),
                                  child: _headerAvatarProvider(context) == null
                                      ? Icon(
                                          Icons.person,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                          size: 18,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        // main greeting
                        Text(
                          'Explore.',
                          style: TextStyle(
                            fontSize: 42,
                            height: 1.1,
                            letterSpacing: -1.5,
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Pill-shaped search bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.black.withValues(alpha: 0.08),
                            ),
                          ),
                          child: TextField(
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Where to next?',
                              hintStyle: TextStyle(
                                color: isDark
                                    ? const Color(0xFFA1A1AA)
                                    : const Color(0xFF71717A),
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                
                // Start Drive Button
                _animatedSection(
                  delayMs: 80,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const drive_setup_screen.DriveSetupScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white : Colors.black,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _AnimatedDriveIcon(isDark: isDark),
                            const SizedBox(width: 8),
                            Text(
                              'Start Drive',
                              style: TextStyle(
                                color: isDark ? Colors.black : Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Editorial Map Preview
                _animatedSection(
                  delayMs: 90,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Explore Sri Lanka',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: sectionTitleColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MapScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.12)
                                        : Colors.black.withValues(alpha: 0.08),
                                  ),
                                ),
                                child: Text(
                                  'Expand Map',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.12)
                                  : Colors.black.withValues(alpha: 0.08),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                FlutterMap(
                                  options: const MapOptions(
                                    initialCenter: LatLng(7.8731, 80.7718),
                                    initialZoom: 7.0,
                                    interactionOptions: InteractionOptions(
                                      flags: InteractiveFlag.all,
                                    ),
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
                                      subdomains: const ['a', 'b', 'c', 'd'],
                                      userAgentPackageName:
                                          'com.smartcity.app',
                                    ),
                                    MarkerLayer(
                                      markers: sriLankaPlaces.map((place) {
                                        return Marker(
                                          point: place.location,
                                          width: 104,
                                          height: 54,
                                          child: _buildMapMarkerWithNav(
                                            context,
                                            place,
                                            isDark,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    Consumer<LocationService>(
                                      builder: (context, location, _) {
                                        final position =
                                            location.currentPosition;
                                        if (position == null) {
                                          return const SizedBox.shrink();
                                        }
                                        return MarkerLayer(
                                          markers: [
                                            Marker(
                                              point: LatLng(
                                                position.latitude,
                                                position.longitude,
                                              ),
                                              width: 34,
                                              height: 34,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: isDark
                                                        ? Colors.black
                                                        : Colors.white,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.my_location,
                                                  color: isDark
                                                      ? Colors.black
                                                      : Colors.white,
                                                  size: 18,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Consumer<LocationService>(
                                    builder: (context, location, _) {
                                      return GestureDetector(
                                        onTap: () async {
                                          await location.getCurrentLocation();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 7,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.92,
                                                  )
                                                : Colors.black.withValues(
                                                    alpha: 0.92,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              100,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.my_location,
                                                size: 14,
                                                color: isDark
                                                    ? Colors.black
                                                    : Colors.white,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Live',
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.black
                                                      : Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Quick Actions Section
                _animatedSection(
                  delayMs: 160,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shortcuts',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: sectionTitleColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildQuickActionButton(
                                context,
                                Icons.report_problem_outlined,
                                'Citizen Reports',
                                const Color(0xFFEF4444), // Vibrant Red
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CommunityIssuesScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildQuickActionButton(
                                context,
                                Icons.directions_bus_filled_outlined,
                                'Smart Buses',
                                const Color(0xFF2563EB), // Vibrant Blue
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SmartBusTrackingScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildQuickActionButton(
                                context,
                                Icons.auto_awesome,
                                'AI Planner',
                                const Color(0xFF111111),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const AITravelPlannerScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildQuickActionButton(
                                context,
                                Icons.sim_card,
                                'SIM Cards',
                                const Color(0xFF111111),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const SIMRecommendationScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildQuickActionButton(
                                context,
                                Icons.hotel,
                                'Hotels',
                                const Color(0xFF111111),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HotelBookingScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildQuickActionButton(
                                context,
                                Icons.menu_book_rounded,
                                'Trip Journal',
                                const Color(0xFF111111),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TripJournalScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              _buildQuickActionButton(
                                context,
                                Icons.settings,
                                'Settings',
                                const Color(0xFF111111),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // AI Insights Today Section
                _animatedSection(
                  delayMs: 230,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'AI Insights',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: sectionTitleColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 178,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildAIInsightCard(
                        context,
                        'Best Time to Visit',
                        'Sigiriya',
                        '6:00 AM - Beat the crowds',
                        Icons.access_time,
                        const Color(0xFF111111),
                      ),
                      _buildAIInsightCard(
                        context,
                        'Weather Alert',
                        'Ella Region',
                        'Light rain expected',
                        Icons.cloud,
                        const Color(0xFF111111),
                      ),
                      _buildAIInsightCard(
                        context,
                        'Local Festival',
                        'Kandy',
                        'Perahera this weekend',
                        Icons.celebration,
                        const Color(0xFF111111),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Locals by AI Section
                _animatedSection(
                  delayMs: 300,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Locals by AI',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: sectionTitleColor,
                          ),
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CommunityFeedScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.dynamic_feed),
                              label: const Text('Open Feed'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Consumer<SocialService>(
                  builder: (context, social, _) {
                    final posts = social.getAlgorithmAlignedPosts();
                    if (posts.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'No traveler uploads yet. Open Feed to share your first post.',
                        ),
                      );
                    }

                    return SizedBox(
                      height: 370,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];
                          final imageUrl = post.photoUrls.isEmpty
                              ? ''
                              : post.photoUrls.first;
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CommunityFeedScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 280,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : Colors.black.withValues(alpha: 0.08),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (imageUrl.isNotEmpty)
                                      Image.network(imageUrl, fit: BoxFit.cover)
                                    else
                                      Container(
                                        color: isDark
                                            ? const Color(0xFF111111)
                                            : const Color(0xFFF4F4F4),
                                      ),
                                    Positioned.fill(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withValues(
                                                alpha: 0.75,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 16,
                                      right: 16,
                                      bottom: 16,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.58,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.12,
                                            ),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '@${post.userName}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              post.placeName,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAIInsightCard(
    BuildContext context,
    String title,
    String location,
    String detail,
    IconData icon,
    Color bgColor,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WaterGlowCard(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? null
              : const Color(0xFF16181C), // Plain dark in light mode
          gradient: isDark
              ? LinearGradient(
                  colors: [
                    const Color(0xFF0F1B31),
                    const Color(0xFF18253E),
                    bgColor.withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null, // Removed gradient for light mode
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.14)
                : Colors.transparent,
          ),
        ),
        child: Stack(
          children: [
            if (!isDark)
              Positioned.fill(
                child: CustomPaint(
                  painter:
                      _InsightGrainPainter(), // Grain added for light mode black cards
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? null
                        : Colors
                              .white12, // Minimal icon background for light mode
                    gradient: isDark
                        ? const LinearGradient(
                            colors: [Color(0xFF2BC0E4), Color(0xFF8A7CFF)],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: Colors.white),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFA8B7D2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEAF1FF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFC1CEE3),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapMarkerWithNav(
    BuildContext context,
    SriLankaPlace place,
    bool isDark,
  ) {
    final uniqueText = _compactPinText(
      place.highlights.isNotEmpty
          ? place.highlights.first
          : place.shortDescription,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: place)),
        );
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 92),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isDark ? Colors.black : Colors.white,
                  width: 1,
                ),
              ),
              child: Text(
                uniqueText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDark ? Colors.white : Colors.black,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.black : Colors.white,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.location_on_rounded,
                color: isDark ? Colors.black : Colors.white,
                size: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _compactPinText(String text) {
    final normalized = text.trim();
    if (normalized.length <= 16) return normalized;
    return '${normalized.substring(0, 15)}...';
  }

  ImageProvider? _headerAvatarProvider(BuildContext context) {
    final profile = context.watch<ProfileService>();
    if (profile.avatarBytes != null) {
      return MemoryImage(profile.avatarBytes!);
    }
    return null;
  }

  Drawer _buildFeatureDrawer(BuildContext context, bool isDark) {
    return Drawer(
      backgroundColor: isDark
          ? const Color(0xFF0F1625)
          : const Color(0xFFF4F9FF),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            _drawerItem(
              context,
              Icons.report_problem_outlined,
              'Citizen Issue Reports',
              const CommunityIssuesScreen(),
            ),
            _drawerItem(
              context,
              Icons.directions_bus_outlined,
              'Smart Bus Tracking',
              const SmartBusTrackingScreen(),
            ),
            _drawerItem(
              context,
              Icons.explore_outlined,
              'Explore',
              const ExploreScreen(),
            ),
            _drawerItem(context, Icons.map_outlined, 'Map', const MapScreen()),
            _drawerItem(
              context,
              Icons.auto_awesome_outlined,
              'AI Planner',
              const AITravelPlannerScreen(),
            ),
            _drawerItem(
              context,
              Icons.sim_card_outlined,
              'SIM Recommendations',
              const SIMRecommendationScreen(),
            ),
            _drawerItem(
              context,
              Icons.hotel_outlined,
              'Hotels',
              const HotelBookingScreen(),
            ),
            _drawerItem(
              context,
              Icons.event_note_outlined,
              'Itinerary',
              const ItineraryScreen(),
            ),
            _drawerItem(
              context,
              Icons.calendar_month_outlined,
              'Travel Calendar',
              const ScheduleCalendarScreen(),
            ),
            _drawerItem(
              context,
              Icons.access_time_outlined,
              'Clock & Timer',
              const WorldClockScreen(),
            ),
            _drawerItem(
              context,
              Icons.dynamic_feed_outlined,
              'Community Feed',
              const CommunityFeedScreen(),
            ),
            _drawerItem(
              context,
              Icons.chat_bubble_outline,
              'Realtime Chat',
              const ChatListScreen(),
            ),
            _drawerItem(
              context,
              Icons.bookmarks_outlined,
              'Saved',
              const SavedScreen(),
            ),
            _drawerItem(
              context,
              Icons.menu_book_outlined,
              'Trip Journal',
              const TripJournalScreen(),
            ),
            _drawerItem(
              context,
              Icons.notifications_outlined,
              'Notifications',
              const NotificationsScreen(),
            ),
            _drawerItem(
              context,
              Icons.person_outline,
              'Profile',
              const ProfileScreen(),
            ),
            _drawerItem(
              context,
              Icons.settings_outlined,
              'Settings',
              const SettingsScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget screen,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBackground = const Color(0xFF111111);
    final tileBorder = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.12);
    final labelColor = const Color(0xFFF5F5F5);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 104,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: tileBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tileBorder),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 28,
              child: Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.05,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard(BuildContext context, bool isDark) {
    return Consumer<WeatherService>(
      builder: (context, weather, _) {
        final point = weather.currentWeather;

        if (point == null && weather.isLoading) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : const Color(0xFFE3EEFB),
              ),
            ),
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.14)
                  : const Color(0xFFDADDE3),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    _weatherBackgroundAsset(point?.weatherCode ?? -1),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: isDark
                          ? const Color(0xFF121826)
                          : const Color(0xFFE8ECEF),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.42),
                          Colors.black.withValues(alpha: 0.58),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          WeatherService.weatherIcon(point?.weatherCode ?? 0),
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${weather.currentLabel} Weather',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              point == null
                                  ? 'Weather unavailable'
                                  : '${WeatherService.weatherLabel(point.weatherCode)} • Wind ${point.windKph.toStringAsFixed(0)} km/h',
                              style: const TextStyle(
                                color: Color(0xFFE4E9F1),
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Updated ${weather.updatedAgo}',
                              style: const TextStyle(
                                color: Color(0xFFD0D8E6),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        point == null
                            ? '--'
                            : '${point.temperatureC.toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      IconButton(
                        onPressed: weather.refreshNow,
                        icon: const Icon(
                          Icons.refresh_rounded,
                          size: 18,
                          color: Color(0xFFD7DDE8),
                        ),
                        tooltip: 'Refresh weather',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _weatherBackgroundAsset(int code) {
    if (code == 0) {
      return 'assets/western province/galle-face.jpg';
    }
    if (code == 1 || code == 2) {
      return 'assets/southern province/mirissa beach.jpg';
    }
    if (code == 3 || code == 45 || code == 48) {
      return 'assets/central province/knuckles.jpg';
    }
    if (code == 51 ||
        code == 53 ||
        code == 55 ||
        code == 61 ||
        code == 63 ||
        code == 65 ||
        code == 66 ||
        code == 67 ||
        code == 80 ||
        code == 81 ||
        code == 82) {
      return 'assets/uva province/ravana falls.jpg';
    }
    if (code == 95 || code == 96 || code == 99) {
      return 'assets/eastern province/kumana national park.jpg';
    }
    return 'assets/home cover.png';
  }

  Widget _animatedSection({required int delayMs, required Widget child}) {
    final duration = Duration(milliseconds: 450 + delayMs);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, section) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 18),
            child: section,
          ),
        );
      },
      child: child,
    );
  }
}

class _InsightGrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random();
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw dark noise/grain for the premium black card in light mode
    final points = (size.width * size.height / 500).round();
    for (var i = 0; i < points; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final alpha = 0.05 + rnd.nextDouble() * 0.05;
      paint.color = Colors.white.withValues(
        alpha: alpha,
      ); // Subtle white speckles on black
      canvas.drawRect(Rect.fromLTWH(x, y, 1.2, 1.2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AnimatedDriveIcon extends StatefulWidget {
  final bool isDark;
  
  const _AnimatedDriveIcon({required this.isDark});

  @override
  State<_AnimatedDriveIcon> createState() => _AnimatedDriveIconState();
}

class _AnimatedDriveIconState extends State<_AnimatedDriveIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: false);

    _animation = Tween<double>(begin: -15.0, end: 15.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0),
          child: Opacity(
            // Fade out at edges to make looping smoother
            opacity: 1.0 - (_animation.value.abs() / 15.0),
            child: Icon(
              Icons.drive_eta, 
              color: widget.isDark ? Colors.black : Colors.white
            ),
          ),
        );
      },
    );
  }
}
