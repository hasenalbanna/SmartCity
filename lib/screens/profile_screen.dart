import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/community_issue.dart';
import '../services/auth_service.dart';
import '../services/community_issue_service.dart';
import '../services/localization_service.dart';
import '../services/profile_service.dart';
import '../services/theme_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/ui/ui.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final profile = context.watch<ProfileService>();
    final localization = context.watch<LocalizationService>();
    final themeService = context.watch<ThemeService>();
    final issueService = context.watch<CommunityIssueService>();

    final userName = auth.currentUser?.username.isNotEmpty == true
        ? auth.currentUser!.username
        : (profile.displayName.isNotEmpty ? profile.displayName : 'AL Citizen');
    final avatarLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'A';

    final totalReports = issueService.issues.length;
    final resolvedReports = issueService.issues
        .where((i) => i.status == IssueStatus.resolved)
        .length;

    return AppScaffold(
      appBar: AppBar(title: const Text('Citizen Profile & Settings')),
      body: ListView(
        padding: AppSpace.pagePadding,
        children: [
          // 1. Citizen Header Card
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary(context),
                  child: Text(
                    avatarLetter,
                    style: AppTypography.title.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpace.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: AppTypography.title.copyWith(
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        'Verified Citizen • Nintavur Smart Municipality',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: AppSpace.sm),
                      const StatusChip(
                        label: 'Civic Steward',
                        kind: StatusChipKind.resolved,
                        icon: Icons.verified_user_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.lg),

          // 2. Civic Contributions Stat Row
          Row(
            children: [
              Expanded(
                child: StatTile(
                  label: 'Reports Filed',
                  value: '$totalReports',
                  icon: Icons.assignment_outlined,
                  accentColor: AppColors.primary(context),
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: StatTile(
                  label: 'Resolved Issues',
                  value: '$resolvedReports',
                  icon: Icons.check_circle_outline_rounded,
                  accentColor: AppColors.success(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.xl),

          // 3. Language & Localization (single unified place)
          const SectionHeader(
            title: 'Preferences',
            subtitle: 'Language, appearance, and accessibility settings',
          ),
          const SizedBox(height: AppSpace.md),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.language_rounded,
                    color: AppColors.primary(context),
                  ),
                  title: Text(
                    'App Language',
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  subtitle: Text(
                    localization.currentLanguageName,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: localization.currentLanguage,
                      borderRadius: AppRadius.mdBorder,
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(
                          value: 'ta',
                          child: Text('தமிழ் (Tamil)'),
                        ),
                        DropdownMenuItem(
                          value: 'si',
                          child: Text('සිංහල (Sinhala)'),
                        ),
                      ],
                      onChanged: (code) {
                        if (code != null) {
                          localization.setLanguage(code);
                        }
                      },
                    ),
                  ),
                ),
                Divider(height: 1, color: AppColors.outline(context)),
                SwitchListTile(
                  secondary: Icon(
                    AppColors.isDark(context)
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    color: AppColors.primary(context),
                  ),
                  title: Text(
                    'Dark Mode',
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  subtitle: Text(
                    'High-contrast dark theme for night reporting',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  value: AppColors.isDark(context),
                  onChanged: (_) => themeService.toggleTheme(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.xl),

          // 4. Security & About
          const SectionHeader(
            title: 'Security & Municipality',
            subtitle: 'Enterprise authentication & system status',
          ),
          const SizedBox(height: AppSpace.md),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.success(context),
                  ),
                  title: Text(
                    'Salted SHA-256 Auth Protection',
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  subtitle: Text(
                    '2,000-round key stretching + brute-force lockout active',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
                Divider(height: 1, color: AppColors.outline(context)),
                ListTile(
                  leading: Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primary(context),
                  ),
                  title: Text(
                    'Smart City v2.0 (Nintavur Edition)',
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  subtitle: Text(
                    'Powered by DisasterShield AI Hazard Aggregator & OpenStreetMap',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.xl),

          // 5. Sign Out
          AppButton(
            label: 'Sign Out',
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
          const SizedBox(height: AppSpace.xl),
        ],
      ),
    );
  }
}
