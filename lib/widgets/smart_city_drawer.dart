import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/community_issue.dart';
import '../screens/ai_travel_planner_screen.dart';
import '../screens/civic_alerts_screen.dart';
import '../screens/community_issues_screen.dart';
import '../screens/explore_screen.dart';
import '../screens/hotel_booking_screen.dart';
import '../screens/itinerary_screen.dart';
import '../screens/login_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/report_issue_wizard_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/sim_recommendation_screen.dart';
import '../screens/smart_bus_tracking_screen.dart';
import '../screens/system_feature_screens.dart';
import '../services/auth_service.dart';
import '../services/community_issue_service.dart';
import '../services/currency_service.dart';
import '../services/localization_service.dart';
import '../services/notification_service.dart';
import '../services/profile_service.dart';
import '../services/theme_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'emergency_beacon_modal.dart';
import 'premium_store_modal.dart';

class _DrawerCategoryMeta {
  final String title;
  final String subtitle;
  final IconData icon;

  const _DrawerCategoryMeta({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _DrawerPageItem {
  final String id;
  final String title;
  final String category;
  final IconData icon;
  final String? badge;
  final void Function(BuildContext context) onNavigate;

  const _DrawerPageItem({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    this.badge,
    required this.onNavigate,
  });
}

/// Compact Liquid-Glass Transparent Left Drawer (`width: 266`):
/// - Shows ONLY the 6 architectural categories by default.
/// - Tapping any category smoothly expands/collapses its pages.
/// - Uses BackdropFilter blur + translucent liquid glass surfaces.
class SmartCityDrawer extends StatefulWidget {
  const SmartCityDrawer({super.key});

  @override
  State<SmartCityDrawer> createState() => _SmartCityDrawerState();
}

class _SmartCityDrawerState extends State<SmartCityDrawer> {
  String? _expandedCategory;

  static const Map<String, _DrawerCategoryMeta> _categoryMeta = {
    '1. Explore & AI Trip': _DrawerCategoryMeta(
      title: 'Explore & AI Trip',
      subtitle: 'Trip Planner, Hotels, SIM & Guides',
      icon: Icons.auto_awesome_rounded,
    ),
    '2. Smart Transit & Maps': _DrawerCategoryMeta(
      title: 'Smart Transit & Maps',
      subtitle: 'Live Bus Radar, Island Map & Route',
      icon: Icons.directions_bus_filled_rounded,
    ),
    '3. Social, Chat & Saved': _DrawerCategoryMeta(
      title: 'Social, Chat & Saved',
      subtitle: 'Locals Feed, Chat, Saved & Journal',
      icon: Icons.photo_camera_back_rounded,
    ),
    '4. Civic Reports & SOS': _DrawerCategoryMeta(
      title: 'Civic Reports & SOS',
      subtitle: 'Falcon AI SOS, Reports & Alerts',
      icon: Icons.radar_rounded,
    ),
    '5. Daily Utilities': _DrawerCategoryMeta(
      title: 'Daily Utilities',
      subtitle: 'Notifications, Calendar & Clock',
      icon: Icons.calendar_month_rounded,
    ),
    '6. Profile & Settings': _DrawerCategoryMeta(
      title: 'Profile & Settings',
      subtitle: 'Home, Profile, Languages & Pro',
      icon: Icons.tune_rounded,
    ),
  };

  List<_DrawerPageItem> _buildSystemPages({
    required int pendingIssues,
    required int unreadNotifications,
    required String activeLang,
    required String activeCurrency,
  }) {
    return [
      // 1. Explore & AI Trip (6 Pages)
      _DrawerPageItem(
        id: 'itinerary_planner',
        title: 'AI Trip & Route Planner',
        category: '1. Explore & AI Trip',
        icon: Icons.auto_awesome_rounded,
        badge: '#1',
        onNavigate: (ctx) => _pushScreen(ctx, const ItineraryScreen()),
      ),
      _DrawerPageItem(
        id: 'explore',
        title: 'Explore Regions & Weather',
        category: '1. Explore & AI Trip',
        icon: Icons.explore_rounded,
        onNavigate: (ctx) => _pushScreen(ctx, const ExploreScreen()),
      ),
      _DrawerPageItem(
        id: 'hotels',
        title: 'Find Hotels & Stays',
        category: '1. Explore & AI Trip',
        icon: Icons.hotel_rounded,
        badge: '12',
        onNavigate: (ctx) => _pushScreen(ctx, const HotelBookingScreen()),
      ),
      _DrawerPageItem(
        id: 'ai_travel_planner',
        title: 'AI Day-by-Day Generator',
        category: '1. Explore & AI Trip',
        icon: Icons.event_note_rounded,
        onNavigate: (ctx) => _pushScreen(ctx, const AiTravelPlannerScreen()),
      ),
      _DrawerPageItem(
        id: 'sim_advisor',
        title: 'AI SIM & 5G Advisor',
        category: '1. Explore & AI Trip',
        icon: Icons.sim_card_rounded,
        onNavigate: (ctx) => _pushScreen(ctx, const SIMRecommendationScreen()),
      ),
      _DrawerPageItem(
        id: 'guides',
        title: 'Local Tour Guides',
        category: '1. Explore & AI Trip',
        icon: Icons.badge_outlined,
        onNavigate: (ctx) => _pushScreen(ctx, const GuidesScreen()),
      ),

      // 2. Smart Transit & Maps (3 Pages)
      _DrawerPageItem(
        id: 'smart_bus',
        title: 'Smart Bus Live Radar',
        category: '2. Smart Transit & Maps',
        icon: Icons.directions_bus_filled_rounded,
        badge: 'LIVE',
        onNavigate: (ctx) =>
            _switchOrPush(ctx, 2, const SmartBusTrackingScreen()),
      ),
      _DrawerPageItem(
        id: 'island_map',
        title: 'Interactive Island Map',
        category: '2. Smart Transit & Maps',
        icon: Icons.map_rounded,
        onNavigate: (ctx) => _pushScreen(ctx, const MapScreen()),
      ),
      _DrawerPageItem(
        id: 'live_route_engine',
        title: 'Live OSRM Drive Engine',
        category: '2. Smart Transit & Maps',
        icon: Icons.alt_route_rounded,
        onNavigate: (ctx) => _pushScreen(ctx, const ItineraryScreen()),
      ),

      // 3. Social, Chat & Saved (4 Pages)
      _DrawerPageItem(
        id: 'social_feed',
        title: 'Locals by AI Feed',
        category: '3. Social, Chat & Saved',
        icon: Icons.photo_camera_back_rounded,
        onNavigate: (ctx) => _pushScreen(ctx, const CommunityFeedScreen()),
      ),
      _DrawerPageItem(
        id: 'realtime_chat',
        title: 'Realtime Citizen Chat',
        category: '3. Social, Chat & Saved',
        icon: Icons.chat_bubble_outline_rounded,
        onNavigate: (ctx) => _pushScreen(ctx, const ChatListScreen()),
      ),
      _DrawerPageItem(
        id: 'saved',
        title: 'Saved Trips & Stays',
        category: '3. Social, Chat & Saved',
        icon: Icons.bookmarks_outlined,
        onNavigate: (ctx) => _pushScreen(ctx, const SavedScreen()),
      ),
      _DrawerPageItem(
        id: 'trip_journal',
        title: 'Trip Journal & Memories',
        category: '3. Social, Chat & Saved',
        icon: Icons.menu_book_rounded,
        onNavigate: (ctx) => _pushScreen(ctx, const TripJournalScreen()),
      ),

      // 4. Civic Reports & SOS (4 Pages)
      _DrawerPageItem(
        id: 'reports',
        title: 'Issue & Disaster Hub',
        category: '4. Civic Reports & SOS',
        icon: Icons.report_problem_rounded,
        badge: pendingIssues > 0 ? '$pendingIssues' : null,
        onNavigate: (ctx) =>
            _switchOrPush(ctx, 1, const CommunityIssuesScreen()),
      ),
      _DrawerPageItem(
        id: 'report_wizard',
        title: 'Falcon AI Voice SOS',
        category: '4. Civic Reports & SOS',
        icon: Icons.record_voice_over_rounded,
        badge: 'SOS',
        onNavigate: (ctx) => _pushScreen(ctx, const ReportIssueWizardScreen()),
      ),
      _DrawerPageItem(
        id: 'civic_alerts',
        title: 'Weather & Civic Alerts',
        category: '4. Civic Reports & SOS',
        icon: Icons.campaign_rounded,
        onNavigate: (ctx) => _pushScreen(ctx, const CivicAlertsScreen()),
      ),
      _DrawerPageItem(
        id: 'sos_beacon',
        title: 'Emergency SOS Strobe',
        category: '4. Civic Reports & SOS',
        icon: Icons.sos_rounded,
        onNavigate: (ctx) {
          Navigator.pop(ctx);
          EmergencyBeaconModal.show(ctx);
        },
      ),

      // 5. Daily Utilities (3 Pages)
      _DrawerPageItem(
        id: 'notifications',
        title: 'Notifications Inbox',
        category: '5. Daily Utilities',
        icon: Icons.notifications_active_outlined,
        badge: unreadNotifications > 0 ? '$unreadNotifications' : null,
        onNavigate: (ctx) => _pushScreen(ctx, const NotificationsScreen()),
      ),
      _DrawerPageItem(
        id: 'calendar',
        title: 'Schedule Calendar',
        category: '5. Daily Utilities',
        icon: Icons.calendar_month_rounded,
        onNavigate: (ctx) => _pushScreen(ctx, const ScheduleCalendarScreen()),
      ),
      _DrawerPageItem(
        id: 'world_clock',
        title: 'World Clock & Timer',
        category: '5. Daily Utilities',
        icon: Icons.access_time_filled_rounded,
        onNavigate: (ctx) => _pushScreen(ctx, const WorldClockScreen()),
      ),

      // 6. Profile & Settings (4 Pages)
      _DrawerPageItem(
        id: 'home',
        title: 'Smart City Home',
        category: '6. Profile & Settings',
        icon: Icons.home_rounded,
        onNavigate: (ctx) => _switchOrPush(ctx, 0, null),
      ),
      _DrawerPageItem(
        id: 'profile',
        title: 'Citizen Profile & ID',
        category: '6. Profile & Settings',
        icon: Icons.person_rounded,
        onNavigate: (ctx) => _switchOrPush(ctx, 3, const ProfileScreen()),
      ),
      _DrawerPageItem(
        id: 'settings',
        title: 'Settings & Languages',
        category: '6. Profile & Settings',
        icon: Icons.settings_rounded,
        badge: '$activeLang•$activeCurrency',
        onNavigate: (ctx) => _pushScreen(ctx, const SettingsScreen()),
      ),
      _DrawerPageItem(
        id: 'pro_store',
        title: 'Smart City Pro Store',
        category: '6. Profile & Settings',
        icon: Icons.workspace_premium_rounded,
        onNavigate: (ctx) {
          Navigator.pop(ctx);
          PremiumStoreModal.show(ctx);
        },
      ),
    ];
  }

  void _switchOrPush(BuildContext context, int tabIndex, Widget? fallback) {
    Navigator.pop(context);
    final navState =
        context.findAncestorStateOfType<State<MainNavigationScreen>>();
    if (navState != null) {
      MainNavigationScreen.switchToTab(context, tabIndex);
    } else if (fallback != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => fallback));
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainNavigationScreen(initialIndex: tabIndex),
        ),
      );
    }
  }

  void _pushScreen(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final profile = context.watch<ProfileService>();
    final issueService = context.watch<CommunityIssueService>();
    final notifService = context.watch<NotificationService>();
    final localization = context.watch<LocalizationService>();
    final currency = context.watch<CurrencyService>();
    final themeService = context.watch<ThemeService>();

    final isDark = AppColors.isDark(context);
    final fg = isDark ? Colors.white : Colors.black;
    final muted = isDark ? Colors.white70 : Colors.black54;
    final glassBorder = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.black.withValues(alpha: 0.12);
    final glassTileFill = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.04);

    final userName = profile.displayName.isNotEmpty
        ? profile.displayName
        : (auth.currentUser?.username.isNotEmpty == true
              ? auth.currentUser!.username
              : 'AL Banna');
    final avatarLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'A';

    final pendingIssues = issueService.issues
        .where((i) => i.status == IssueStatus.pending)
        .length;

    final allPages = _buildSystemPages(
      pendingIssues: pendingIssues,
      unreadNotifications: notifService.unreadCount,
      activeLang: localization.currentLanguage.toUpperCase(),
      activeCurrency: currency.currentCurrency,
    );

    final Map<String, List<_DrawerPageItem>> grouped = {};
    for (final page in allPages) {
      grouped.putIfAbsent(page.category, () => []).add(page);
    }

    return Drawer(
      width: 262,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: const BorderRadius.horizontal(
          right: Radius.circular(28),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.black.withValues(alpha: 0.58),
                        Colors.black.withValues(alpha: 0.76),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.72),
                        Colors.white.withValues(alpha: 0.88),
                      ],
              ),
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(28),
              ),
              border: Border(
                right: BorderSide(color: glassBorder, width: 1.2),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Compact Liquid Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.lg,
                      AppSpace.md,
                      AppSpace.md,
                      AppSpace.md,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: fg,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            avatarLetter,
                            style: AppTypography.subtitle.copyWith(
                              color: isDark ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpace.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.subtitle.copyWith(
                                  color: fg,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '6 Categories • 24 Pages',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Switch Theme',
                          onPressed: themeService.toggleTheme,
                          icon: Icon(
                            isDark
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            size: 20,
                            color: fg,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: glassBorder, height: 1),

                  // 2. Category-Only Liquid Accordion List
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.md,
                        vertical: AppSpace.md,
                      ),
                      children: [
                        for (final entry in grouped.entries)
                          _buildLiquidCategoryAccordion(
                            context,
                            categoryKey: entry.key,
                            items: entry.value,
                            isDark: isDark,
                            fg: fg,
                            muted: muted,
                            glassBorder: glassBorder,
                            glassTileFill: glassTileFill,
                          ),
                      ],
                    ),
                  ),

                  // 3. Compact Liquid Footer
                  Divider(color: glassBorder, height: 1),
                  Padding(
                    padding: const EdgeInsets.all(AppSpace.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              PremiumStoreModal.show(context);
                            },
                            borderRadius: AppRadius.mdBorder,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpace.sm,
                              ),
                              decoration: BoxDecoration(
                                color: fg,
                                borderRadius: AppRadius.mdBorder,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Pro Store',
                                style: AppTypography.caption.copyWith(
                                  color: isDark ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpace.sm),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              await auth.logout();
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                  (_) => false,
                                );
                              }
                            },
                            borderRadius: AppRadius.mdBorder,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpace.sm,
                              ),
                              decoration: BoxDecoration(
                                color: glassTileFill,
                                borderRadius: AppRadius.mdBorder,
                                border: Border.all(color: glassBorder),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Sign Out',
                                style: AppTypography.caption.copyWith(
                                  color: fg,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
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
        ),
      ),
    );
  }

  Widget _buildLiquidCategoryAccordion(
    BuildContext context, {
    required String categoryKey,
    required List<_DrawerPageItem> items,
    required bool isDark,
    required Color fg,
    required Color muted,
    required Color glassBorder,
    required Color glassTileFill,
  }) {
    final isExpanded = _expandedCategory == categoryKey;
    final meta = _categoryMeta[categoryKey] ??
        _DrawerCategoryMeta(
          title: categoryKey,
          subtitle: '${items.length} pages',
          icon: Icons.folder_outlined,
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedCategory = isExpanded ? null : categoryKey;
              });
            },
            borderRadius: AppRadius.mdBorder,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.md,
                vertical: AppSpace.md,
              ),
              decoration: BoxDecoration(
                color: isExpanded
                    ? (isDark
                        ? Colors.white.withValues(alpha: 0.14)
                        : Colors.black.withValues(alpha: 0.08))
                    : glassTileFill,
                borderRadius: AppRadius.mdBorder,
                border: Border.all(
                  color: isExpanded ? fg.withValues(alpha: 0.45) : glassBorder,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isExpanded ? fg : glassTileFill,
                      borderRadius: AppRadius.smBorder,
                      border: Border.all(color: glassBorder),
                    ),
                    child: Icon(
                      meta.icon,
                      size: 17,
                      color: isExpanded
                          ? (isDark ? Colors.black : Colors.white)
                          : fg,
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meta.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyStrong.copyWith(color: fg),
                        ),
                        Text(
                          meta.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(color: muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpace.xs),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: muted,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpace.md,
                top: AppSpace.xs,
              ),
              child: Column(
                children: items.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      onTap: () => item.onNavigate(context),
                      borderRadius: AppRadius.smBorder,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.md,
                          vertical: AppSpace.sm,
                        ),
                        decoration: BoxDecoration(
                          color: glassTileFill,
                          borderRadius: AppRadius.smBorder,
                          border: Border.all(color: glassBorder),
                        ),
                        child: Row(
                          children: [
                            Icon(item.icon, size: 16, color: fg),
                            const SizedBox(width: AppSpace.sm),
                            Expanded(
                              child: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(
                                  color: fg,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (item.badge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: fg,
                                  borderRadius: AppRadius.pillBorder,
                                ),
                                child: Text(
                                  item.badge!,
                                  style: AppTypography.caption.copyWith(
                                    color: isDark ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
