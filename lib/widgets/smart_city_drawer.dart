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
import '../services/subscription_service.dart';
import '../services/theme_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'emergency_beacon_modal.dart';
import 'premium_store_modal.dart';
import 'ui/ui.dart';

class _DrawerPageItem {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final IconData icon;
  final String? badge;
  final bool isDanger;
  final void Function(BuildContext context) onNavigate;

  const _DrawerPageItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    this.badge,
    this.isDanger = false,
    required this.onNavigate,
  });
}

/// Psychologically Ordered 24-Page Navigation Drawer:
/// Ordered by User Preference & Frequency of Engagement:
/// 1. Explore, AI Trip & Stays (Most Loved Aspirational & Travel Experiences)
/// 2. Smart Transit & Live Maps (Daily Habitual Mobility & GPS)
/// 3. Social Feed, Chat & Saved (Community Connection & Memories)
/// 4. Civic Reports & Falcon SOS (Safety, Hazard Reporting & Emergency)
/// 5. Minimal B&W Utilities (Fast Personal Tools: Notifications, Calendar, Clock)
/// 6. Profile, Settings & Pro Store (Account, 11 Languages, 6 Currencies & Store)
class SmartCityDrawer extends StatefulWidget {
  const SmartCityDrawer({super.key});

  @override
  State<SmartCityDrawer> createState() => _SmartCityDrawerState();
}

