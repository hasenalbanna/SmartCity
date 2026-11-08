import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ai_hazard_analysis.dart';
import '../models/community_issue.dart';
import '../services/community_issue_service.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/emergency_beacon_modal.dart';
import '../widgets/premium_store_modal.dart';
import '../widgets/ui/ui.dart';

class CivicAlertsScreen extends StatefulWidget {
  const CivicAlertsScreen({super.key});

  @override
  State<CivicAlertsScreen> createState() => _CivicAlertsScreenState();
}

class _CivicAlertsScreenState extends State<CivicAlertsScreen> {
  String _selectedFilter = 'All';

  static const List<String> _filters = [
    'All',
    'Critical',
    'Council Tickets',
    'Community',
  ];

  String _formatDate(DateTime dt) => '${dt.month}/${dt.day}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final issueService = context.watch<CommunityIssueService>();
    final notificationService = context.watch<NotificationService>();

    final alertItems = _buildUnifiedAlerts(
      issueService.issues,
      notificationService.notifications,
    );

    final filtered = alertItems.where((item) {
      if (_selectedFilter == 'Critical') {
        return item.severity == _AlertSeverity.critical;
      }
      if (_selectedFilter == 'Council Tickets') {
        return item.ticketId != null;
      }
      if (_selectedFilter == 'Community') {
        return item.severity == _AlertSeverity.info ||
            item.severity == _AlertSeverity.warning;
      }
      return true;
    }).toList();

