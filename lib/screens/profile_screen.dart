import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/community_issue.dart';
import '../services/auth_service.dart';
import '../services/community_issue_service.dart';
import '../services/currency_service.dart';
import '../services/localization_service.dart';
import '../services/notification_service.dart';
import '../services/profile_service.dart';
import '../services/smart_bus_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/emergency_beacon_modal.dart';
import '../widgets/premium_store_modal.dart';
import '../widgets/ui/ui.dart';
import 'civic_alerts_screen.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';
import 'report_issue_wizard_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double _transitPassBalanceLkr = 1450.0;

  void _showEditProfileDialog(BuildContext context, ProfileService profile) {
    final nameCtrl = TextEditingController(
      text: profile.displayName.isNotEmpty ? profile.displayName : 'AL Banna',
    );
    final bioCtrl = TextEditingController(
      text: profile.bio.isNotEmpty
          ? profile.bio
          : 'Active citizen contributor & community infrastructure monitor.',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Customize Citizen Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: nameCtrl,
              label: 'Full Name',
              hint: 'Enter your display name',
              isRequired: true,
            ),
            const SizedBox(height: AppSpace.md),
            AppTextField(
              controller: bioCtrl,
              label: 'Civic Bio / Role',
              hint: 'e.g. Ward 04 Community Volunteer',
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.pop(ctx),
          ),
          AppButton(
            label: 'Save Profile',
            onPressed: () {
              profile.updateProfile(
                displayName: nameCtrl.text.trim(),
                bio: bioCtrl.text.trim(),
                location: profile.location.isNotEmpty
                    ? profile.location
                    : 'Smart City Citizen',
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Citizen profile updated.')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showTopUpPassDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Top Up Smart Transit Pass'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select an instant reload amount for Nintavur Smart Bus routes 22 & 48:',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            Wrap(
              spacing: AppSpace.sm,
              runSpacing: AppSpace.sm,
              children: [250.0, 500.0, 1000.0].map((amount) {
                return AppButton(
                  label: '+ LKR ${amount.toInt()}',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    setState(() => _transitPassBalanceLkr += amount);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added LKR ${amount.toInt()} to your Smart Transit Pass.',
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          AppButton(
            label: 'Close',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final profile = context.watch<ProfileService>();
    final localization = context.watch<LocalizationService>();
    final currency = context.watch<CurrencyService>();
    final issueService = context.watch<CommunityIssueService>();
    final busService = context.watch<SmartBusService>();
    final notificationService = context.watch<NotificationService>();

    final userName = profile.displayName.isNotEmpty
        ? profile.displayName
        : (auth.currentUser?.username.isNotEmpty == true
              ? auth.currentUser!.username
              : 'AL Banna');
    final userBio = profile.bio.isNotEmpty
        ? profile.bio
        : 'Civic Steward • Global Smart City Network';
    final avatarLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'A';

    final allIssues = issueService.issues;
    final totalReports = allIssues.length;
    final resolvedReports = allIssues
        .where((i) => i.status == IssueStatus.resolved)
        .length;
    final aiVerifiedCount = allIssues
        .where((i) => (i.aiAnalysis?.confidenceScore ?? 0) >= 0.85)
        .length;
    final civicPoints =
        (totalReports * 35) +
        (resolvedReports * 50) +
        (profile.uploadedPhotos.length * 25);
    final nextTierPoints = 600;
    final progress = (civicPoints / nextTierPoints).clamp(0.0, 1.0);

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Citizen Profile & Civic Hub'),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            onPressed: () => _showEditProfileDialog(context, profile),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Settings, Language & Currency',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpace.md),
            child: IconButton(
              tooltip: 'Trigger Emergency SOS',
              onPressed: () => EmergencyBeaconModal.show(context),
              icon: Icon(
                Icons.sos_rounded,
                color: AppColors.danger(context),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.lg,
          AppSpace.lg,
          AppSpace.lg,
          AppSpace.xxl,
        ),
        children: [
          // 1. Digital Citizen ID Card + Reputation Progress
          AppCard(
            accentBorderColor: AppColors.primary(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => profile.pickAvatarFromGallery(),
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: AppColors.primary(context),
                            backgroundImage: profile.avatarBytes != null
                                ? MemoryImage(profile.avatarBytes!)
                                : null,
                            child: profile.avatarBytes == null
                                ? Text(
                                    avatarLetter,
                                    style: AppTypography.display.copyWith(
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.surface(context),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.outline(context),
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 14,
                                color: AppColors.primary(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpace.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  userName,
                                  style: AppTypography.title.copyWith(
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                              ),
                              const StatusChip(
                                label: 'ID: NIN-8492',
                                kind: StatusChipKind.info,
                                icon: Icons.badge_outlined,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpace.xs),
                          Text(
                            userBio,
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                          const SizedBox(height: AppSpace.sm),
                          Wrap(
                            spacing: AppSpace.sm,
                            runSpacing: AppSpace.xs,
                            children: [
                              const StatusChip(
                                label: 'Verified Citizen',
                                kind: StatusChipKind.resolved,
                                icon: Icons.verified_user_outlined,
                              ),
                              StatusChip(
                                label: '${auth.userCity}, ${auth.userCountry}',
                                kind: StatusChipKind.neutral,
                                icon: Icons.location_on_outlined,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpace.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted(context),
                    borderRadius: AppRadius.smBorder,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Civic Reputation • Level 4 Steward',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '$civicPoints / $nextTierPoints pts',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primary(context),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpace.sm),
                      ClipRRect(
                        borderRadius: AppRadius.pillBorder,
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: AppColors.outline(context),
                          color: AppColors.primary(context),
                        ),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        'Earn points by reporting verified road, drainage, and streetlight issues.',
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
          const SizedBox(height: AppSpace.lg),

          // 2. 4-Column Civic Impact KPI Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 640;
              final tiles = [
                StatTile(
                  label: 'Reports Filed',
                  value: '$totalReports',
                  icon: Icons.assignment_outlined,
                  accentColor: AppColors.primary(context),
                  onTap: () => MainNavigationScreen.switchToTab(context, 1),
                ),
                StatTile(
                  label: 'Resolved',
                  value: '$resolvedReports',
                  icon: Icons.check_circle_outline_rounded,
                  accentColor: AppColors.success(context),
                  onTap: () => MainNavigationScreen.switchToTab(context, 1),
                ),
                StatTile(
                  label: 'AI Verified',
                  value: '$aiVerifiedCount',
                  icon: Icons.auto_awesome_outlined,
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
                StatTile(
                  label: 'Civic Points',
                  value: '$civicPoints',
                  icon: Icons.stars_rounded,
                  accentColor: AppColors.primary(context),
                ),
              ];

              if (isWide) {
                return Row(
                  children: [
                    for (int i = 0; i < tiles.length; i++) ...[
                      Expanded(child: tiles[i]),
                      if (i < tiles.length - 1)
                        const SizedBox(width: AppSpace.md),
                    ],
                  ],
                );
              }
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: tiles[0]),
                      const SizedBox(width: AppSpace.md),
                      Expanded(child: tiles[1]),
                    ],
                  ),
                  const SizedBox(height: AppSpace.md),
                  Row(
                    children: [
                      Expanded(child: tiles[2]),
                      const SizedBox(width: AppSpace.md),
                      Expanded(child: tiles[3]),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpace.xl),

          // 2.5 Smart City Pro Subscription & Revenue Storefront Banner
          const PremiumUpsellBanner(
            title: 'Smart City Pro, Insurance Dossiers & Business Map Pins',
            subtitle:
                'Upgrade to Falcon Shield+ Pro (LKR 990/mo), Business Enterprise (LKR 4,900/mo), or buy instant Insurance Claim PDFs.',
            priceBadge: 'PRO MARKETPLACE',
            ctaLabel: 'Open Store',
          ),
          const SizedBox(height: AppSpace.xl),

          // 3. Smart Transit Commuter Pass & Saved Routes
          SectionHeader(
            title: 'Smart Transit Pass & Commute',
            subtitle: 'Contactless fare wallet & favorite Nintavur bus routes',
            actionLabel: 'Top Up',
            onAction: () => _showTopUpPassDialog(context),
          ),
          const SizedBox(height: AppSpace.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary(context).withValues(alpha: 0.12),
                        borderRadius: AppRadius.smBorder,
                      ),
                      child: Icon(
                        Icons.contactless_outlined,
                        color: AppColors.primary(context),
                      ),
                    ),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Global Smart Transit Card',
                            style: AppTypography.subtitle.copyWith(
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          Text(
                            'Valid on Route 22 (Kalmunai) & Route 48 (Ampara)',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'LKR ${_transitPassBalanceLkr.toStringAsFixed(0)}',
                          style: AppTypography.title.copyWith(
                            color: AppColors.success(context),
                          ),
                        ),
                        const StatusChip(
                          label: 'Active Pass',
                          kind: StatusChipKind.resolved,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.md),
                Divider(height: 1, color: AppColors.outline(context)),
                const SizedBox(height: AppSpace.md),
                Wrap(
                  spacing: AppSpace.sm,
                  runSpacing: AppSpace.sm,
                  children: busService.routes.map((route) {
                    return ActionChip(
                      avatar: Icon(
                        Icons.directions_bus_outlined,
                        size: 16,
                        color: Color(route.colorHex),
                      ),
                      label: Text(
                        '${route.displayName} • LKR ${route.fareLkr.toInt()}',
                      ),
                      onPressed: () {
                        busService.selectRoute(route.id);
                        MainNavigationScreen.switchToTab(context, 2);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.xl),

          // 4. My Recent Council Work Orders & Reports
          SectionHeader(
            title: 'My Council Work Orders',
            subtitle: 'Track live status of issues you reported to the council',
            actionLabel: '+ New Report',
            onAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReportIssueWizardScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpace.md),
          ...allIssues.take(3).map(
                (issue) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.md),
                  child: AppCard(
                    onTap: () => MainNavigationScreen.switchToTab(context, 1),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    issue.aiAnalysis?.councilTicketId ??
                                        'CW-2026-NIN',
                                    style: AppTypography.caption.copyWith(
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary(context),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpace.sm),
                                  Text(
                                    '• ${issue.category}',
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
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpace.md),
                        StatusChip.fromIssueStatus(issue.status),
                      ],
                    ),
                  ),
                ),
              ),
          const SizedBox(height: AppSpace.xl),

          // 5. Emergency Speed-Dial & Municipal Hotlines
          const SectionHeader(
            title: 'Emergency & Municipal Hotlines',
            subtitle: 'Instant dispatch & emergency response contacts',
          ),
          const SizedBox(height: AppSpace.md),
          Wrap(
            spacing: AppSpace.md,
            runSpacing: AppSpace.md,
            children: [
              _buildHotlineChip(
                context,
                title: '1990 Suwa Seriya',
                subtitle: 'Emergency Ambulance',
                icon: Icons.medical_services_outlined,
                color: AppColors.danger(context),
                notificationService: notificationService,
              ),
              _buildHotlineChip(
                context,
                title: '117 Disaster Management',
                subtitle: 'Flood & Coastal Alert',
                icon: Icons.flood_outlined,
                color: AppColors.warning(context),
                notificationService: notificationService,
              ),
              _buildHotlineChip(
                context,
                title: '067-2250111 Council',
                subtitle: 'National & Global Smart City Council',
                icon: Icons.account_balance_outlined,
                color: AppColors.primary(context),
                notificationService: notificationService,
              ),
            ],
          ),
          const SizedBox(height: AppSpace.xl),

          // 6. Civic Evidence Photo Vault
          SectionHeader(
            title: 'Civic Evidence Vault (${profile.uploadedPhotos.length})',
            subtitle: 'Photos attached to your community hazard reports',
            actionLabel: 'Upload Photo',
            onAction: () async {
              final added = await profile.addPostFromGallery();
              if (added && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Photo added to your Civic Evidence Vault.'),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: AppSpace.md),
          if (profile.uploadedPhotos.isEmpty)
            AppCard(
              child: Row(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Text(
                      'No additional evidence photos uploaded yet. Tap "Upload Photo" to attach field photos.',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: profile.uploadedPhotos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpace.sm,
                mainAxisSpacing: AppSpace.sm,
              ),
              itemBuilder: (context, idx) {
                return ClipRRect(
                  borderRadius: AppRadius.smBorder,
                  child: Image.memory(
                    profile.uploadedPhotos[idx],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          const SizedBox(height: AppSpace.xl),

          // 7. Settings & Preferences
          SectionHeader(
            title: 'Settings & Control Center',
            subtitle: 'Language, currency, ward alerts, and appearance',
            actionLabel: 'Open Settings',
            onAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(height: AppSpace.md),
          AppCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            padding: const EdgeInsets.all(AppSpace.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted(context),
                    borderRadius: AppRadius.mdBorder,
                    border: Border.all(color: AppColors.outline(context)),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: AppColors.primary(context),
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart City Settings & Preferences',
                        style: AppTypography.bodyStrong.copyWith(
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${localization.currentLanguageName} • ${currency.currentCurrency} • Alert channels & Dark mode',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.xl),

          // 8. Security & Account Actions
          AppButton(
            label: 'Sign Out of Citizen Account',
            icon: Icons.logout_rounded,
            variant: AppButtonVariant.secondary,
            fullWidth: true,
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHotlineChip(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required NotificationService notificationService,
  }) {
    return SizedBox(
      width: 240,
      child: AppCard(
        onTap: () {
          notificationService.add(
            title: 'Connected: $title',
            body: 'Emergency dispatch line ($subtitle) ready.',
            type: NotificationType.alert,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dialing $title ($subtitle)...')),
          );
        },
        padding: const EdgeInsets.all(AppSpace.md),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppRadius.smBorder,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  Text(
                    subtitle,
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
      ),
    );
  }
}
