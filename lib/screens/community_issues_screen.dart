import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/community_issue.dart';
import '../services/auth_service.dart';
import '../services/community_issue_service.dart';
import '../services/profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/emergency_beacon_modal.dart';
import '../widgets/ui/ui.dart';
import '../widgets/voice_ai_report_modal.dart';
import 'report_issue_wizard_screen.dart';

class CommunityIssuesScreen extends StatefulWidget {
  const CommunityIssuesScreen({super.key});

  @override
  State<CommunityIssuesScreen> createState() => _CommunityIssuesScreenState();
}

class _CommunityIssuesScreenState extends State<CommunityIssuesScreen> {
  final MapController _mapController = MapController();
  bool _isMapExpanded = false;
  String _selectedFilter = 'All';
  final Set<String> _expandedAiCards = {};

  static const List<String> _filters = [
    'All',
    'Pending',
    'In Progress',
    'Resolved',
  ];

  static const List<LatLng> _nintavurBoundary = [
    LatLng(7.3720, 81.8250),
    LatLng(7.3720, 81.8650),
    LatLng(7.3220, 81.8650),
    LatLng(7.3220, 81.8250),
    LatLng(7.3720, 81.8250),
  ];

  String _formatDate(DateTime dt) => '${dt.month}/${dt.day}/${dt.year}';

