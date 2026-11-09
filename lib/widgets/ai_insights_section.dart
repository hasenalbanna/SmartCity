import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'ui/ui.dart';

class AiInsightItem {
  final String category;
  final String location;
  final String recommendation;
  final String detailedForecast;
  final String imagePath;
  final IconData icon;
  final String confidenceBadge;

  const AiInsightItem({
    required this.category,
    required this.location,
    required this.recommendation,
    required this.detailedForecast,
    required this.imagePath,
    required this.icon,
    required this.confidenceBadge,
  });
}

/// Horizontal carousel of AI Insights cards featuring real high-resolution
/// destination & civic photography, glassmorphic badges, and interactive detail sheets.
class AiInsightsSection extends StatelessWidget {
  const AiInsightsSection({super.key});

  static const List<AiInsightItem> insights = [
    AiInsightItem(
      category: 'Best Time to Visit',
      location: 'Sigiriya',
      recommendation: '6:00 AM - Beat the crowds',
      detailedForecast:
          'Falcon AI crowd telemetry predicts 72% lower queue times between 6:00 AM and 8:15 AM. UV index remains low (2.4) with clear morning visibility at Lion Rock.',
      imagePath: 'assets/images/sigiriya.jpg',
      icon: Icons.access_time_filled_rounded,
      confidenceBadge: '98% AI Match',
    ),
    AiInsightItem(
      category: 'Weather Alert',
      location: 'Ella Region',
      recommendation: 'Light rain expected',
      detailedForecast:
          'Mountain mist and light afternoon showers (4.2 mm) expected near Nine Arch Bridge & Ella Rock after 2:30 PM. Morning hikes remain clear and safe.',
      imagePath: 'assets/images/nine_arch_bridge.jpg',
      icon: Icons.cloud_rounded,
      confidenceBadge: 'Live Radar',
    ),
    AiInsightItem(
      category: 'Local Festival',
      location: 'Kandy',
      recommendation: 'Perahera this weekend',
      detailedForecast:
          'Cultural procession routes around Temple of the Sacred Tooth Relic are active this evening. Smart Bus express shuttles are operating every 10 minutes.',
      imagePath: 'assets/central province/temple of tooth.jpg',
      icon: Icons.celebration_rounded,
      confidenceBadge: 'Cultural Event',
    ),
    AiInsightItem(
      category: 'Coastal Conditions',
      location: 'Nintavur & Arugam Bay',
      recommendation: 'Calm tide • Ideal coastal drive',
      detailedForecast:
          'Eastern coastal sensors report 0.6m gentle swell, 28.5°C sea breeze, and clear drainage canals across Nintavur Marine Drive.',
      imagePath: 'assets/eastern province/arugam bay.jpg',
      icon: Icons.waves_rounded,
      confidenceBadge: '96% Safe Tide',
    ),
    AiInsightItem(
      category: 'Heritage Walk',
      location: 'Galle Fort',
      recommendation: '5:15 PM - Golden hour ramparts',
      detailedForecast:
          'Low pedestrian density along the western ramparts with a 19 km/h cooling sea breeze before sunset.',
      imagePath: 'assets/images/galle_fort.jpg',
      icon: Icons.wb_twilight_rounded,
      confidenceBadge: 'Golden Hour',
    ),
  ];

