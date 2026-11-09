import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/community_issue.dart';
import '../services/auth_service.dart';
import '../services/community_issue_service.dart';
import '../services/falcon_ai_service.dart';
import '../services/profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/emergency_beacon_modal.dart';
import '../widgets/falcon_ai_disaster_panel.dart';
import '../widgets/premium_store_modal.dart';
import '../widgets/ui/ui.dart';
import 'report_issue_wizard_screen.dart';

class CommunityIssuesScreen extends StatefulWidget {
  const CommunityIssuesScreen({super.key});

  @override
  State<CommunityIssuesScreen> createState() => _CommunityIssuesScreenState();
}

class _CommunityIssuesScreenState extends State<CommunityIssuesScreen> {
  final MapController _mapController = MapController();
  bool _isMapExpanded = false;
  int _reportModeIndex = 0; // 0 = Local Issues, 1 = Disaster Issues (Falcon AI)
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
    final falcon = context.watch<FalconAiService>();

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
            label: 'Activate Falcon AI Disaster Voice Assistant',
            button: true,
            child: FloatingActionButton.extended(
              heroTag: 'falcon_voice_fab',
              backgroundColor: _reportModeIndex == 1
                  ? AppColors.danger(context)
                  : AppColors.surface(context),
              foregroundColor: _reportModeIndex == 1
                  ? AppColors.onPrimary(context)
                  : AppColors.danger(context),
              onPressed: () {
                setState(() => _reportModeIndex = 1);
                falcon.wakeUpFalcon();
              },
              icon: const Icon(Icons.radar_rounded, size: 18),
              label: const Text('Hey Falcon AI'),
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          FloatingActionButton.extended(
            heroTag: 'report_issue_fab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReportIssueWizardScreen(
                    initialModeIndex: _reportModeIndex,
                  ),
                ),
              );
            },
            backgroundColor: AppColors.primary(context),
            foregroundColor: AppColors.onPrimary(context),
            icon: const Icon(Icons.add_location_alt_outlined, size: 18),
            label: const Text('Report Issue'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(context, userName, avatarLetter),
          _buildPrimaryTwoOptionsSelector(context, falcon),
          _buildMapSection(context, allIssues, falcon),
          Expanded(
            child: _reportModeIndex == 1
                ? FalconAiDisasterPanel(mapController: _mapController)
                : _buildLocalIssuesSection(
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
    final onPrimary = AppColors.onPrimary(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.md,
        vertical: AppSpace.sm,
      ),
      color: AppColors.surface(context),
      child: Row(
        children: [
          Builder(
            builder: (scaffoldContext) => IconButton(
              tooltip: 'Open All Pages Menu',
              visualDensity: VisualDensity.compact,
              onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
              icon: const Icon(Icons.menu_rounded),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Hello, $userName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.title.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppSpace.xs),
          InkWell(
            onTap: () => PremiumStoreModal.show(context),
            borderRadius: AppRadius.pillBorder,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.sm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted(context),
                borderRadius: AppRadius.pillBorder,
                border: Border.all(color: AppColors.outline(context)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    size: 15,
                    color: AppColors.textPrimary(context),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Pro',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpace.xs),
          Semantics(
            label: 'Trigger Emergency SOS Strobe',
            button: true,
            child: InkWell(
              onTap: () => EmergencyBeaconModal.show(context),
              borderRadius: AppRadius.pillBorder,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary(context),
                  borderRadius: AppRadius.pillBorder,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sos_rounded, size: 15, color: onPrimary),
                    const SizedBox(width: 4),
                    Text(
                      'SOS',
                      style: AppTypography.caption.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpace.xs),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary(context),
            child: Text(
              avatarLetter,
              style: AppTypography.caption.copyWith(
                color: onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// First thing the user sees on the Report page:
  /// Option 1: Report Local Issues | Option 2: Disaster Issues (Falcon AI)
  Widget _buildPrimaryTwoOptionsSelector(
    BuildContext context,
    FalconAiService falcon,
  ) {
    final isLocal = _reportModeIndex == 0;
    final isDisaster = _reportModeIndex == 1;
    final onPrimary = AppColors.onPrimary(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.lg,
        AppSpace.xs,
        AppSpace.lg,
        AppSpace.sm,
      ),
      color: AppColors.surface(context),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: AppRadius.mdBorder,
              onTap: () => setState(() => _reportModeIndex = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.md,
                  vertical: AppSpace.sm + 2,
                ),
                decoration: BoxDecoration(
                  color: isLocal
                      ? AppColors.primary(context)
                      : AppColors.surfaceMuted(context),
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(
                    color: isLocal
                        ? AppColors.primary(context)
                        : AppColors.outline(context),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.construction_rounded,
                      size: 18,
                      color: isLocal
                          ? onPrimary
                          : AppColors.textPrimary(context),
                    ),
                    const SizedBox(width: AppSpace.sm),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '1. Local Issues',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyStrong.copyWith(
                              color: isLocal
                                  ? onPrimary
                                  : AppColors.textPrimary(context),
                            ),
                          ),
                          Text(
                            'Roads, drainage, lights',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: isLocal
                                  ? onPrimary.withValues(alpha: 0.78)
                                  : AppColors.textSecondary(context),
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
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: InkWell(
              borderRadius: AppRadius.mdBorder,
              onTap: () => setState(() => _reportModeIndex = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.md,
                  vertical: AppSpace.sm + 2,
                ),
                decoration: BoxDecoration(
                  color: isDisaster
                      ? AppColors.danger(context)
                      : AppColors.surfaceMuted(context),
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(
                    color: isDisaster
                        ? AppColors.danger(context)
                        : AppColors.outline(context),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.radar_rounded,
                      size: 18,
                      color: isDisaster
                          ? onPrimary
                          : AppColors.textPrimary(context),
                    ),
                    const SizedBox(width: AppSpace.sm),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '2. Disaster • Falcon AI',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodyStrong.copyWith(
                              color: isDisaster
                                  ? onPrimary
                                  : AppColors.textPrimary(context),
                            ),
                          ),
                          Text(
                            falcon.isSirenActive
                                ? 'SIREN ACTIVE!'
                                : 'Say "Hey Falcon wake up"',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: isDisaster
                                  ? onPrimary.withValues(alpha: 0.78)
                                  : AppColors.textSecondary(context),
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
        ],
      ),
    );
  }

  Widget _buildMapSection(
    BuildContext context,
    List<CommunityIssue> issues,
    FalconAiService falcon,
  ) {
    final mapHeight = _isMapExpanded ? 320.0 : 200.0;
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
                markers: [
                  ...issues.map((issue) {
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
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  if (falcon.state == FalconAiState.dispatched)
                    Marker(
                      point: falcon.lockedLocation,
                      width: 80,
                      height: 80,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.danger(context),
                              borderRadius: AppRadius.smBorder,
                            ),
                            child: Text(
                              'FALCON SOS',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.my_location_rounded,
                            size: 36,
                            color: AppColors.danger(context),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            left: AppSpace.md,
            bottom: AppSpace.md,
            child: InkWell(
              onTap: () => setState(() => _isMapExpanded = !_isMapExpanded),
              borderRadius: AppRadius.mdBorder,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.md,
                  vertical: AppSpace.sm,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.84),
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isMapExpanded
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isMapExpanded ? 'Collapse Map' : 'Expand Map',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: AppSpace.md,
            bottom: AppSpace.md,
            child: InkWell(
              onTap: () {
                _mapController.move(const LatLng(7.3486, 81.8475), 14.2);
              },
              borderRadius: AppRadius.mdBorder,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.md,
                  vertical: AppSpace.sm,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.84),
                  borderRadius: AppRadius.mdBorder,
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.my_location_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Smart Hub',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalIssuesSection(
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
                  title: 'Local Community Reports (${issues.length})',
                  subtitle:
                      'Filter by status or export a Certified AI Insurance Claim PDF',
                  actionLabel: 'Insurance PDF',
                  onAction: () => PremiumStoreModal.show(context),
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
                    itemCount: issues.length + 1,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpace.md),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return const PremiumUpsellBanner(
                          title:
                              'Vehicle Pothole or Flood Damage? Get Certified Claim PDF',
                          subtitle:
                              'Download an official GPS + AI Vision verified forensic report accepted by Sri Lankan auto & property insurers.',
                          priceBadge: 'LKR 450',
                          ctaLabel: 'Get Claim PDF',
                          icon: Icons.verified_outlined,
                        );
                      }
                      final issue = issues[index - 1];
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
              AppButton(
                label: 'Download Certified Insurance Claim PDF (LKR 450)',
                icon: Icons.picture_as_pdf_outlined,
                fullWidth: true,
                onPressed: () {
                  Navigator.pop(ctx);
                  PremiumStoreModal.show(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