class _SmartCityDrawerState extends State<SmartCityDrawer> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  static const List<String> _categories = [
    'All',
    '1. Explore, AI Trip & Stays',
    '2. Smart Transit & Maps',
    '3. Social, Chat & Saved',
    '4. Civic Reports & SOS',
    '5. Minimal B&W Utilities',
    '6. Profile & Settings',
  ];

  List<_DrawerPageItem> _buildSystemPages({
    required int pendingIssues,
    required int unreadNotifications,
    required String activeLang,
    required String activeCurrency,
  }) {
    return [
      // ======================================================================
      // CATEGORY 1: EXPLORE, AI TRIP & STAYS (6 PAGES — MOST LOVED BY USERS)
      // ======================================================================
      _DrawerPageItem(
        id: 'itinerary_planner',
        title: 'Ceylon Explorer — AI Trip Planner',
        subtitle: 'Unified Route Engine, Hotels, SIM Advisor & Expense Split',
        category: '1. Explore, AI Trip & Stays',
        icon: Icons.auto_awesome_rounded,
        badge: '#1 LOVED',
        onNavigate: (ctx) => _pushScreen(ctx, const ItineraryScreen()),
      ),
      _DrawerPageItem(
        id: 'explore',
        title: 'Explore Smart Regions & Weather',
        subtitle: 'Live weather cover, Must-See landmarks & 9 provinces',
        category: '1. Explore, AI Trip & Stays',
        icon: Icons.explore_rounded,
        badge: 'HERO',
        onNavigate: (ctx) => _pushScreen(ctx, const ExploreScreen()),
      ),
      _DrawerPageItem(
        id: 'hotels',
        title: 'Find Your Perfect Stay (Hotels)',
        subtitle: 'Booking.com-style stays, map pins & room reservation',
        category: '1. Explore, AI Trip & Stays',
        icon: Icons.hotel_rounded,
        badge: '12 STAYS',
        onNavigate: (ctx) => _pushScreen(ctx, const HotelBookingScreen()),
      ),
      _DrawerPageItem(
        id: 'ai_travel_planner',
        title: 'AI Day-by-Day Itinerary Generator',
        subtitle: 'Custom Sri Lanka plan by days, budget & interests',
        category: '1. Explore, AI Trip & Stays',
        icon: Icons.event_note_rounded,
        badge: 'AI',
        onNavigate: (ctx) => _pushScreen(ctx, const AiTravelPlannerScreen()),
      ),
      _DrawerPageItem(
        id: 'sim_advisor',
        title: 'AI SIM Card & Coverage Advisor',
        subtitle: 'Dialog, Mobitel, Airtel & Hutch tourist eSIM matcher',
        category: '1. Explore, AI Trip & Stays',
        icon: Icons.sim_card_rounded,
        badge: '5G/4G',
        onNavigate: (ctx) => _pushScreen(ctx, const SIMRecommendationScreen()),
      ),
      _DrawerPageItem(
        id: 'guides',
        title: 'Certified Local Tour Guides',
        subtitle: 'Verified cultural, safari, surfing & hiking specialists',
        category: '1. Explore, AI Trip & Stays',
        icon: Icons.badge_outlined,
        badge: '6 GUIDES',
        onNavigate: (ctx) => _pushScreen(ctx, const GuidesScreen()),
      ),

      // ======================================================================
      // CATEGORY 2: SMART TRANSIT & LIVE MAPS (3 PAGES — DAILY MOBILITY)
      // ======================================================================
      _DrawerPageItem(
        id: 'smart_bus',
        title: 'Smart Bus Live Radar (Routes 22 & 48)',
        subtitle: 'Real-time bus telemetry, seat load & ETA countdown',
        category: '2. Smart Transit & Maps',
        icon: Icons.directions_bus_filled_rounded,
        badge: 'TAB 3',
        onNavigate: (ctx) =>
            _switchOrPush(ctx, 2, const SmartBusTrackingScreen()),
      ),
      _DrawerPageItem(
        id: 'island_map',
        title: 'Interactive Island & Smart City Map',
        subtitle: 'Full-screen OpenStreetMap with UNESCO & civic pins',
        category: '2. Smart Transit & Maps',
        icon: Icons.map_rounded,
        badge: 'OSM',
        onNavigate: (ctx) => _pushScreen(ctx, const MapScreen()),
      ),
      _DrawerPageItem(
        id: 'live_route_engine',
        title: 'Live OSRM Route & Drive Engine',
        subtitle: 'Multi-stop road routing, vehicle speed & fuel estimator',
        category: '2. Smart Transit & Maps',
        icon: Icons.alt_route_rounded,
        badge: 'GPS',
        onNavigate: (ctx) => _pushScreen(ctx, const ItineraryScreen()),
      ),

      // ======================================================================
      // CATEGORY 3: SOCIAL FEED, CHAT & SAVED (4 PAGES — COMMUNITY LOOP)
      // ======================================================================
      _DrawerPageItem(
        id: 'social_feed',
        title: 'Locals by AI — Instagram Feed',
        subtitle: 'Citizen stories, photo uploads, likes & comments',
        category: '3. Social, Chat & Saved',
        icon: Icons.photo_camera_back_rounded,
        badge: 'SOCIAL',
        onNavigate: (ctx) => _pushScreen(ctx, const CommunityFeedScreen()),
      ),
      _DrawerPageItem(
        id: 'realtime_chat',
        title: 'Realtime Citizen & Guide Chat',
        subtitle: 'Clean minimal B&W messaging with municipal & tour desks',
        category: '3. Social, Chat & Saved',
        icon: Icons.chat_bubble_outline_rounded,
        badge: 'MINIMAL B&W',
        onNavigate: (ctx) => _pushScreen(ctx, const ChatListScreen()),
      ),
      _DrawerPageItem(
        id: 'saved',
        title: 'Saved Trips, Places & Stays',
        subtitle: 'Bookmarked routes, heritage landmarks & luxury hotels',
        category: '3. Social, Chat & Saved',
        icon: Icons.bookmarks_outlined,
        onNavigate: (ctx) => _pushScreen(ctx, const SavedScreen()),
      ),
      _DrawerPageItem(
        id: 'trip_journal',
        title: 'Trip Journal & Field Memories',
        subtitle: 'Personal travel log, photos & route distance archive',
        category: '3. Social, Chat & Saved',
        icon: Icons.menu_book_rounded,
        onNavigate: (ctx) => _pushScreen(ctx, const TripJournalScreen()),
      ),

      // ======================================================================
      // CATEGORY 4: CIVIC REPORTS & FALCON AI SOS (4 PAGES — SAFETY & OPS)
      // ======================================================================
      _DrawerPageItem(
        id: 'reports',
        title: 'Citizen Issue & Disaster Hub',
        subtitle: '2-Mode Hub: Local Issues & Falcon AI Voice Guardian',
        category: '4. Civic Reports & SOS',
        icon: Icons.report_problem_rounded,
        badge: pendingIssues > 0 ? '$pendingIssues OPEN' : 'TAB 2',
        onNavigate: (ctx) =>
            _switchOrPush(ctx, 1, const CommunityIssuesScreen()),
      ),
      _DrawerPageItem(
        id: 'report_wizard',
        title: 'Falcon AI Voice SOS & Issue Wizard',
        subtitle: 'Say "Hey Falcon, wake up" or report local road hazards',
        category: '4. Civic Reports & SOS',
        icon: Icons.record_voice_over_rounded,
        badge: 'FALCON AI',
        isDanger: true,
        onNavigate: (ctx) => _pushScreen(ctx, const ReportIssueWizardScreen()),
      ),
      _DrawerPageItem(
        id: 'civic_alerts',
        title: 'Civic Alerts & Weather Radar',
        subtitle: '117 DMC monsoon warnings & council work orders',
        category: '4. Civic Reports & SOS',
        icon: Icons.campaign_rounded,
        badge: 'LIVE',
        onNavigate: (ctx) => _pushScreen(ctx, const CivicAlertsScreen()),
      ),
      _DrawerPageItem(
        id: 'sos_beacon',
        title: 'Emergency SOS Strobe & Hotlines',
        subtitle: '1990 Suwa Seriya, 117 DMC & instant GPS distress beacon',
        category: '4. Civic Reports & SOS',
        icon: Icons.sos_rounded,
        badge: '117 / 1990',
        isDanger: true,
        onNavigate: (ctx) {
          Navigator.pop(ctx);
          EmergencyBeaconModal.show(ctx);
        },
      ),

      // ======================================================================
      // CATEGORY 5: MINIMAL B&W DAILY UTILITIES (3 PAGES — MONOCHROME SUITE)
      // ======================================================================
      _DrawerPageItem(
        id: 'notifications',
        title: 'System Notifications & Inbox',
        subtitle: 'Clean minimal B&W alerts, work orders & bus ETA',
        category: '5. Minimal B&W Utilities',
        icon: Icons.notifications_active_outlined,
        badge: unreadNotifications > 0 ? '$unreadNotifications NEW' : 'B&W',
        onNavigate: (ctx) => _pushScreen(ctx, const NotificationsScreen()),
      ),
      _DrawerPageItem(
        id: 'calendar',
        title: 'Travel & Civic Schedule Calendar',
        subtitle: 'Clean minimal B&W 7-day planner for trips & inspections',
        category: '5. Minimal B&W Utilities',
        icon: Icons.calendar_month_rounded,
        badge: 'B&W',
        onNavigate: (ctx) => _pushScreen(ctx, const ScheduleCalendarScreen()),
      ),
      _DrawerPageItem(
        id: 'world_clock',
        title: 'World Clock & Travel Timer',
        subtitle: 'Clean minimal B&W Colombo (UTC+5:30) multi-zone clock',
        category: '5. Minimal B&W Utilities',
        icon: Icons.access_time_filled_rounded,
        badge: 'B&W',
        onNavigate: (ctx) => _pushScreen(ctx, const WorldClockScreen()),
      ),

      // ======================================================================
      // CATEGORY 6: PROFILE, SETTINGS & PRO STORE (4 PAGES — CONTROL CENTER)
      // ======================================================================
      _DrawerPageItem(
        id: 'home',
        title: 'Smart City Home Dashboard',
        subtitle: 'Calm 5-Zone Command Center & Most Popular Experiences',
        category: '6. Profile & Settings',
        icon: Icons.home_rounded,
        badge: 'TAB 1',
        onNavigate: (ctx) => _switchOrPush(ctx, 0, null),
      ),
      _DrawerPageItem(
        id: 'profile',
        title: 'Citizen Profile & Civic Hub',
        subtitle: 'Digital Citizen ID, Smart Transit Pass & evidence vault',
        category: '6. Profile & Settings',
        icon: Icons.person_rounded,
        badge: 'TAB 4',
        onNavigate: (ctx) => _switchOrPush(ctx, 3, const ProfileScreen()),
      ),
      _DrawerPageItem(
        id: 'settings',
        title: 'Settings & Smart City Control Center',
        subtitle: '11 Languages, 6 Currencies, Dark Mode & Falcon AI',
        category: '6. Profile & Settings',
        icon: Icons.settings_rounded,
        badge: '$activeLang • $activeCurrency',
        onNavigate: (ctx) => _pushScreen(ctx, const SettingsScreen()),
      ),
      _DrawerPageItem(
        id: 'pro_store',
        title: 'Smart City Pro & Revenue Storefront',
        subtitle: 'Falcon Shield+ Pro, Insurance Dossiers & Sponsored Pins',
        category: '6. Profile & Settings',
        icon: Icons.workspace_premium_rounded,
        badge: 'PRO',
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
    final subscription = context.watch<SubscriptionService>();
    final themeService = context.watch<ThemeService>();

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

    final filteredPages = allPages.where((p) {
      if (_selectedCategory != 'All' && p.category != _selectedCategory) {
        return false;
      }
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.title.toLowerCase().contains(q) ||
          p.subtitle.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
    }).toList();

    final Map<String, List<_DrawerPageItem>> grouped = {};
    for (final page in filteredPages) {
      grouped.putIfAbsent(page.category, () => []).add(page);
    }

    return Drawer(
      width: 356,
      backgroundColor: AppColors.background(context),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Drawer Architecture Header
            Container(
              padding: const EdgeInsets.all(AppSpace.lg),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                border: Border(
                  bottom: BorderSide(color: AppColors.outline(context)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary(context),
                        backgroundImage: profile.avatarBytes != null
                            ? MemoryImage(profile.avatarBytes!)
                            : null,
                        child: profile.avatarBytes == null
                            ? Text(
                                avatarLetter,
                                style: AppTypography.title.copyWith(
                                  color: AppColors.onPrimary(context),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: AppSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.subtitle.copyWith(
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                            Text(
                              '${subscription.currentPlanName} • 24 Pages by Priority',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Toggle Theme',
                        onPressed: themeService.toggleTheme,
                        icon: Icon(
                          AppColors.isDark(context)
                              ? Icons.light_mode_outlined
                              : Icons.dark_mode_outlined,
                          color: AppColors.primary(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.md),

                  // Search Box inside Drawer
                  TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: AppTypography.body.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search all 24 system pages...',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: AppColors.textSecondary(context),
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 16),
                              onPressed: () =>
                                  setState(() => _searchQuery = ''),
                            )
                          : null,
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.surfaceMuted(context),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.md,
                        vertical: AppSpace.sm,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.mdBorder,
                        borderSide: BorderSide(
                          color: AppColors.outline(context),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.mdBorder,
                        borderSide: BorderSide(
                          color: AppColors.outline(context),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.sm),

                  // Category Filter Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final selected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpace.xs),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: selected,
                            onSelected: (_) =>
                                setState(() => _selectedCategory = cat),
                            selectedColor: AppColors.primary(context),
                            backgroundColor: AppColors.surfaceMuted(context),
                            labelStyle: AppTypography.caption.copyWith(
                              color: selected
                                  ? AppColors.onPrimary(context)
                                  : AppColors.textPrimary(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Categorized System Pages List (With "Most Loved" Quick Pin Bar)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.md,
                  vertical: AppSpace.md,
                ),
                children: [
                  if (_searchQuery.isEmpty && _selectedCategory == 'All') ...[
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpace.xs,
                        bottom: AppSpace.xs,
                      ),
                      child: Text(
                        '★ MOST LOVED BY USERS (1-TAP)',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary(context),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTopFavoriteChip(
                            context,
                            icon: Icons.auto_awesome_rounded,
                            label: 'AI Trip',
                            onTap: () =>
                                _pushScreen(context, const ItineraryScreen()),
                          ),
                          const SizedBox(width: AppSpace.xs),
                          _buildTopFavoriteChip(
                            context,
                            icon: Icons.hotel_rounded,
                            label: 'Hotels',
                            onTap: () => _pushScreen(
                              context,
                              const HotelBookingScreen(),
                            ),
                          ),
                          const SizedBox(width: AppSpace.xs),
                          _buildTopFavoriteChip(
                            context,
                            icon: Icons.explore_rounded,
                            label: 'Explore',
                            onTap: () =>
                                _pushScreen(context, const ExploreScreen()),
                          ),
                          const SizedBox(width: AppSpace.xs),
                          _buildTopFavoriteChip(
                            context,
                            icon: Icons.directions_bus_filled_rounded,
                            label: 'Smart Bus',
                            onTap: () => _switchOrPush(
                              context,
                              2,
                              const SmartBusTrackingScreen(),
                            ),
                          ),
                          const SizedBox(width: AppSpace.xs),
                          _buildTopFavoriteChip(
                            context,
                            icon: Icons.radar_rounded,
                            label: 'Falcon SOS',
                            onTap: () => _pushScreen(
                              context,
                              const ReportIssueWizardScreen(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.md),
                  ],
                  for (final entry in grouped.entries) ...[
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppSpace.xs,
                        top: AppSpace.sm,
                        bottom: AppSpace.xs,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key.toUpperCase(),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary(context),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${entry.value.length} pages',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...entry.value.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.xs),
                        child: InkWell(
                          onTap: () => item.onNavigate(context),
                          borderRadius: AppRadius.mdBorder,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.md,
                              vertical: AppSpace.sm,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface(context),
                              borderRadius: AppRadius.mdBorder,
                              border: Border.all(
                                color: item.isDanger
                                    ? AppColors.danger(
                                        context,
                                      ).withValues(alpha: 0.35)
                                    : AppColors.outline(context),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: item.isDanger
                                        ? AppColors.danger(
                                            context,
                                          ).withValues(alpha: 0.12)
                                        : AppColors.primary(
                                            context,
                                          ).withValues(alpha: 0.12),
                                    borderRadius: AppRadius.smBorder,
                                  ),
                                  child: Icon(
                                    item.icon,
                                    size: 18,
                                    color: item.isDanger
                                        ? AppColors.danger(context)
                                        : AppColors.primary(context),
                                  ),
                                ),
                                const SizedBox(width: AppSpace.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.bodyStrong
                                            .copyWith(
                                              color: AppColors.textPrimary(
                                                context,
                                              ),
                                            ),
                                      ),
                                      Text(
                                        item.subtitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.caption.copyWith(
                                          color: AppColors.textSecondary(
                                            context,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (item.badge != null) ...[
                                  const SizedBox(width: AppSpace.xs),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item.isDanger
                                          ? AppColors.danger(
                                              context,
                                            ).withValues(alpha: 0.14)
                                          : AppColors.primary(
                                              context,
                                            ).withValues(alpha: 0.12),
                                      borderRadius: AppRadius.smBorder,
                                    ),
                                    child: Text(
                                      item.badge!,
                                      style: AppTypography.caption.copyWith(
                                        color: item.isDanger
                                            ? AppColors.danger(context)
                                            : AppColors.primary(context),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpace.sm),
                  ],
                ],
              ),
            ),

            // 3. Drawer Footer: Quick Pro Upgrade & Sign Out
            Container(
              padding: const EdgeInsets.all(AppSpace.md),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                border: Border(
                  top: BorderSide(color: AppColors.outline(context)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Pro Store',
                      icon: Icons.workspace_premium_rounded,
                      variant: AppButtonVariant.secondary,
                      onPressed: () {
                        Navigator.pop(context);
                        PremiumStoreModal.show(context);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: AppButton(
                      label: 'Sign Out',
                      icon: Icons.logout_rounded,
                      variant: AppButtonVariant.ghost,
                      onPressed: () async {
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

  Widget _buildTopFavoriteChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.pillBorder,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.md,
          vertical: AppSpace.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: AppRadius.pillBorder,
          border: Border.all(color: AppColors.outline(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.primary(context)),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