  static const List<AiInsightItem> usInsights = [
    AiInsightItem(
      category: 'Best Time to Visit',
      location: 'Central Park & Midtown',
      recommendation: '7:30 AM - Beat the morning rush',
      detailedForecast:
          'Falcon AI pedestrian sensors indicate 68% lower foot traffic across Central Park Promenade before 8:30 AM. Clear sky conditions and mild morning breeze.',
      imagePath:
          'https://images.unsplash.com/photo-1538688525198-9b88f6f53126?w=800&auto=format&fit=crop&q=80',
      icon: Icons.access_time_filled_rounded,
      confidenceBadge: '98% AI Match',
    ),
    AiInsightItem(
      category: 'Weather Alert',
      location: 'New York Metro Area',
      recommendation: 'Clear skies • Moderate 21°C',
      detailedForecast:
          'Hudson River coastal telemetry confirms calm winds (12 km/h) and optimal visibility across Brooklyn Bridge and Manhattan transit corridors.',
      imagePath:
          'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=800&auto=format&fit=crop&q=80',
      icon: Icons.wb_sunny_rounded,
      confidenceBadge: 'Live Radar',
    ),
    AiInsightItem(
      category: 'Transit Update',
      location: 'Manhattan & Queens Line',
      recommendation: 'Express shuttles on schedule',
      detailedForecast:
          'Subway and city bus telemetry reporting 99.4% on-time performance across Atlantic Ave and Grand Central terminals.',
      imagePath:
          'https://images.unsplash.com/photo-1518391846015-55a9cc003b25?w=800&auto=format&fit=crop&q=80',
      icon: Icons.directions_bus_rounded,
      confidenceBadge: 'Smart Transit',
    ),
    AiInsightItem(
      category: 'Civic Priority',
      location: 'Brooklyn Civic Corridor',
      recommendation: 'Zero active flood alerts',
      detailedForecast:
          'Drainage pumps and municipal storm sensors operating normally across Kings County municipal district.',
      imagePath:
          'https://images.unsplash.com/photo-1485871981521-5b1fd3805eee?w=800&auto=format&fit=crop&q=80',
      icon: Icons.check_circle_rounded,
      confidenceBadge: '99% Clear',
    ),
  ];

  static const List<AiInsightItem> ukInsights = [
    AiInsightItem(
      category: 'Best Time to Visit',
      location: 'Westminster & Thames Walk',
      recommendation: '8:00 AM - Uncrowded riverbanks',
      detailedForecast:
          'Pedestrian density along the Thames Path and Elizabeth Tower is minimal before 9:00 AM with fresh riverside breeze.',
      imagePath:
          'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=800&auto=format&fit=crop&q=80',
      icon: Icons.access_time_filled_rounded,
      confidenceBadge: '95% AI Match',
    ),
    AiInsightItem(
      category: 'Transit Update',
      location: 'London Underground & Bus',
      recommendation: 'TfL network operating normally',
      detailedForecast:
          'Jubilee and Central lines reporting on-schedule frequency with real-time contactless bus sync at London Bridge.',
      imagePath:
          'https://images.unsplash.com/photo-1486299267070-83823f5448dd?w=800&auto=format&fit=crop&q=80',
      icon: Icons.directions_bus_rounded,
      confidenceBadge: 'TfL Status',
    ),
  ];

  static const List<AiInsightItem> jpInsights = [
    AiInsightItem(
      category: 'Best Time to Visit',
      location: 'Shinjuku Gyoen & Meiji Jingu',
      recommendation: '7:00 AM - Quiet temple grounds',
      detailedForecast:
          'Crowd prediction shows peaceful atmosphere and optimal photography light across forested pathways.',
      imagePath:
          'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800&auto=format&fit=crop&q=80',
      icon: Icons.access_time_filled_rounded,
      confidenceBadge: '97% AI Match',
    ),
    AiInsightItem(
      category: 'Transit Update',
      location: 'Yamanote & Chuo Lines',
      recommendation: 'Shinkansen & Metro on time',
      detailedForecast:
          'Telemetry records 99.9% transit precision across Shinjuku, Shibuya, and Tokyo Station hubs.',
      imagePath:
          'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=800&auto=format&fit=crop&q=80',
      icon: Icons.directions_transit_rounded,
      confidenceBadge: 'Smart Transit',
    ),
  ];