    final todayItems = filtered.where((i) => i.isToday).toList();
    final earlierItems = filtered.where((i) => !i.isToday).toList();

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Civic Alerts & Feed'),
        actions: [
          if (notificationService.unreadCount > 0)
            TextButton(
              onPressed: notificationService.markAllRead,
              child: const Text('Mark all read'),
            ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpace.md),
            child: Semantics(
              label: 'Trigger Emergency SOS Beacon',
              button: true,
              child: IconButton(
                tooltip: 'SOS Beacon',
                onPressed: () => EmergencyBeaconModal.show(context),
                icon: Icon(
                  Icons.sos_rounded,
                  color: AppColors.danger(context),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: AppSpace.pagePadding,
        children: [
          // Top Monsoon / AI Aggregator Banner
          AppCard(
            accentBorderColor: AppColors.primary(context),
            backgroundColor: AppColors.infoBg(context),
            padding: const EdgeInsets.all(AppSpace.md),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  color: AppColors.primary(context),
                  size: 24,
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DisasterShield AI Aggregator Active',
                        style: AppTypography.bodyStrong.copyWith(
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Monitoring Nintavur & Addappalam coastal zone, drainage canals, and road reports in real time.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.md),
          const PremiumUpsellBanner(
            title: '45-Min Early Flood Radar & Property Risk Certificate',
            subtitle:
                'Unlock street-level monsoon water predictions (Falcon Shield+ Pro) or buy a 10-year Property Flood Valuation Report (LKR 1,200).',
            priceBadge: 'PRO / LKR 1,200',
            ctaLabel: 'Unlock Pro',
            icon: Icons.flood_outlined,
          ),
          const SizedBox(height: AppSpace.lg),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final selected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpace.sm),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpace.lg),

          if (filtered.isEmpty)
            const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No alerts match this filter',
              subtitle:
                  'Try switching back to All to see recent civic updates.',
            )
          else ...[
            if (todayItems.isNotEmpty) ...[
              const SectionHeader(
                title: 'Today',
                subtitle: 'Real-time AI hazard dispatches & local advisories',
              ),
              const SizedBox(height: AppSpace.md),
              ...todayItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.md),
                  child: _buildAlertCard(context, item),
                ),
              ),
              const SizedBox(height: AppSpace.md),
            ],
            if (earlierItems.isNotEmpty) ...[
              const SectionHeader(
                title: 'Earlier',
                subtitle: 'Verified community reports & municipal updates',
              ),
              const SizedBox(height: AppSpace.md),
              ...earlierItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.md),
                  child: _buildAlertCard(context, item),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, _CivicAlertItem item) {
    Color accent;
    StatusChipKind chipKind;
    switch (item.severity) {
      case _AlertSeverity.critical:
        accent = AppColors.danger(context);
        chipKind = StatusChipKind.pending;
        break;
      case _AlertSeverity.warning:
        accent = AppColors.warning(context);
        chipKind = StatusChipKind.inProgress;
        break;
      case _AlertSeverity.resolved:
        accent = AppColors.success(context);
        chipKind = StatusChipKind.resolved;
        break;
      case _AlertSeverity.info:
        accent = AppColors.primary(context);
        chipKind = StatusChipKind.info;
        break;
    }

    return AppCard(
      accentBorderColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusChip(
                label: item.badgeLabel,
                kind: chipKind,
                icon: item.icon,
              ),
              if (item.ticketId != null) ...[
                const SizedBox(width: AppSpace.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted(context),
                    borderRadius: AppRadius.smBorder,
                  ),
                  child: Text(
                    item.ticketId!,
                    style: AppTypography.caption.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                item.timeLabel,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            item.title,
            style: AppTypography.subtitle.copyWith(
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            item.body,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          if (item.location != null) ...[
            const SizedBox(height: AppSpace.sm),
            Row(
              children: [
                Icon(
                  Icons.place_outlined,
                  size: 15,
                  color: AppColors.textSecondary(context),
                ),
                const SizedBox(width: AppSpace.xs),
                Expanded(
                  child: Text(
                    item.location!,
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
        ],
      ),
    );
  }

  List<_CivicAlertItem> _buildUnifiedAlerts(
    List<CommunityIssue> issues,
    List<AppNotification> notifications,
  ) {
    final List<_CivicAlertItem> items = [];

    for (final n in notifications) {
      items.add(
        _CivicAlertItem(
          title: n.title,
          body: n.body,
          badgeLabel: n.type == NotificationType.alert ? 'Emergency' : 'Notice',
          timeLabel: 'Just now',
          isToday: true,
          severity: n.type == NotificationType.alert
              ? _AlertSeverity.critical
              : _AlertSeverity.info,
          icon: n.type == NotificationType.alert
              ? Icons.warning_amber_rounded
              : Icons.notifications_active_outlined,
        ),
      );
    }

    for (int i = 0; i < issues.length; i++) {
      final issue = issues[i];
      final ai = issue.aiAnalysis;
      final isCritical = (ai?.urgencyScore ?? 0) >= 8.0 ||
          ai?.routingChannel == AiRoutingChannel.areaAlert ||
          ai?.routingChannel == AiRoutingChannel.councilTicket;

      _AlertSeverity severity;
      if (issue.status == IssueStatus.resolved) {
        severity = _AlertSeverity.resolved;
      } else if (isCritical) {
        severity = _AlertSeverity.critical;
      } else if (issue.status == IssueStatus.inProgress) {
        severity = _AlertSeverity.warning;
      } else {
        severity = _AlertSeverity.info;
      }

      items.add(
        _CivicAlertItem(
          title: '${issue.category}: ${issue.title}',
          body: ai?.reasoning ?? issue.description,
          location: issue.address,
          badgeLabel: ai?.channelLabel ?? issue.status.name.toUpperCase(),
          ticketId: ai?.councilTicketId,
          timeLabel: i < 3 ? 'Today' : _formatDate(issue.createdAt),
          isToday: i < 3,
          severity: severity,
          icon: Icons.place_outlined,
        ),
      );
    }

    return items;
  }
}

enum _AlertSeverity { critical, warning, resolved, info }

class _CivicAlertItem {
  final String title;
  final String body;
  final String? location;
  final String badgeLabel;
  final String? ticketId;
  final String timeLabel;
  final bool isToday;
  final _AlertSeverity severity;
  final IconData icon;

  const _CivicAlertItem({
    required this.title,
    required this.body,
    this.location,
    required this.badgeLabel,
    this.ticketId,
    required this.timeLabel,
    required this.isToday,
    required this.severity,
    required this.icon,
  });
}
