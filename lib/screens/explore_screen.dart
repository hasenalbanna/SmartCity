import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/weather_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/ai_insights_section.dart';
import '../widgets/instagram_feed_section.dart';
import '../widgets/premium_store_modal.dart';
import '../widgets/ui/ui.dart';
import 'civic_alerts_screen.dart';
import 'itinerary_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExplorePlace {
  final String name;
  final String tag;
  final String imagePath;
  final double rating;
  final String summary;

  const _ExplorePlace({
    required this.name,
    required this.tag,
    required this.imagePath,
    required this.rating,
    required this.summary,
  });
}

class _ProvinceCardData {
  final String name;
  final String coverImagePath;
  final String hotspot;
  final String tempLabel;
  final String liveVisitors;

  const _ProvinceCardData({
    required this.name,
    required this.coverImagePath,
    required this.hotspot,
    required this.tempLabel,
    required this.liveVisitors,
  });
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _searchQuery = '';

  static const List<_ExplorePlace> _mustSeePlaces = [
    _ExplorePlace(
      name: 'Sigiriya',
      tag: 'Lion Rock',
      imagePath: 'assets/images/sigiriya.jpg',
      rating: 4.9,
      summary:
          'Ancient sky fortress with frescoes, mirror wall, and 360-degree views.',
    ),
    _ExplorePlace(
      name: 'Galle Fort',
      tag: 'Historic',
      imagePath: 'assets/images/galle_fort.jpg',
      rating: 4.8,
      summary:
          'UNESCO coastal fort city with colonial streets, cafes, and ramparts.',
    ),
    _ExplorePlace(
      name: 'Temple of Tooth',
      tag: 'Sacred',
      imagePath: 'assets/central province/temple of tooth.jpg',
      rating: 4.7,
      summary: 'Revered cultural and spiritual complex in the heart of Kandy.',
    ),
  ];

