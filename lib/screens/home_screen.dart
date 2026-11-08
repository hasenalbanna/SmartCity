import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ai_hazard_analysis.dart';
import '../models/community_issue.dart';
import '../services/auth_service.dart';
import '../services/community_issue_service.dart';
import '../services/profile_service.dart';
import '../services/smart_bus_service.dart';
import '../services/subscription_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/ai_insights_section.dart';
import '../widgets/app_top_utilities.dart';
import '../widgets/instagram_feed_section.dart';
import '../widgets/premium_store_modal.dart';
import '../widgets/smart_city_drawer.dart';
import '../widgets/ui/ui.dart';
import 'civic_alerts_screen.dart';
import 'explore_screen.dart';
import 'hotel_booking_screen.dart';
import 'itinerary_screen.dart';
import 'main_navigation_screen.dart';
import 'report_issue_wizard_screen.dart';
import 'sim_recommendation_screen.dart';
import 'system_feature_screens.dart';

/// Psychologically Engineered Monochrome Luxury Home Screen:
/// - Background: Plain Deep Black (#000000) with a subtle obsidian/charcoal
///   gradient (#000000 -> #0A0A0D -> #141419).
/// - Palette: Zero blue — strictly Black, White, Platinum, and Obsidian Grays.
/// - 5-Zone Cognitive Architecture:
///   1. Single Unified Header Row ([☰ Menu] + Greeting | 5 Minimal Utilities) + Search Bar
///   2. Ambient Hero Cover (`ExploreCoverWeatherCard`)
///   3. Miller's Law "Most-Loved 4" Experience Grid (AI Trip, Hotels, Smart Bus, Falcon SOS)
///   4. Picture Superiority `AI Insights` Real Photography Carousel
///   5. Live City Pulse + Citizen Social Feed + Executive Pro Footer Card
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatDate(DateTime dt) => '${dt.month}/${dt.day}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final issueService = context.watch<CommunityIssueService>();
    final busService = context.watch<SmartBusService>();
    final auth = context.watch<AuthService>();
    final profileService = context.watch<ProfileService>();
    final subService = context.watch<SubscriptionService>();

    final issues = issueService.issues;
    final openIssuesCount =
        issues.where((i) => i.status != IssueStatus.resolved).length;
    final busesCount = busService.buses.length;
    final activeAlertsCount = issues
        .where(
          (i) =>
              (i.aiAnalysis?.urgencyScore ?? 0) >= 7.5 ||
              i.aiAnalysis?.routingChannel == AiRoutingChannel.areaAlert ||
              i.aiAnalysis?.routingChannel == AiRoutingChannel.councilTicket,
        )
        .length;

    final userName = auth.currentUser?.username.isNotEmpty == true
        ? auth.currentUser!.username
        : (profileService.displayName.isNotEmpty
              ? profileService.displayName.split(' ').first
              : 'AL');

    final latestIssue = issues.isNotEmpty ? issues.first : null;
    final fg = AppColors.textPrimary(context);
    final muted = AppColors.textSecondary(context);
    final surface = AppColors.surface(context);
    final surfaceMuted = AppColors.surfaceMuted(context);
    final outline = AppColors.outline(context);

    return AppScaffold(
      drawer: const SmartCityDrawer(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.lg,
          AppSpace.md,
          AppSpace.lg,
          AppSpace.xxl,
        ),
        children: [
          // ===================================================================
          // ZONE 1: UNIFIED SINGLE HEADER BAR (MONOCHROME BLACK / WHITE / GRAY)
          // ===================================================================
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Builder(
                builder: (scaffoldContext) => InkWell(
                  onTap: () => Scaffold.of(scaffoldContext).openDrawer(),
                  borderRadius: AppRadius.mdBorder,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: AppRadius.mdBorder,
                      border: Border.all(color: outline),
                    ),
                    child: Icon(
                      Icons.menu_rounded,
                      size: 22,
                      color: fg,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $userName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title.copyWith(color: fg),
                    ),
                    Text(
                      'Nintavur • ${subService.currentPlanName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              const AppTopUtilities(
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),

          // Instant Monochrome Search / 24-Page Quick Jump Bar
          Builder(
            builder: (scaffoldContext) => InkWell(
              onTap: () => Scaffold.of(scaffoldContext).openDrawer(),
              borderRadius: AppRadius.pillBorder,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.lg,
                  vertical: AppSpace.md,
                ),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: AppRadius.pillBorder,
                  border: Border.all(color: outline),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: fg,
                    ),
                    const SizedBox(width: AppSpace.sm),
                    Expanded(
                      child: Text(
                        'Search destinations, hotels, AI planner, or 24 pages...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body.copyWith(color: muted),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: fg,
                        borderRadius: AppRadius.pillBorder,
                      ),
                      child: Text(
                        'All 24',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onPrimary(context),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.lg),

          // ===================================================================
          // ZONE 2: VISCERAL HERO ANCHOR — EXPLORE & LIVE WEATHER COVER CARD
          // ===================================================================
          ExploreCoverWeatherCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExploreScreen()),
              );
            },
          ),
          const SizedBox(height: AppSpace.xl),

          // ===================================================================
          // ZONE 3: MILLER'S LAW "MOST-LOVED 4" MONOCHROME EXPERIENCE HUB
          // ===================================================================
          const SectionHeader(
            title: 'Most Popular Experiences',
            subtitle: 'Ranked by what citizens & travelers use most every day',
          ),
          const SizedBox(height: AppSpace.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 640;
              final experiences = [
                _QuickActionData(
                  badge: '#1 MOST LOVED',
                  title: 'AI Trip Planner',
                  subtitle: 'Route, Hotels, SIM & Budget',
                  icon: Icons.auto_awesome_rounded,
                  isPrimaryInvert: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ItineraryScreen(),
                      ),
                    );
                  },
                ),
                _QuickActionData(
                  badge: '12 STAYS',
                  title: 'Find Hotels & Stays',
                  subtitle: 'Booking.com stays & map pins',
                  icon: Icons.hotel_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HotelBookingScreen(),
                      ),
                    );
                  },
                ),
                _QuickActionData(
                  badge: 'LIVE GPS',
                  title: 'Smart Bus Radar',
                  subtitle: 'Routes 22 & 48 live ETA',
                  icon: Icons.directions_bus_filled_rounded,
                  onTap: () => MainNavigationScreen.switchToTab(context, 2),
                ),
                _QuickActionData(
                  badge: 'FALCON AI',
                  title: 'Report & Voice SOS',
                  subtitle: 'Local issues & "Hey Falcon"',
                  icon: Icons.radar_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReportIssueWizardScreen(),
                      ),
                    );
                  },
                ),
              ];

              if (isWide) {
                return Row(
                  children: [
                    for (int i = 0; i < experiences.length; i++) ...[
                      Expanded(
                        child: _buildExperienceCard(context, experiences[i]),
                      ),
                      if (i < experiences.length - 1)
                        const SizedBox(width: AppSpace.md),
                    ],
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildExperienceCard(context, experiences[0]),
                      ),
                      const SizedBox(width: AppSpace.md),
                      Expanded(
                        child: _buildExperienceCard(context, experiences[1]),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.md),
                  Row(
                    children: [
                      Expanded(
                        child: _buildExperienceCard(context, experiences[2]),
                      ),
                      const SizedBox(width: AppSpace.md),
                      Expanded(
                        child: _buildExperienceCard(context, experiences[3]),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpace.md),

          // Secondary Fast-Access Monochrome Pill Strip
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickPill(
                  context,
                  icon: Icons.sim_card_outlined,
                  label: 'AI SIM Advisor',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SIMRecommendationScreen(),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                _buildQuickPill(
                  context,
                  icon: Icons.map_outlined,
                  label: 'Full Island Map',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MapScreen()),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                _buildQuickPill(
                  context,
                  icon: Icons.badge_outlined,
                  label: 'Local Tour Guides',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GuidesScreen()),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                _buildQuickPill(
                  context,
                  icon: Icons.bookmarks_outlined,
                  label: 'Saved Places',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SavedScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.xl),

          // ===================================================================
          // ZONE 4: PICTURE SUPERIORITY EFFECT — AI INSIGHTS PHOTO CAROUSEL
          // ===================================================================
          const AiInsightsSection(),
          const SizedBox(height: AppSpace.xl),

          // ===================================================================
          // ZONE 5: PROGRESSIVE DISCLOSURE — MONOCHROME LIVE CITY PULSE
          // ===================================================================
          SectionHeader(
            title: 'Live City Pulse',
            subtitle: 'Real-time Nintavur civic status at a glance',
            actionLabel: 'All Reports (${issues.length})',
            onAction: () => MainNavigationScreen.switchToTab(context, 1),
          ),
          const SizedBox(height: AppSpace.md),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Open Reports',
                  value: '$openIssuesCount',
                  icon: Icons.report_problem_outlined,
                  accentColor: fg,
                  onTap: () => MainNavigationScreen.switchToTab(context, 1),
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: StatTile(
                  label: 'Buses Live',
                  value: '$busesCount',
                  icon: Icons.directions_bus_outlined,
                  accentColor: fg,
                  onTap: () => MainNavigationScreen.switchToTab(context, 2),
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: StatTile(
                  label: 'Active Alerts',
                  value: '$activeAlertsCount',
                  icon: Icons.shield_outlined,
                  accentColor: fg,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CivicAlertsScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (latestIssue != null) ...[
            const SizedBox(height: AppSpace.md),
            _buildCleanLatestIssueBanner(context, latestIssue),
          ],

          // ===================================================================
          // ZONE 6: SOCIAL PROOF — LOCALS BY AI (COMPACT PREVIEW)
          // ===================================================================
          const SizedBox(height: AppSpace.xl),
          const InstagramFeedSection(maxPosts: 2, showStoriesRow: true),

          // ===================================================================
          // ZONE 7: EXECUTIVE MONOCHROME PRO STOREFRONT CARD AT FOOTER
          // ===================================================================
          const SizedBox(height: AppSpace.xl),
          InkWell(
            onTap: () => PremiumStoreModal.show(context),
            borderRadius: AppRadius.lgBorder,
            child: Container(
              padding: const EdgeInsets.all(AppSpace.lg),
              decoration: BoxDecoration(
                color: surfaceMuted,
                borderRadius: AppRadius.lgBorder,
                border: Border.all(color: fg.withValues(alpha: 0.45)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: fg,
                      borderRadius: AppRadius.mdBorder,
                    ),
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.onPrimary(context),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subService.isProOrHigher
                              ? '${subService.currentPlanName} Active'
                              : 'Upgrade to Falcon Shield+ Pro',
                          style: AppTypography.subtitle.copyWith(color: fg),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '24/7 voice SOS guardian, insurance dossiers & priority alerts.',
                          style: AppTypography.caption.copyWith(color: muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.md,
                      vertical: AppSpace.xs,
                    ),
                    decoration: BoxDecoration(
                      color: fg,
                      borderRadius: AppRadius.pillBorder,
                    ),
                    child: Text(
                      'Open Pro',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onPrimary(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(BuildContext context, _QuickActionData data) {
    final fg = AppColors.textPrimary(context);
    final muted = AppColors.textSecondary(context);
    final surface = AppColors.surface(context);
    final surfaceMuted = AppColors.surfaceMuted(context);
    final outline = AppColors.outline(context);
    final onPrimary = AppColors.onPrimary(context);

    return InkWell(
      onTap: data.onTap,
      borderRadius: AppRadius.lgBorder,
      child: Container(
        padding: const EdgeInsets.all(AppSpace.lg),
        decoration: BoxDecoration(
          color: data.isPrimaryInvert ? surfaceMuted : surface,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(
            color: data.isPrimaryInvert ? fg.withValues(alpha: 0.65) : outline,
            width: data.isPrimaryInvert ? 1.4 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: data.isPrimaryInvert ? fg : surfaceMuted,
                    borderRadius: AppRadius.smBorder,
                    border: Border.all(color: outline),
                  ),
                  child: Icon(
                    data.icon,
                    color: data.isPrimaryInvert ? onPrimary : fg,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: data.isPrimaryInvert ? fg : surfaceMuted,
                    borderRadius: AppRadius.pillBorder,
                    border: Border.all(color: outline),
                  ),
                  child: Text(
                    data.badge,
                    style: AppTypography.caption.copyWith(
                      color: data.isPrimaryInvert ? onPrimary : fg,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.md),
            Text(
              data.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.subtitle.copyWith(
                color: fg,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              data.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.caption.copyWith(color: muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final fg = AppColors.textPrimary(context);
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.pillBorder,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.md,
          vertical: AppSpace.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: AppRadius.pillBorder,
          border: Border.all(color: AppColors.outline(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: AppSpace.xs),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanLatestIssueBanner(
    BuildContext context,
    CommunityIssue issue,
  ) {
    final fg = AppColors.textPrimary(context);
    final muted = AppColors.textSecondary(context);
    return AppCard(
      onTap: () => MainNavigationScreen.switchToTab(context, 1),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted(context),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outline(context)),
            ),
            child: Icon(
              Icons.location_on_outlined,
              size: 20,
              color: fg,
            ),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'LATEST REPORT • ${issue.category.toUpperCase()}',
                      style: AppTypography.caption.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(issue.createdAt),
                      style: AppTypography.caption.copyWith(color: muted),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  issue.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subtitle.copyWith(color: fg),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          StatusChip.fromIssueStatus(issue.status),
        ],
      ),
    );
  }
}

class _QuickActionData {
  final String badge;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPrimaryInvert;
  final VoidCallback onTap;

  const _QuickActionData({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isPrimaryInvert = false,
    required this.onTap,
  });
}