  static List<AiInsightItem> getInsights(String country) {
    final c = country.toLowerCase();
    if (c.contains('united states') ||
        c.contains('america') ||
        c.contains('usa') ||
        c == 'us') {
      return usInsights;
    }
    if (c.contains('united kingdom') ||
        c.contains('britain') ||
        c.contains('england') ||
        c.contains('london') ||
        c == 'uk' ||
        c == 'gb') {
      return ukInsights;
    }
    if (c.contains('japan') || c.contains('tokyo') || c == 'jp') {
      return jpInsights;
    }
    return insights;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final activeList = getInsights(auth.userCountry);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'AI Insights',
          subtitle: 'Real-time Falcon AI crowd, weather & cultural intelligence',
          actionLabel: 'See All',
          onAction: () => _showAllInsightsModal(context, activeList),
        ),
        const SizedBox(height: AppSpace.md),
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: activeList.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpace.md),
            itemBuilder: (context, index) {
              final item = activeList[index];
              return _AiInsightPhotoCard(
                item: item,
                onTap: () => _showInsightDetailModal(context, item),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showInsightDetailModal(BuildContext context, AiInsightItem item) {
    final auth = context.read<AuthService>();
    showModalBottomSheet<void>(
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
              ClipRRect(
                borderRadius: AppRadius.lgBorder,
                child: SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AdaptiveDestinationImage(
                        imageUrl: item.imagePath,
                        country: auth.userCountry,
                        placeName: item.location,
                        category: item.category,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.black.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: AppSpace.md,
                        left: AppSpace.md,
                        child: StatusChip(
                          label: item.confidenceBadge,
                          kind: StatusChipKind.info,
                          icon: Icons.auto_awesome_rounded,
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
                              item.category,
                              style: AppTypography.caption.copyWith(
                                color: Colors.white70,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              item.location,
                              style: AppTypography.title.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              Row(
                children: [
                  Icon(item.icon, color: AppColors.primary(ctx), size: 20),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: Text(
                      item.recommendation,
                      style: AppTypography.subtitle.copyWith(
                        color: AppColors.textPrimary(ctx),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.sm),
              Text(
                item.detailedForecast,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary(ctx),
                ),
              ),
              const SizedBox(height: AppSpace.xl),
              AppButton(
                label: 'Got It',
                icon: Icons.check_circle_outline_rounded,
                fullWidth: true,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAllInsightsModal(BuildContext context, List<AiInsightItem> list) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.78,
          maxChildSize: 0.94,
          minChildSize: 0.5,
          builder: (_, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.all(AppSpace.xl),
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.primary(ctx),
                    ),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: Text(
                        'All Live AI Insights',
                        style: AppTypography.title.copyWith(
                          color: AppColors.textPrimary(ctx),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.md),
                ...list.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpace.md),
                    child: SizedBox(
                      height: 170,
                      child: _AiInsightPhotoCard(
                        item: item,
                        fullWidth: true,
                        onTap: () {
                          Navigator.pop(ctx);
                          _showInsightDetailModal(context, item);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AiInsightPhotoCard extends StatelessWidget {
  final AiInsightItem item;
  final VoidCallback onTap;
  final bool fullWidth;

  const _AiInsightPhotoCard({
    required this.item,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return SizedBox(
      width: fullWidth ? double.infinity : 205,
      child: ClipRRect(
        borderRadius: AppRadius.lgBorder,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Real High-Resolution Destination Image with Zero-Storage Country Fallback
                AdaptiveDestinationImage(
                  imageUrl: item.imagePath,
                  country: auth.userCountry,
                  placeName: item.location,
                  category: item.category,
                ),
                // Rich Cinematic Scrim Overlay for Crisp Text Readability
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.20),
                        Colors.black.withValues(alpha: 0.55),
                        Colors.black.withValues(alpha: 0.88),
                      ],
                      stops: const [0.0, 0.48, 1.0],
                    ),
                  ),
                ),
                // Top Row: Glass Icon Container + AI Badge
                Positioned(
                  top: AppSpace.md,
                  left: AppSpace.md,
                  right: AppSpace.md,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: AppRadius.smBorder,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.28),
                          ),
                        ),
                        child: Icon(
                          item.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.52),
                          borderRadius: AppRadius.pillBorder,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.24),
                          ),
                        ),
                        child: Text(
                          item.confidenceBadge,
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom Text Content: Category, Location, Recommendation
                Positioned(
                  left: AppSpace.md,
                  right: AppSpace.md,
                  bottom: AppSpace.md,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.recommendation,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: Colors.white.withValues(alpha: 0.90),
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
