import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/community_issue.dart';
import '../models/ai_hazard_analysis.dart';
import '../services/auth_service.dart';
import '../services/community_issue_service.dart';
import '../services/profile_service.dart';
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
  String _selectedFilter = 'All'; // 'All', 'Pending', 'In Progress', 'Resolved'

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year}';
  }

  Color _getStatusBg(IssueStatus status) {
    switch (status) {
      case IssueStatus.pending:
        return const Color(0xFFFEE2E2); // Soft red
      case IssueStatus.inProgress:
        return const Color(0xFFDBEAFE); // Soft blue
      case IssueStatus.resolved:
        return const Color(0xFFDCFCE7); // Soft green
    }
  }

  Color _getStatusText(IssueStatus status) {
    switch (status) {
      case IssueStatus.pending:
        return const Color(0xFFB91C1C); // Red text
      case IssueStatus.inProgress:
        return const Color(0xFF1D4ED8); // Blue text
      case IssueStatus.resolved:
        return const Color(0xFF15803D); // Green text
    }
  }

  String _getStatusLabel(IssueStatus status) {
    switch (status) {
      case IssueStatus.pending:
        return 'Pending';
      case IssueStatus.inProgress:
        return 'In Progress';
      case IssueStatus.resolved:
        return 'Resolved';
    }
  }

  Color _getMarkerColor(IssueStatus status) {
    switch (status) {
      case IssueStatus.pending:
        return const Color(0xFFEF4444); // Red dot
      case IssueStatus.inProgress:
        return const Color(0xFFF59E0B); // Amber dot
      case IssueStatus.resolved:
        return const Color(0xFF10B981); // Green dot
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthService>();
    final profile = context.watch<ProfileService>();
    final issuesService = context.watch<CommunityIssueService>();

    final userName = auth.currentUser?.username.isNotEmpty == true
        ? auth.currentUser!.username
        : (profile.displayName.isNotEmpty ? profile.displayName : 'AL');
    final avatarLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'A';

    final allIssues = issuesService.issues;
    final filteredIssues = allIssues.where((issue) {
      if (_selectedFilter == 'Pending') return issue.status == IssueStatus.pending;
      if (_selectedFilter == 'In Progress') return issue.status == IssueStatus.inProgress;
      if (_selectedFilter == 'Resolved') return issue.status == IssueStatus.resolved;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101318) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Hello, AL
            _buildHeader(userName, avatarLetter, isDark),

            // Top Map Section
            _buildMapSection(allIssues, isDark),

            // Recent Reports List Section
            Expanded(
              child: _buildRecentReportsSection(filteredIssues, issuesService, isDark),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'voice_ai_fab',
            onPressed: () {
              VoiceAiReportModal.show(
                context,
                initialLocation: const LatLng(7.3486, 81.8494),
              );
            },
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 5,
            tooltip: 'Voice AI Report',
            child: const Icon(Icons.mic, size: 24),
          ),
          const SizedBox(width: 12),
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
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 6,
            icon: const Icon(Icons.add_location_alt_outlined, size: 20),
            label: const Text(
              'Report Issue',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String userName, String avatarLetter, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Hello, $userName',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white12 : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      'EN',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, size: 16),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    avatarLetter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(List<CommunityIssue> issues, bool isDark) {
    final mapHeight = _isMapExpanded ? 360.0 : 210.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: mapHeight,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white24 : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(7.3486, 81.8494), // Nintavur
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.smartcity.app',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: const [
                        LatLng(7.3780, 81.8385),
                        LatLng(7.3486, 81.8385),
                        LatLng(7.3180, 81.8385),
                      ],
                      strokeWidth: 2.5,
                      color: const Color(0xFFDC2626),
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: issues.map((issue) {
                    final color = _getMarkerColor(issue.status);
                    return Marker(
                      point: issue.location,
                      width: 32,
                      height: 32,
                      child: GestureDetector(
                        onTap: () {
                          _showIssueDetailsBottomSheet(issue, isDark);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withValues(alpha: 0.35),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
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

            // Zoom Controls Top Left
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.add, size: 18, color: Colors.black87),
                      ),
                    ),
                    const Divider(height: 1, thickness: 1),
                    InkWell(
                      onTap: () => _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.remove, size: 18, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Region Pill Label (e.g. Nintavur)
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                ),
                child: const Text(
                  'Nintavur',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),

            // Expand Map & Center buttons bottom left
            Positioned(
              bottom: 12,
              left: 12,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.my_location, size: 18, color: Colors.black87),
                      onPressed: () {
                        _mapController.move(const LatLng(7.3486, 81.8494), 14.5);
                      },
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      setState(() => _isMapExpanded = !_isMapExpanded);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _isMapExpanded ? 'collapse' : 'expand',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildRecentReportsSection(
    List<CommunityIssue> issues,
    CommunityIssueService service,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161A22) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle Pill
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Reports',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
                InkWell(
                  onTap: () {
                    _showFilterBottomSheet(isDark);
                  },
                  child: Text(
                    _selectedFilter == 'All' ? 'View All' : _selectedFilter,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Reports Cards List
        Expanded(
          child: issues.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No $_selectedFilter reports found',
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: issues.length,
                  itemBuilder: (context, index) {
                    final issue = issues[index];
                    return _buildReportCard(issue, service, isDark);
                  },
                ),
        ),
      ],
    ),
    );
  }

  Widget _buildReportCard(
    CommunityIssue issue,
    CommunityIssueService service,
    bool isDark,
  ) {
    final ai = issue.aiAnalysis;

    return InkWell(
      onTap: () => _showIssueDetailsBottomSheet(issue, isDark),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : const Color(0xFFF1F3F5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Circular Location Pin Icon Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : const Color(0xFFF9FAFB),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? Colors.white24 : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    size: 22,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 14),

                // Category, Title, Address
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            issue.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: Color(0xFF2563EB), // Vibrant Blue
                            ),
                          ),
                          Text(
                            _formatDate(issue.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        issue.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        issue.address,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : const Color(0xFF6B7280),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (ai != null) ...[
              const SizedBox(height: 10),
              // AI Triage Tags
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_outlined, size: 12, color: Color(0xFF2563EB)),
                        const SizedBox(width: 4),
                        Text(
                          ai.councilTicketId,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1D4ED8),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'AI ${((ai.confidenceScore) * 100).toInt()}% • Urg ${ai.urgencyScore}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ),
                  if (ai.routingChannel == AiRoutingChannel.areaAlert)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '🚨 AREA ALERT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // Status Badge + Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusBg(issue.status),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _getStatusLabel(issue.status),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusText(issue.status),
                    ),
                  ),
                ),

                // Mark In Progress Button
                if (issue.status != IssueStatus.inProgress)
                  InkWell(
                    onTap: () {
                      service.updateStatus(issue.id, IssueStatus.inProgress);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Status updated to In Progress'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Mark In Progress',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                  ),

                // Mark Resolved Button
                if (issue.status != IssueStatus.resolved)
                  InkWell(
                    onTap: () {
                      service.updateStatus(issue.id, IssueStatus.resolved);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Issue marked as Resolved'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Mark Resolved',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showIssueDetailsBottomSheet(CommunityIssue issue, bool isDark) {
    final ai = issue.aiAnalysis;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    issue.category,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusBg(issue.status),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getStatusLabel(issue.status),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getStatusText(issue.status)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                issue.title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                issue.description,
                style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87, height: 1.4),
              ),
              const SizedBox(height: 12),
              Text(
                '📍 ${issue.address}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                '📞 ${issue.contactNumber}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // AI Hazard Aggregator Panel (DisasterShield Architecture)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, size: 18, color: Color(0xFF2563EB)),
                        const SizedBox(width: 8),
                        const Text(
                          'DisasterShield AI Diagnostic Triage',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildAiCheckRow('Municipal Work Order', ai?.councilTicketId ?? 'CW-2026-NIN-1001', isDark),
                    _buildAiCheckRow('Routing Channel', ai?.channelLabel ?? 'Council Work Order', isDark, isHighlight: true),
                    _buildAiCheckRow('Anti-Spam Authenticity', 'Passed (Trust Score 98%)', isDark),
                    _buildAiCheckRow('Geofence Bounds', 'Verified within Nintavur Municipal Sector', isDark),
                    _buildAiCheckRow('Weather Gauge Cross-Match', ai?.weatherCorrelated == true ? 'Correlated (Monsoon Radar Supported)' : 'Normal weather baseline', isDark),
                    _buildAiCheckRow('Dynamic Urgency Score', '${ai?.urgencyScore ?? 7.5} / 10', isDark),
                    _buildAiCheckRow('Citizens in Buffer Zone', '${ai?.peopleAtRisk ?? 35} residents', isDark),
                    _buildAiCheckRow('Response SLA', 'Crew dispatch within ${ai?.estimatedResponseHours ?? 4} hrs', isDark),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Reasoning: ${ai?.reasoning ?? "Verified by Municipal AI engine."}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF1D4ED8), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAiCheckRow(String label, String value, bool isDark, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : const Color(0xFF6B7280))),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isHighlight ? const Color(0xFF2563EB) : (isDark ? Colors.white : Colors.black87),
              fontFamily: label.contains('Order') ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161B22) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Filter Reports',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              ...['All', 'Pending', 'In Progress', 'Resolved'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return ListTile(
                  title: Text(filter, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF2563EB)) : null,
                  onTap: () {
                    setState(() => _selectedFilter = filter);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