  static const List<_ProvinceCardData> _provinces = [
    _ProvinceCardData(
      name: 'Eastern Province (Nintavur & Arugam Bay)',
      coverImagePath: 'assets/PROVINCE COVER PHOTO/EASTERN.png',
      hotspot: 'Nintavur Smart Coastal Belt & Kumana',
      tempLabel: '29°C',
      liveVisitors: '6,420 live',
    ),
    _ProvinceCardData(
      name: 'Central Province',
      coverImagePath: 'assets/PROVINCE COVER PHOTO/CENTRAL.png',
      hotspot: 'Sigiriya & Kandy Cultural Route',
      tempLabel: '22°C',
      liveVisitors: '5,184 live',
    ),
    _ProvinceCardData(
      name: 'Western Province',
      coverImagePath: 'assets/PROVINCE COVER PHOTO/WESTERN.png',
      hotspot: 'Colombo Smart Waterfront',
      tempLabel: '25°C',
      liveVisitors: '5,945 live',
    ),
    _ProvinceCardData(
      name: 'Southern Province',
      coverImagePath: 'assets/PROVINCE COVER PHOTO/SOTHERN.png',
      hotspot: 'Galle Fort & Mirissa Coast',
      tempLabel: '27°C',
      liveVisitors: '4,890 live',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WeatherService>().refreshNow();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlaces = _mustSeePlaces.where((p) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          p.tag.toLowerCase().contains(q);
    }).toList();

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Explore Smart Regions'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CivicAlertsScreen()),
              );
            },
            icon: const Icon(Icons.notifications_active_outlined, size: 18),
            label: const Text('Civic Alerts'),
          ),
          const SizedBox(width: AppSpace.sm),
        ],
      ),
      body: ListView(
        padding: AppSpace.pagePadding,
        children: [
          // Search Bar
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: const InputDecoration(
              hintText: 'Where to next? Search regions or landmarks...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: AppSpace.lg),

          // Cover Weather Card (same cover card style)
          const ExploreCoverWeatherCard(showExploreBadge: false),
          const SizedBox(height: AppSpace.sm),
          AppButton(
            label: 'Open AI Trip Planner & Live Route Engine',
            icon: Icons.event_note_rounded,
            fullWidth: true,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ItineraryScreen()),
              );
            },
          ),
          const SizedBox(height: AppSpace.lg),

          // Premium Upsell Banner
          const PremiumUpsellBanner(
            title: 'Promote Your Local Business or Hotel on Explore',
            subtitle:
                'Get featured in Must-See Today & Live Transit Maps across Eastern & Central Provinces.',
            priceBadge: 'LKR 1,500 / WK',
            ctaLabel: 'Sponsor Pin',
          ),
          const SizedBox(height: AppSpace.xl),

          // Must-See Today
          const SectionHeader(
            title: 'Must-See Today',
            subtitle: 'Top rated cultural & smart city landmarks',
          ),
          const SizedBox(height: AppSpace.md),
          SizedBox(
            height: 168,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filteredPlaces.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpace.md),
              itemBuilder: (context, index) {
                final place = filteredPlaces[index];
                return _buildMustSeeCard(context, place);
              },
            ),
          ),
          const SizedBox(height: AppSpace.xl),

          // Explore Provinces
          const SectionHeader(
            title: 'Explore Provinces',
            subtitle: 'Live regional weather & active visitor telemetry',
          ),
          const SizedBox(height: AppSpace.md),
          ..._provinces.map(
            (prov) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.md),
              child: _buildProvinceCard(context, prov),
            ),
          ),
          const SizedBox(height: AppSpace.xl),

          // AI Insights with Real Destination & Civic Photography
          const AiInsightsSection(),
          const SizedBox(height: AppSpace.xl),

          // Instagram-Style Citizen Social Feed
          const InstagramFeedSection(showStoriesRow: true),
        ],
      ),
    );
  }

  Widget _buildMustSeeCard(BuildContext context, _ExplorePlace place) {
    return SizedBox(
      width: 220,
      child: ClipRRect(
        borderRadius: AppRadius.lgBorder,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              place.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.surfaceMuted(context),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),
            Positioned(
              top: AppSpace.sm,
              right: AppSpace.sm,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.pillBorder,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppColors.warning(context),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      place.rating.toStringAsFixed(1),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: AppSpace.md,
              right: AppSpace.md,
              bottom: AppSpace.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: AppTypography.subtitle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    place.tag,
                    style: AppTypography.caption.copyWith(
                      color: Colors.white70,
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

  Widget _buildProvinceCard(BuildContext context, _ProvinceCardData prov) {
    return ClipRRect(
      borderRadius: AppRadius.lgBorder,
      child: SizedBox(
        height: 150,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              prov.coverImagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                'assets/cover.png',
                fit: BoxFit.cover,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),
            Positioned(
              top: AppSpace.md,
              left: AppSpace.md,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.pillBorder,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_outlined,
                      size: 14,
                      color: AppColors.textPrimaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      prov.tempLabel,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: AppSpace.md,
              right: AppSpace.md,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.pillBorder,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.people_outline_rounded,
                      size: 14,
                      color: AppColors.textPrimaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      prov.liveVisitors,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: AppSpace.md,
              right: AppSpace.md,
              bottom: AppSpace.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prov.name,
                    style: AppTypography.title.copyWith(color: Colors.white),
                  ),
                  Text(
                    prov.hotspot,
                    style: AppTypography.caption.copyWith(
                      color: Colors.white70,
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
}

/// Reusable Explore Cover Hero Card ("Current Location / Drizzle / 25.8°C")
/// that lives directly on the Home Screen and opens ExploreScreen when tapped.
class ExploreCoverWeatherCard extends StatelessWidget {
  final VoidCallback? onTap;
  final bool showExploreBadge;

  const ExploreCoverWeatherCard({
    super.key,
    this.onTap,
    this.showExploreBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherService>();
    final point = weather.currentWeather;
    final title = point == null
        ? 'Current Location'
        : (weather.currentLabel.isNotEmpty
              ? weather.currentLabel
              : 'Current Location');
    final subtitle = point == null
        ? 'Drizzle • Nintavur & Regional Hub'
        : WeatherService.weatherLabel(point.weatherCode);
    final tempText = point == null
        ? '25.8°C'
        : '${point.temperatureC.toStringAsFixed(1)}°C';

    return Semantics(
      label: 'Explore regions and live weather: $title, $subtitle, $tempText',
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: AppRadius.lgBorder,
          child: Container(
            height: 138,
            decoration: BoxDecoration(
              borderRadius: AppRadius.lgBorder,
              border: Border.all(color: AppColors.outline(context)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/cover.png',
                  fit: BoxFit.cover,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.62),
                      ],
                    ),
                  ),
                ),
                if (showExploreBadge)
                  Positioned(
                    top: AppSpace.md,
                    right: AppSpace.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.md,
                        vertical: AppSpace.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: AppRadius.pillBorder,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.explore_rounded,
                            size: 15,
                            color: AppColors.primary(context),
                          ),
                          const SizedBox(width: AppSpace.xs),
                          Text(
                            'Tap to Explore Regions →',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textPrimaryLight,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(AppSpace.lg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.title.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: AppTypography.body.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        tempText,
                        style: AppTypography.display.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

