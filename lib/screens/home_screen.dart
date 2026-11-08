import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/ai_hazard_analysis.dart';
import '../models/community_issue.dart';
import '../services/auth_service.dart';
import '../services/community_issue_service.dart';
import '../services/profile_service.dart';
import '../services/smart_bus_service.dart';
import '../services/subscription_service.dart';
import '../services/theme_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/emergency_beacon_modal.dart';
import '../widgets/premium_store_modal.dart';
import '../widgets/ui/ui.dart';
import 'civic_alerts_screen.dart';
import 'explore_screen.dart';
import 'main_navigation_screen.dart';
import 'report_issue_wizard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const LatLng _nintavurCenter = LatLng(7.3486, 81.8475);

  String _formatDate(DateTime dt) => '${dt.month}/${dt.day}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final issueService = context.watch<CommunityIssueService>();
    final busService = context.watch<SmartBusService>();
    final auth = context.watch<AuthService>();
    final profileService = context.watch<ProfileService>();
    final themeService = context.watch<ThemeService>();
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

    return AppScaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ReportIssueWizardScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Report Issue'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.lg,
          AppSpace.lg,
          AppSpace.lg,
          96,
        ),
        children: [
          // 1. Header: Greeting + Pro Plan Pill + Theme Toggle
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $userName',
                      style: AppTypography.display.copyWith(
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: AppColors.primary(context),
                        ),
                        const SizedBox(width: AppSpace.xs),
                        Flexible(
                          child: Text(
                            'Nintavur Smart Municipality • ${subService.currentPlanName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              AppButton(
                label: subService.isProOrHigher ? 'Pro Hub' : 'Upgrade Pro',
                icon: Icons.workspace_premium_rounded,
                variant: AppButtonVariant.secondary,
                onPressed: () => PremiumStoreModal.show(context),
              ),
              const SizedBox(width: AppSpace.xs),
              Semantics(
                label: 'Toggle light and dark theme',
                button: true,
                child: IconButton(
                  tooltip: 'Switch Theme',
                  onPressed: themeService.toggleTheme,
                  icon: Icon(
                    AppColors.isDark(context)
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),

          // 2. Explore Cover Weather Hero Card (Current Location / Drizzle / 25.8°C -> opens ExploreScreen)
          ExploreCoverWeatherCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ExploreScreen()),
              );
            },
          ),
          const SizedBox(height: AppSpace.md),

          // 2.5 Live City Sensor & Telemetry Strip
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                StatusChip(
                  label: '29°C • Coastal Breeze',
                  kind: StatusChipKind.info,
                  icon: Icons.wb_cloudy_outlined,
                ),
                SizedBox(width: AppSpace.sm),
                StatusChip(
                  label: 'AQI 32 • Clean Air',
                  kind: StatusChipKind.resolved,
                  icon: Icons.air_rounded,
                ),
                SizedBox(width: AppSpace.sm),
                StatusChip(
                  label: 'Falcon AI • Online',
                  kind: StatusChipKind.inProgress,
                  icon: Icons.radar_rounded,
                ),
                SizedBox(width: AppSpace.sm),
                StatusChip(
                  label: 'Grid 94% Active',
                  kind: StatusChipKind.neutral,
                  icon: Icons.bolt_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.lg),

          // 3. Live City KPI StatTiles (3 columns)
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Open Reports',
                  value: '$openIssuesCount',
                  icon: Icons.report_problem_outlined,
                  accentColor: AppColors.danger(context),
                  onTap: () => MainNavigationScreen.switchToTab(context, 1),
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: StatTile(
                  label: 'Buses Live',
                  value: '$busesCount',
                  icon: Icons.directions_bus_outlined,
                  accentColor: AppColors.primary(context),
                  onTap: () => MainNavigationScreen.switchToTab(context, 2),
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: StatTile(
                  label: 'Active Alerts',
                  value: '$activeAlertsCount',
                  icon: Icons.shield_outlined,
                  accentColor: AppColors.warning(context),
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
          const SizedBox(height: AppSpace.lg),

          // 4. Premium Falcon Shield+ & B2B Monetization Banner
          const PremiumUpsellBanner(
            title:
                'Falcon Shield+ Pro & B2B Map Sponsorships Now Available',
            subtitle:
                'Get 24/7 "Hey Falcon" voice SOS guardian, Insurance Claim PDFs (LKR 450), or sponsor your shop on the live city map.',
            priceBadge: 'PRO & ADD-ONS',
            ctaLabel: 'Explore Store',
          ),
          const SizedBox(height: AppSpace.xl),

          // 5. Quick Civic Actions Grid (2x2)
          const SectionHeader(
            title: 'Quick Actions',
            subtitle:
                'Report local issues, wake Falcon AI for disasters, or track buses',
          ),
          const SizedBox(height: AppSpace.md),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 640;
              final actions = [
                _QuickActionData(
                  title: '1. Local Issues',
                  subtitle: 'Roads, drainage, streetlights',
                  icon: Icons.construction_rounded,
                  color: AppColors.primary(context),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReportIssueWizardScreen(
                          initialModeIndex: 0,
                        ),
                      ),
                    );
                  },
                ),
                _QuickActionData(
                  title: '2. Falcon AI Disaster',
                  subtitle: 'Say "Hey Falcon, wake up"',
                  icon: Icons.radar_rounded,
                  color: AppColors.danger(context),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReportIssueWizardScreen(
                          initialModeIndex: 1,
                        ),
                      ),
                    );
                  },
                ),
                _QuickActionData(
                  title: 'Track Smart Bus',
                  subtitle: 'Live GPS routes 22 & 48',
                  icon: Icons.directions_bus_filled_outlined,
                  color: AppColors.success(context),
                  onTap: () => MainNavigationScreen.switchToTab(context, 2),
                ),
                _QuickActionData(
                  title: 'Visual SOS Strobe',
                  subtitle: 'High-visibility rescue beacon',
                  icon: Icons.sos_rounded,
                  color: AppColors.warning(context),
                  onTap: () => EmergencyBeaconModal.show(context),
                ),
              ];

              if (isWide) {
                return Row(
                  children: [
                    for (int i = 0; i < actions.length; i++) ...[
                      Expanded(
                        child: _buildQuickActionCard(context, actions[i]),
                      ),
                      if (i < actions.length - 1)
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
                        child: _buildQuickActionCard(context, actions[0]),
                      ),
                      const SizedBox(width: AppSpace.md),
                      Expanded(
                        child: _buildQuickActionCard(context, actions[1]),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.md),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionCard(context, actions[2]),
                      ),
                      const SizedBox(width: AppSpace.md),
                      Expanded(
                        child: _buildQuickActionCard(context, actions[3]),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpace.xl),

          // 6. Nearby Issues Mini-Map (OpenStreetMap tiles)
          SectionHeader(
            title: 'Nearby Civic Map',
            subtitle: 'Live Nintavur community issue pins & active transit',
            actionLabel: 'Full Map',
            onAction: () => MainNavigationScreen.switchToTab(context, 1),
          ),
          const SizedBox(height: AppSpace.md),
          AppCard(
            padding: EdgeInsets.zero,
            child: SizedBox(
              height: 220,
              child: Stack(
                children: [
                  FlutterMap(
                    options: const MapOptions(
                      initialCenter: _nintavurCenter,
                      initialZoom: 13.8,
                      interactionOptions: InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.smartcity.app',
                      ),
                      MarkerLayer(
                        markers: issues.take(10).map((issue) {
                          final isResolved =
                              issue.status == IssueStatus.resolved;
                          final color = isResolved
                              ? AppColors.success(context)
                              : AppColors.danger(context);
                          return Marker(
                            point: issue.location,
                            width: 22,
                            height: 22,
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.5,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  Positioned(
                    right: AppSpace.md,
                    bottom: AppSpace.md,
                    child: AppButton(
                      label: 'Explore Map',
                      icon: Icons.open_in_full_rounded,
                      onPressed: () =>
                          MainNavigationScreen.switchToTab(context, 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpace.xl),

          // 7. Latest 3 Community Reports
          SectionHeader(
            title: 'Recent Reports',
            subtitle:
                'Latest citizen submissions verified by AI Hazard Aggregator',
            actionLabel: 'View All (${issues.length})',
            onAction: () => MainNavigationScreen.switchToTab(context, 1),
          ),
          const SizedBox(height: AppSpace.md),
          if (issues.isEmpty)
            const EmptyState(
              icon: Icons.check_circle_outline_rounded,
              title: 'No open community issues',
              subtitle: 'All reported problems in Nintavur have been resolved.',
            )
          else
            ...issues.take(3).map(
                  (issue) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpace.md),
                    child: _buildIssueSummaryCard(context, issue, issueService),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, _QuickActionData data) {
    return AppCard(
      onTap: data.onTap,
      padding: const EdgeInsets.all(AppSpace.lg),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: AppRadius.smBorder,
            ),
            child: Icon(data.icon, color: data.color, size: 22),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueSummaryCard(
    BuildContext context,
    CommunityIssue issue,
    CommunityIssueService service,
  ) {
    return AppCard(
      onTap: () => MainNavigationScreen.switchToTab(context, 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_outlined,
              size: 20,
              color: AppColors.primary(context),
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
                      issue.category.toUpperCase(),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(issue.createdAt),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.xs),
                Text(
                  issue.title,
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  issue.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: AppSpace.sm),
                Wrap(
                  spacing: AppSpace.sm,
                  runSpacing: AppSpace.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip.fromIssueStatus(issue.status),
                    if (issue.aiAnalysis != null)
                      StatusChip(
                        label: issue.aiAnalysis!.councilTicketId,
                        kind: StatusChipKind.info,
                        icon: Icons.confirmation_number_outlined,
                      ),
                    PopupMenuButton<IssueStatus>(
                      tooltip: 'Change issue status',
                      onSelected: (status) =>
                          service.updateStatus(issue.id, status),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: IssueStatus.pending,
                          child: Text('Mark Pending'),
                        ),
                        PopupMenuItem(
                          value: IssueStatus.inProgress,
                          child: Text('Mark In Progress'),
                        ),
                        PopupMenuItem(
                          value: IssueStatus.resolved,
                          child: Text('Mark Resolved'),
                        ),
                      ],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.xs,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Change status',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 18,
                              color: AppColors.textSecondary(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
