import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/subscription_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'ui/ui.dart';

/// Clean Monochrome Black, White & Gray inline Pro banner.
class PremiumUpsellBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String priceBadge;
  final String ctaLabel;
  final IconData icon;

  const PremiumUpsellBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.priceBadge,
    this.ctaLabel = 'Upgrade',
    this.icon = Icons.workspace_premium_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionService>();
    final isDark = AppColors.isDark(context);

    return InkWell(
      onTap: () => PremiumStoreModal.show(context),
      borderRadius: AppRadius.lgBorder,
      child: Container(
        padding: const EdgeInsets.all(AppSpace.lg),
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient(context),
          borderRadius: AppRadius.lgBorder,
          border: Border.all(
            color: AppColors.primary(context).withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary(context),
                borderRadius: AppRadius.mdBorder,
              ),
              child: Icon(
                icon,
                color: AppColors.onPrimary(context),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white : Colors.black,
                          borderRadius: AppRadius.pillBorder,
                        ),
                        child: Text(
                          sub.isProOrHigher ? 'PRO ACTIVE' : priceBadge,
                          style: AppTypography.caption.copyWith(
                            color: isDark ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpace.sm),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodyStrong.copyWith(
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpace.md),
            AppButton(
              label: ctaLabel,
              onPressed: () => PremiumStoreModal.show(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Redesigned Luxury Monochrome Black, White & Gray Pro Membership Storefront.
class PremiumStoreModal {
  PremiumStoreModal._();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PremiumStoreSheet(),
    );
  }
}

class _PremiumStoreSheet extends StatefulWidget {
  const _PremiumStoreSheet();

  @override
  State<_PremiumStoreSheet> createState() => _PremiumStoreSheetState();
}

class _PremiumStoreSheetState extends State<_PremiumStoreSheet> {
  int _selectedTabIndex = 0; // 0 = Membership Plans, 1 = Pay-Per-Use Add-Ons

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionService>();
    final isDark = AppColors.isDark(context);
    final fg = AppColors.textPrimary(context);
    final muted = AppColors.textSecondary(context);
    final surface = AppColors.surface(context);
    final surfaceMuted = AppColors.surfaceMuted(context);
    final outline = AppColors.outline(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.90,
      minChildSize: 0.65,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            gradient: AppColors.backgroundGradient(context),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
            border: Border.all(color: outline),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppSpace.xl,
              AppSpace.md,
              AppSpace.xl,
              AppSpace.xxl,
            ),
            children: [
              // Drag Handle
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

              // Luxury Monochrome Executive Header Card
              Container(
                padding: const EdgeInsets.all(AppSpace.lg),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: AppRadius.lgBorder,
                  border: Border.all(color: outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: fg,
                            borderRadius: AppRadius.mdBorder,
                          ),
                          child: Icon(
                            Icons.workspace_premium_rounded,
                            color: AppColors.onPrimary(context),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpace.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: surfaceMuted,
                                  borderRadius: AppRadius.pillBorder,
                                  border: Border.all(color: outline),
                                ),
                                child: Text(
                                  'ACTIVE TIER • ${sub.currentPlanName.toUpperCase()}',
                                  style: AppTypography.caption.copyWith(
                                    color: fg,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Smart City Pro & Civic Marketplace',
                                style: AppTypography.title.copyWith(color: fg),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close_rounded, color: fg),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.sm),
                    Text(
                      'Basic civic reporting is 100% Free. Upgrade for 24/7 Falcon AI Voice SOS, certified insurance dossiers, and live map sponsorships.',
                      style: AppTypography.body.copyWith(color: muted),
                    ),
                    const SizedBox(height: AppSpace.lg),

                    // 2-Tab Monochrome Switcher (Plans vs. Instant Add-Ons)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: surfaceMuted,
                        borderRadius: AppRadius.mdBorder,
                        border: Border.all(color: outline),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildTabButton(
                              context,
                              index: 0,
                              label: '1. Membership Plans',
                              icon: Icons.verified_outlined,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildTabButton(
                              context,
                              index: 1,
                              label: '2. Instant Add-Ons',
                              icon: Icons.bolt_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.xl),

              if (_selectedTabIndex == 0) ...[
                // =============================================================
                // TAB 1: MONTHLY SUBSCRIPTION TIERS (MONOCHROME B&W CARDS)
                // =============================================================
                _buildMonochromePlanCard(
                  context,
                  sub: sub,
                  plan: SubscriptionPlan.falconPro,
                  title: 'Falcon Shield+ Pro',
                  priceMain: 'LKR 990',
                  pricePeriod: '/ month',
                  badge: 'MOST POPULAR',
                  isFeatured: true,
                  features: const [
                    '24/7 Hands-Free "Hey Falcon" AI Voice Disaster Guardian',
                    'Auto-dispatch live GPS SOS to 5 family contacts + SMS fallback',
                    '45-Minute Early Street-Level Monsoon Flood Radar',
                    '3 Free Certified Insurance Claim Dossier PDFs / month',
                    '15% Cashback on Smart Bus Pass top-ups + VIP Seat Lock',
                  ],
                ),
                const SizedBox(height: AppSpace.md),
                _buildMonochromePlanCard(
                  context,
                  sub: sub,
                  plan: SubscriptionPlan.free,
                  title: 'Citizen Basic',
                  priceMain: 'FREE',
                  pricePeriod: 'Forever',
                  badge: 'INCLUDED',
                  isFeatured: false,
                  features: const [
                    'Unlimited local road, drainage & lighting reports',
                    'Live GPS Smart Bus tracking (Routes 22 & 48)',
                    'Public community hazard feed & visual SOS strobe',
                  ],
                ),
                const SizedBox(height: AppSpace.md),
                _buildMonochromePlanCard(
                  context,
                  sub: sub,
                  plan: SubscriptionPlan.businessEnterprise,
                  title: 'Business & Landlord Enterprise',
                  priceMain: 'LKR 4,900',
                  pricePeriod: '/ month',
                  badge: 'B2B & SHOPS',
                  isFeatured: false,
                  features: const [
                    '5 Sponsored Business Pins on Live Citizen & Transit Map',
                    'Promote store offers to commuters arriving at nearby bus stops',
                    '15 Property Flood-Safety & Infrastructure Valuation Reports / mo',
                    'Priority 2-Hour Commercial SLA Escalation & API Webhook',
                  ],
                ),
              ] else ...[
                // =============================================================
                // TAB 2: PAY-PER-USE MICRO-TRANSACTIONS (MONOCHROME B&W)
                // =============================================================
                ...SubscriptionService.marketplaceAddOns.map((addOn) {
                  final isPurchased = sub.purchasedAddOnIds.contains(addOn.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpace.md),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpace.lg),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: AppRadius.lgBorder,
                        border: Border.all(
                          color: isPurchased ? fg : outline,
                          width: isPurchased ? 1.6 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpace.sm,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isPurchased ? fg : surfaceMuted,
                                  borderRadius: AppRadius.pillBorder,
                                  border: Border.all(color: outline),
                                ),
                                child: Text(
                                  isPurchased ? 'PURCHASED' : addOn.badge,
                                  style: AppTypography.caption.copyWith(
                                    color: isPurchased
                                        ? (isDark ? Colors.black : Colors.white)
                                        : fg,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpace.sm),
                              Expanded(
                                child: Text(
                                  addOn.category.toUpperCase(),
                                  style: AppTypography.caption.copyWith(
                                    color: muted,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                addOn.priceLabel,
                                style: AppTypography.title.copyWith(
                                  color: fg,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpace.sm),
                          Text(
                            addOn.title,
                            style: AppTypography.subtitle.copyWith(color: fg),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            addOn.subtitle,
                            style: AppTypography.body.copyWith(color: muted),
                          ),
                          const SizedBox(height: AppSpace.md),
                          AppButton(
                            label: isPurchased
                                ? 'Purchase Again (${addOn.priceLabel})'
                                : 'Unlock Now • ${addOn.priceLabel}',
                            variant: isPurchased
                                ? AppButtonVariant.secondary
                                : AppButtonVariant.primary,
                            fullWidth: true,
                            onPressed: () {
                              sub.purchaseAddOn(addOn);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Purchased "${addOn.title}" (${addOn.priceLabel})!',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabButton(
    BuildContext context, {
    required int index,
    required String label,
    required IconData icon,
  }) {
    final selected = _selectedTabIndex == index;
    final fg = AppColors.textPrimary(context);
    final onPrimary = AppColors.onPrimary(context);

    return InkWell(
      onTap: () => setState(() => _selectedTabIndex = index),
      borderRadius: AppRadius.smBorder,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.md,
          vertical: AppSpace.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? fg : Colors.transparent,
          borderRadius: AppRadius.smBorder,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? onPrimary : AppColors.textSecondary(context),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.caption.copyWith(
                  color: selected
                      ? onPrimary
                      : AppColors.textSecondary(context),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonochromePlanCard(
    BuildContext context, {
    required SubscriptionService sub,
    required SubscriptionPlan plan,
    required String title,
    required String priceMain,
    required String pricePeriod,
    required String badge,
    required bool isFeatured,
    required List<String> features,
  }) {
    final isCurrent = sub.currentPlan == plan;
    final fg = AppColors.textPrimary(context);
    final muted = AppColors.textSecondary(context);
    final onPrimary = AppColors.onPrimary(context);
    final surface = AppColors.surface(context);
    final surfaceMuted = AppColors.surfaceMuted(context);
    final outline = AppColors.outline(context);

    return Container(
      padding: const EdgeInsets.all(AppSpace.xl),
      decoration: BoxDecoration(
        color: isFeatured ? surfaceMuted : surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(
          color: (isCurrent || isFeatured) ? fg : outline,
          width: (isCurrent || isFeatured) ? 1.8 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.md,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: (isCurrent || isFeatured) ? fg : surfaceMuted,
                  borderRadius: AppRadius.pillBorder,
                  border: Border.all(color: outline),
                ),
                child: Text(
                  isCurrent ? 'CURRENT PLAN' : badge,
                  style: AppTypography.caption.copyWith(
                    color: (isCurrent || isFeatured) ? onPrimary : fg,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    priceMain,
                    style: AppTypography.title.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    pricePeriod,
                    style: AppTypography.caption.copyWith(
                      color: muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          Text(
            title,
            style: AppTypography.title.copyWith(
              color: fg,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Divider(color: outline, height: 1),
          const SizedBox(height: AppSpace.md),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: fg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: onPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: Text(
                      f,
                      style: AppTypography.body.copyWith(color: fg),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          AppButton(
            label: isCurrent ? 'Current Active Plan' : 'Select $title',
            variant: isCurrent
                ? AppButtonVariant.secondary
                : AppButtonVariant.primary,
            fullWidth: true,
            onPressed: isCurrent
                ? null
                : () {
                    sub.upgradePlan(plan);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Activated $title ($priceMain $pricePeriod)!',
                        ),
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }
}
