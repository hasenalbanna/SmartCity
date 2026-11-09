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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.lg,
          AppSpace.md,
          AppSpace.lg,
          AppSpace.xxl,
        ),
        children: [
          // ===================================================================
          // ZONE 1: UNIFIED HEADER BAR (RESPONSIVE ZERO-OVERFLOW AT 360PX)
          // ===================================================================
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 460;
              final brandRow = Row(
                children: [
                  Builder(
                    builder: (scaffoldContext) => InkWell(
                      onTap: () => Scaffold.of(scaffoldContext).openDrawer(),
                      borderRadius: AppRadius.mdBorder,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.isDark(context)
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.05),
                          borderRadius: AppRadius.mdBorder,
                          border: Border.all(
                            color: AppColors.isDark(context)
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.black.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Icon(
                          Icons.menu_rounded,
                          size: 20,
                          color: fg,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.xs),
                  Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppRadius.mdBorder,
                      border: Border.all(color: outline),
                    ),
                    child: ClipRRect(
                      borderRadius: AppRadius.smBorder,
                      child: Image.asset(
                        'assets/images/smart_city_logo.png',
                        fit: BoxFit.contain,
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
                          '${auth.userCity}, ${auth.userCountry} • ${subService.currentPlanName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(color: muted),
                        ),
                      ],
                    ),
                  ),
                  if (!isNarrow)
                    const AppTopUtilities(
                      padding: EdgeInsets.zero,
                    ),
                ],
              );

              if (!isNarrow) return brandRow;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  brandRow,
                  const SizedBox(height: AppSpace.sm),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: AppTopUtilities(padding: EdgeInsets.zero),
                  ),
                ],
              );
            },
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
              final isCompact = constraints.maxWidth < 640;
              final experiences = [
                _QuickActionData(
                  badge: isCompact ? '#1 AI' : '#1 MOST LOVED',
                  title: isCompact ? 'AI Trip' : 'AI Trip Planner',
                  subtitle: isCompact ? 'Route & Plan' : 'Route, Hotels, SIM & Budget',
                  icon: Icons.auto_awesome_rounded,
                  isPrimaryInvert: true,
                  accentColor: AppColors.accentPurple(context),
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
                  title: isCompact ? 'Hotels' : 'Find Hotels & Stays',
                  subtitle: isCompact ? 'Book Stays' : 'Booking.com stays & map pins',
                  icon: Icons.hotel_rounded,
                  accentColor: AppColors.accentAmber(context),
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
                  title: isCompact ? 'Smart Bus' : 'Smart Bus Radar',
                  subtitle: isCompact ? 'Live ETA' : 'Routes 22 & 48 live ETA',
                  icon: Icons.directions_bus_filled_rounded,
                  accentColor: AppColors.accentTeal(context),
                  onTap: () => MainNavigationScreen.switchToTab(
                    context,
                    MainNavigationScreen.tabSmartBus,
                  ),
                ),
                _QuickActionData(
                  badge: isCompact ? 'SOS AI' : 'FALCON AI',
                  title: isCompact ? 'Falcon SOS' : 'Report & Voice SOS',
                  subtitle: isCompact ? 'Report Issue' : 'Local issues & "Hey Falcon"',
                  icon: Icons.radar_rounded,
                  accentColor: AppColors.accentRose(context),
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

              return Row(
                children: [
                  for (int i = 0; i < experiences.length; i++) ...[
                    Expanded(
                      child: _buildExperienceCard(
                        context,
                        experiences[i],
                        isCompact: isCompact,
                      ),
                    ),
                    if (i < experiences.length - 1)
                      SizedBox(width: isCompact ? AppSpace.sm : AppSpace.md),
                  ],
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
            subtitle: 'Real-time national & global smart city status at a glance',
            actionLabel: 'All Reports (${issues.length})',
            onAction: () => MainNavigationScreen.switchToTab(
              context,
              MainNavigationScreen.tabReports,
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Open Reports',
                  value: '$openIssuesCount',
                  icon: Icons.report_problem_outlined,
                  accentColor: AppColors.accentRose(context),
                  onTap: () => MainNavigationScreen.switchToTab(
                    context,
                    MainNavigationScreen.tabReports,
                  ),
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: StatTile(
                  label: 'Buses Live',
                  value: '$busesCount',
                  icon: Icons.directions_bus_outlined,
                  accentColor: AppColors.accentTeal(context),
                  onTap: () => MainNavigationScreen.switchToTab(
                    context,
                    MainNavigationScreen.tabSmartBus,
                  ),
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: StatTile(
                  label: 'Active Alerts',
                  value: '$activeAlertsCount',
                  icon: Icons.shield_outlined,
                  accentColor: AppColors.accentAmber(context),
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
          // ZONE 6: CITIZEN COMMUNITY TRAVEL GRID (MAP PATHS & STORIES)
          // ===================================================================
          const SizedBox(height: AppSpace.xl),
          const InstagramFeedSection(
            maxPosts: 4,
            showStoriesRow: true,
            preferGrid: true,
          ),

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

  Widget _buildExperienceCard(
    BuildContext context,
    _QuickActionData data, {
    bool isCompact = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = AppColors.textPrimary(context);
    final muted = AppColors.textSecondary(context);
    final accentColor = data.accentColor ?? AppColors.primary(context);

    // Adaptive card background
    final bgStart = isDark
        ? Color.lerp(const Color(0xFF131722), accentColor, 0.09)!
        : Color.lerp(Colors.white, accentColor, 0.04)!;
    final bgEnd = isDark
        ? const Color(0xFF090C12)
        : const Color(0xFFF6F8FA);

    if (isCompact) {
      return ClipRRect(
        borderRadius: AppRadius.mdBorder,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdBorder,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bgStart, bgEnd],
            ),
            border: Border.all(
              color: accentColor.withValues(alpha: isDark ? 0.35 : 0.22),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: isDark ? 0.12 : 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: data.onTap,
              borderRadius: AppRadius.mdBorder,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ExperienceCardPatternPainter(
                        color: accentColor,
                        isDark: isDark,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -6,
                    bottom: -8,
                    child: IgnorePointer(
                      child: Icon(
                        data.icon,
                        size: 44,
                        color: accentColor.withValues(alpha: isDark ? 0.08 : 0.05),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.sm,
                      vertical: AppSpace.md,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: isDark ? 0.20 : 0.12),
                            borderRadius: AppRadius.smBorder,
                            border: Border.all(
                              color: accentColor.withValues(alpha: isDark ? 0.45 : 0.30),
                            ),
                          ),
                          child: Icon(
                            data.icon,
                            color: accentColor,
                            size: 19,
                          ),
                        ),
                        const SizedBox(height: AppSpace.sm),
                        Text(
                          data.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: fg,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTypography.caption.copyWith(
                            color: muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
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

    return ClipRRect(
      borderRadius: AppRadius.lgBorder,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.lgBorder,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgStart, bgEnd],
          ),
          border: Border.all(
            color: accentColor.withValues(alpha: isDark ? 0.35 : 0.22),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: isDark ? 0.14 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: data.onTap,
            borderRadius: AppRadius.lgBorder,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _ExperienceCardPatternPainter(
                      color: accentColor,
                      isDark: isDark,
                    ),
                  ),
                ),
                Positioned(
                  right: -8,
                  bottom: -10,
                  child: IgnorePointer(
                    child: Icon(
                      data.icon,
                      size: 64,
                      color: accentColor.withValues(alpha: isDark ? 0.08 : 0.05),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpace.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: isDark ? 0.20 : 0.12),
                              borderRadius: AppRadius.smBorder,
                              border: Border.all(
                                color: accentColor.withValues(alpha: isDark ? 0.45 : 0.30),
                              ),
                            ),
                            child: Icon(
                              data.icon,
                              color: accentColor,
                              size: 21,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.sm + 2,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: isDark ? 0.22 : 0.12),
                              borderRadius: AppRadius.pillBorder,
                              border: Border.all(
                                color: accentColor.withValues(alpha: isDark ? 0.50 : 0.30),
                              ),
                            ),
                            child: Text(
                              data.badge,
                              style: AppTypography.caption.copyWith(
                                color: fg,
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                letterSpacing: 0.3,
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
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: muted,
                          fontWeight: FontWeight.w600,
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
      onTap: () => MainNavigationScreen.switchToTab(
        context,
        MainNavigationScreen.tabReports,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted(context),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.outline(context)),
            ),
            child: Icon(
              Icons.location_on_outlined,
              size: 18,
              color: fg,
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LATEST REPORT • ${issue.category.toUpperCase()} • ${_formatDate(issue.createdAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w800,
                  ),
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
          const SizedBox(width: AppSpace.xs),
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
  final Color? accentColor;
  final VoidCallback onTap;

  const _QuickActionData({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isPrimaryInvert = false,
    this.accentColor,
    required this.onTap,
  });
}

/// Custom vector painter drawing modern geometric mesh lines and ambient radar arcs.
class _ExperienceCardPatternPainter extends CustomPainter {
  final Color color;
  final bool isDark;

  _ExperienceCardPatternPainter({
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color.withValues(alpha: isDark ? 0.08 : 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 1. Concentric ambient ripples in top-right
    final center = Offset(size.width * 0.92, -10);
    for (int r = 1; r <= 3; r++) {
      canvas.drawCircle(center, r * 24.0, linePaint);
    }

    // 2. Subtle diagonal wave curve
    final path = Path();
    path.moveTo(0, size.height * 0.70);
    path.quadraticBezierTo(
      size.width * 0.50,
      size.height * 0.50,
      size.width,
      size.height * 0.85,
    );
    canvas.drawPath(path, linePaint);

    // 3. Ambient glow in top-left
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: isDark ? 0.12 : 0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: const Offset(20, 20), radius: 52));
    canvas.drawCircle(const Offset(20, 20), 52, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _ExperienceCardPatternPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isDark != isDark;
  }
}