  Color _getMarkerColor(BuildContext context, IssueStatus status) {
    switch (status) {
      case IssueStatus.pending:
        return AppColors.danger(context);
      case IssueStatus.inProgress:
        return AppColors.warning(context);
      case IssueStatus.resolved:
        return AppColors.success(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final profile = context.watch<ProfileService>();
    final issuesService = context.watch<CommunityIssueService>();

    final userName = auth.currentUser?.username.isNotEmpty == true
        ? auth.currentUser!.username
        : (profile.displayName.isNotEmpty ? profile.displayName : 'AL');
    final avatarLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'A';

    final allIssues = issuesService.issues;
    final filteredIssues = allIssues.where((issue) {
      if (_selectedFilter == 'Pending') {
        return issue.status == IssueStatus.pending;
      }
      if (_selectedFilter == 'In Progress') {
        return issue.status == IssueStatus.inProgress;
      }
      if (_selectedFilter == 'Resolved') {
        return issue.status == IssueStatus.resolved;
      }
      return true;
    }).toList();

    return AppScaffold(
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: 'Report issue by voice',
            button: true,
            child: FloatingActionButton(
              heroTag: 'voice_ai_fab',
              tooltip: 'Voice AI Report',
              backgroundColor: AppColors.surface(context),
              foregroundColor: AppColors.primary(context),
              onPressed: () {
                VoiceAiReportModal.show(
                  context,
                  initialLocation: const LatLng(7.3486, 81.8494),
                );
              },
              child: const Icon(Icons.mic_rounded),
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          FloatingActionButton.extended(
            heroTag: 'report_issue_fab',
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
        ],
      ),
      body: Column(
        children: [
          _buildHeader(context, userName, avatarLetter),
          _buildMapSection(context, allIssues),
          Expanded(
            child: _buildRecentReportsSection(
              context,
              filteredIssues,
              issuesService,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String userName,
    String avatarLetter,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.lg,
        vertical: AppSpace.md,
      ),
      color: AppColors.surface(context),
      child: Row(
        children: [
          Text(
            'Hello, $userName',
            style: AppTypography.title.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Semantics(
            label: 'Trigger Emergency SOS Strobe',
            button: true,
            child: OutlinedButton.icon(
              onPressed: () => EmergencyBeaconModal.show(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger(context),
                side: BorderSide(color: AppColors.danger(context)),
                minimumSize: const Size(40, 36),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.md,
                  vertical: AppSpace.xs,
                ),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.pillBorder),
              ),
              icon: const Icon(Icons.sos_rounded, size: 16),
              label: const Text('SOS'),
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary(context),
            child: Text(
              avatarLetter,
              style: AppTypography.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(BuildContext context, List<CommunityIssue> issues) {
    final mapHeight = _isMapExpanded ? 340.0 : 220.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      height: mapHeight,
      width: double.infinity,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(7.3486, 81.8475),
              initialZoom: 13.8,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.smartcity.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _nintavurBoundary,
                    strokeWidth: 3.0,
                    color: AppColors.danger(context),
                  ),
                ],
              ),
              MarkerLayer(
                markers: issues.map((issue) {
                  final dotColor = _getMarkerColor(context, issue.status);
                  return Marker(
                    point: issue.location,
                    width: 34,
                    height: 34,
                    child: Semantics(
                      label: '${issue.category} report at ${issue.address}',
                      button: true,
                      child: GestureDetector(
                        onTap: () => _showIssueDetailsSheet(context, issue),
                        child: Center(
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: dotColor.withValues(alpha: 0.45),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          // Zoom controls
          Positioned(
            top: AppSpace.md,
            left: AppSpace.md,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: AppRadius.smBorder,
                border: Border.all(color: AppColors.outline(context)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Zoom in',
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () {
                      final cam = _mapController.camera;
                      _mapController.move(cam.center, cam.zoom + 1);
                    },
                  ),
                  Divider(height: 1, color: AppColors.outline(context)),
                  IconButton(
                    tooltip: 'Zoom out',
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: () {
                      final cam = _mapController.camera;
                      _mapController.move(cam.center, cam.zoom - 1);
                    },
                  ),
                ],
              ),
            ),
          ),
          // Expand / Collapse map pill
          Positioned(
            left: AppSpace.md,
            bottom: AppSpace.md,
            child: AppButton(
              label: _isMapExpanded ? 'Collapse Map' : 'Expand Map',
              icon: _isMapExpanded
                  ? Icons.fullscreen_exit_rounded
                  : Icons.fullscreen_rounded,
              variant: AppButtonVariant.secondary,
              onPressed: () =>
                  setState(() => _isMapExpanded = !_isMapExpanded),
            ),
          ),
          // Center on Nintavur pill
          Positioned(
            right: AppSpace.md,
            bottom: AppSpace.md,
            child: AppButton(
              label: 'Nintavur',
              icon: Icons.my_location_rounded,
              variant: AppButtonVariant.secondary,
              onPressed: () {
                _mapController.move(const LatLng(7.3486, 81.8475), 14.2);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReportsSection(
    BuildContext context,
    List<CommunityIssue> issues,
    CommunityIssueService service,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background(context),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpace.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline(context),
                borderRadius: AppRadius.pillBorder,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.lg,
              AppSpace.md,
              AppSpace.lg,
              AppSpace.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'Recent Reports (${issues.length})',
                  subtitle: 'Filter by status or tap any report for AI forensics',
                ),
                const SizedBox(height: AppSpace.sm),
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
                          onSelected: (_) =>
                              setState(() => _selectedFilter = filter),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: issues.isEmpty
                ? EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'No reports in "$_selectedFilter"',
                    subtitle:
                        'Switch filters or submit a new community issue report.',
                    actionLabel: 'Report Issue',
                    onAction: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportIssueWizardScreen(),
                        ),
                      );
                    },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpace.lg,
                      AppSpace.sm,
                      AppSpace.lg,
                      96,
                    ),
                    itemCount: issues.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpace.md),
                    itemBuilder: (context, index) {
                      final issue = issues[index];
                      return _buildIssueCard(context, issue, service);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssueCard(
    BuildContext context,
    CommunityIssue issue,
    CommunityIssueService service,
  ) {
    final ai = issue.aiAnalysis;
    final isAiExpanded = _expandedAiCards.contains(issue.id);

    return AppCard(
      onTap: () {
        _mapController.move(issue.location, 15.2);
        _showIssueDetailsSheet(context, issue);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  color: AppColors.primary(context),
                  size: 22,
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
                        if (ai != null)
                          StatusChip(
                            label: ai.councilTicketId,
                            kind: StatusChipKind.info,
                            icon: Icons.confirmation_number_outlined,
                          ),
                        PopupMenuButton<IssueStatus>(
                          tooltip: 'Change status',
                          onSelected: (next) =>
                              service.updateStatus(issue.id, next),
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
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.sm,
                              vertical: AppSpace.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted(context),
                              borderRadius: AppRadius.pillBorder,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Change status',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textPrimary(context),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.expand_more_rounded,
                                  size: 16,
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
          if (ai != null) ...[
            const SizedBox(height: AppSpace.sm),
            InkWell(
              borderRadius: AppRadius.smBorder,
              onTap: () {
                setState(() {
                  if (isAiExpanded) {
                    _expandedAiCards.remove(issue.id);
                  } else {
                    _expandedAiCards.add(issue.id);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.md,
                  vertical: AppSpace.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted(context),
                  borderRadius: AppRadius.smBorder,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_outlined,
                          size: 15,
                          color: AppColors.primary(context),
                        ),
                        const SizedBox(width: AppSpace.xs),
                        Expanded(
                          child: Text(
                            'AI Triage: ${ai.channelLabel} • Urgency ${ai.urgencyScore.toStringAsFixed(1)}/10',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(
                          isAiExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.textSecondary(context),
                        ),
                      ],
                    ),
                    if (isAiExpanded) ...[
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        ai.reasoning,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showIssueDetailsSheet(BuildContext context, CommunityIssue issue) {
    final ai = issue.aiAnalysis;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StatusChip.fromIssueStatus(issue.status),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.sm),
              Text(
                issue.title,
                style: AppTypography.title.copyWith(
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: AppSpace.xs),
              Text(
                issue.address,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: AppSpace.md),
              Text(
                issue.description,
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimary(context),
                ),
              ),
              if (ai != null) ...[
                const SizedBox(height: AppSpace.lg),
                AppCard(
                  backgroundColor: AppColors.surfaceMuted(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DisasterShield AI Forensics (${(ai.confidenceScore * 100).toInt()}% Confidence)',
                        style: AppTypography.bodyStrong.copyWith(
                          color: AppColors.primary(context),
                        ),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        ai.reasoning,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: AppSpace.sm),
                      Wrap(
                        spacing: AppSpace.sm,
                        runSpacing: AppSpace.xs,
                        children: [
                          StatusChip(
                            label: 'Ticket: ${ai.councilTicketId}',
                            kind: StatusChipKind.info,
                          ),
                          StatusChip(
                            label:
                                'Urgency ${ai.urgencyScore.toStringAsFixed(1)}/10',
                            kind: ai.urgencyScore >= 8
                                ? StatusChipKind.pending
                                : StatusChipKind.inProgress,
                          ),
                          StatusChip(
                            label: 'SLA: ${ai.estimatedResponseHours}h',
                            kind: StatusChipKind.neutral,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpace.lg),
            ],
          ),
        );
      },
    );
  }
}
