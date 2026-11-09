import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/subscription_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'premium_store_modal.dart';
import 'ui/ui.dart';

/// Interactive luxury Feature Unlock Modal triggered when a citizen attempts
/// to access a locked premium capability.
///
/// Features competitive market benchmarking (Citizen Plus, Citymapper Club, AllTrails+),
/// tier differentiation, and 1-tap instant upgrade options.
class FeatureUnlockModal extends StatelessWidget {
  final PremiumFeature feature;
  final VoidCallback? onUnlocked;

  const FeatureUnlockModal({
    super.key,
    required this.feature,
    this.onUnlocked,
  });

  static Future<bool> show(
    BuildContext context, {
    required PremiumFeature feature,
    VoidCallback? onUnlocked,
  }) async {
    final sub = context.read<SubscriptionService>();
    if (sub.canAccessFeature(feature)) {
      onUnlocked?.call();
      return true;
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => FeatureUnlockModal(
        feature: feature,
        onUnlocked: onUnlocked,
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = AppColors.textPrimary(context);
    final muted = AppColors.textSecondary(context);
    final accentGold = AppColors.accentAmber(context);
    final accentBlue = AppColors.accentBlue(context);
    final outline = AppColors.outline(context);

    final benchmark = SubscriptionService.benchmarkResearch[feature] ??
        const FeatureBenchmarkInfo(
          feature: PremiumFeature.falconVoiceGuardian,
          featureName: 'Falcon Shield+ Pro Feature',
          rivalAppName: 'Leading Competitor Apps',
          rivalPrice: '\$19.99 / mo',
          rivalPerks: 'Premium access and dedicated support',
          ourAdvantage: 'Unified city safety, transit, and AI tools for \$4.99/mo',
          unlockAction: 'Upgrade to Falcon Shield+ Pro',
        );

    // Matching add-on if applicable
    MonetizationAddOn? matchingAddOn;
    if (feature == PremiumFeature.certifiedInsuranceDossier) {
      matchingAddOn = SubscriptionService.marketplaceAddOns.firstWhere(
        (a) => a.id == 'addon_insurance_pdf',
      );
    } else if (feature == PremiumFeature.vipBusRadar) {
      matchingAddOn = SubscriptionService.marketplaceAddOns.firstWhere(
        (a) => a.id == 'addon_bus_vip_pass',
      );
    } else if (feature == PremiumFeature.sponsoredBusinessPins) {
      matchingAddOn = SubscriptionService.marketplaceAddOns.firstWhere(
        (a) => a.id == 'addon_sponsored_pin',
      );
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpace.xl,
        AppSpace.lg,
        AppSpace.xl,
        MediaQuery.of(context).viewInsets.bottom + AppSpace.xxl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: outline,
                  borderRadius: AppRadius.pillBorder,
                ),
              ),
            ),
            const SizedBox(height: AppSpace.lg),

            // Header Row: Glowing Icon + Title
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accentGold.withValues(alpha: isDark ? 0.16 : 0.10),
                    borderRadius: AppRadius.mdBorder,
                    border: Border.all(
                      color: accentGold.withValues(alpha: 0.45),
                      width: 1.4,
                    ),
                  ),
                  child: Icon(
                    Icons.lock_person_rounded,
                    color: accentGold,
                    size: 26,
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.sm + 2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accentGold.withValues(alpha: isDark ? 0.22 : 0.14),
                          borderRadius: AppRadius.pillBorder,
                        ),
                        child: Text(
                          'PREMIUM FEATURE REQUIRED',
                          style: AppTypography.caption.copyWith(
                            color: accentGold,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        benchmark.featureName,
                        style: AppTypography.title.copyWith(
                          color: fg,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.lg),

            // Market Competitive Analysis Card
            Container(
              padding: const EdgeInsets.all(AppSpace.md),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131722) : const Color(0xFFF8FAFC),
                borderRadius: AppRadius.mdBorder,
                border: Border.all(color: outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.insights_rounded,
                        size: 16,
                        color: accentBlue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'MARKET BENCHMARK ANALYSIS',
                        style: AppTypography.caption.copyWith(
                          color: accentBlue,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    'Compared to ${benchmark.rivalAppName}:',
                    style: AppTypography.bodyStrong.copyWith(
                      color: fg,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        benchmark.rivalPrice,
                        style: AppTypography.title.copyWith(
                          color: AppColors.accentRose(context),
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'charged by ${benchmark.rivalAppName}',
                        style: AppTypography.caption.copyWith(color: muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• ${benchmark.rivalPerks}',
                    style: AppTypography.caption.copyWith(
                      color: muted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Divider(color: outline, height: 1),
                  const SizedBox(height: AppSpace.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColors.accentGreen(context),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          benchmark.ourAdvantage,
                          style: AppTypography.caption.copyWith(
                            color: fg,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.lg),

            // Tier Value Comparison Pills
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.sm,
                      vertical: AppSpace.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted(context),
                      borderRadius: AppRadius.smBorder,
                      border: Border.all(color: outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Current Plan',
                          style: AppTypography.caption.copyWith(
                            color: muted,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          sub.currentPlanName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyStrong.copyWith(
                            color: fg,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.sm,
                      vertical: AppSpace.sm,
                    ),
                    decoration: BoxDecoration(
                      color: accentGold.withValues(alpha: isDark ? 0.12 : 0.08),
                      borderRadius: AppRadius.smBorder,
                      border: Border.all(
                        color: accentGold.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recommended Plan',
                          style: AppTypography.caption.copyWith(
                            color: accentGold,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          'Falcon Shield+ Pro',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyStrong.copyWith(
                            color: fg,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.xl),

            // Primary Upgrade CTA Button
            AppButton(
              label: '👑 Upgrade to Falcon Shield+ Pro (\$4.99/mo)',
              fullWidth: true,
              onPressed: () {
                Navigator.pop(context, true);
                PremiumStoreModal.show(context, initialTabIndex: 0);
              },
            ),
            const SizedBox(height: AppSpace.sm),

            // Secondary Option: Single Add-On Pass (if available)
            if (matchingAddOn != null) ...[
              AppButton(
                label: '⚡ Unlock Single Pass: ${matchingAddOn.title} (${matchingAddOn.priceLabel})',
                variant: AppButtonVariant.secondary,
                fullWidth: true,
                onPressed: () {
                  sub.purchaseAddOn(matchingAddOn!);
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Unlocked ${matchingAddOn.title}!'),
                    ),
                  );
                  onUnlocked?.call();
                },
              ),
              const SizedBox(height: AppSpace.sm),
            ],

            // Browse All Store Plans
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                  PremiumStoreModal.show(context);
                },
                child: Text(
                  'Explore All Plans & Business Enterprise Options',
                  style: AppTypography.caption.copyWith(
                    color: muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
