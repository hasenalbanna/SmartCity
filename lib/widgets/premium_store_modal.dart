import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/subscription_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'ui/ui.dart';

/// Reusable inline upsell banner tailored to each page of Smart City.
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
    this.ctaLabel = 'Upgrade / Buy',
    this.icon = Icons.workspace_premium_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionService>();
    return AppCard(
      accentBorderColor: AppColors.warning(context),
      backgroundColor: AppColors.warningBg(context),
      onTap: () => PremiumStoreModal.show(context),
      padding: const EdgeInsets.all(AppSpace.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.warning(context).withValues(alpha: 0.18),
              borderRadius: AppRadius.smBorder,
            ),
            child: Icon(icon, color: AppColors.warning(context), size: 24),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusChip(
                      label: sub.isProOrHigher ? 'PRO ACTIVE' : priceBadge,
                      kind: sub.isProOrHigher
                          ? StatusChipKind.resolved
                          : StatusChipKind.inProgress,
                      icon: Icons.bolt_rounded,
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
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          AppButton(
            label: ctaLabel,
            onPressed: () => PremiumStoreModal.show(context),
          ),
        ],
      ),
    );
  }
}

/// Full-featured Monetization Storefront & Subscription Modal.
class PremiumStoreModal {
  PremiumStoreModal._();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        builder: _buildSheet,
      ),
    );
  }

  static Widget _buildSheet(
    BuildContext context,
    ScrollController scrollController,
  ) {
    final sub = context.watch<SubscriptionService>();

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(AppSpace.xl),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outline(context),
              borderRadius: AppRadius.pillBorder,
            ),
          ),
        ),
        const SizedBox(height: AppSpace.md),
        Row(
          children: [
            Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.warning(context),
              size: 28,
            ),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart City Pro & Civic Marketplace',
                    style: AppTypography.title.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  Text(
                    'Basic civic reporting is 100% Free. Unlock Falcon AI Pro, Insurance Dossiers & B2B Map Sponsorships.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.xl),

        // 1. Subscription Plans Comparison
        const SectionHeader(
          title: '1. Monthly Subscriptions',
          subtitle:
              'Recurring safety, transit cashback, and business visibility plans',
        ),
        const SizedBox(height: AppSpace.md),
        _buildPlanCard(
          context,
          sub: sub,
          plan: SubscriptionPlan.free,
          title: 'Citizen Basic',
          price: 'FREE Forever',
          badge: 'INCLUDED',
          features: const [
            'Unlimited local road, drainage & lighting reports',
            'Live GPS Smart Bus tracking (Routes 22 & 48)',
            'Public community hazard feed & SOS strobe',
          ],
        ),
        const SizedBox(height: AppSpace.md),
        _buildPlanCard(
          context,
          sub: sub,
          plan: SubscriptionPlan.falconPro,
          title: 'Falcon Shield+ Pro',
          price: 'LKR 990 / month',
          badge: 'MOST POPULAR',
          accent: AppColors.primary(context),
          features: const [
            '24/7 Hands-Free "Hey Falcon" AI Voice Disaster Guardian',
            'Auto-dispatch live GPS SOS to 5 family contacts + SMS fallback',
            '45-Minute Early Street-Level Monsoon Flood Radar',
            '3 Free Certified Insurance Claim Dossier PDFs / month',
            '15% Cashback on Smart Bus Pass top-ups + VIP Seat Lock',
          ],
        ),
        const SizedBox(height: AppSpace.md),
        _buildPlanCard(
          context,
          sub: sub,
          plan: SubscriptionPlan.businessEnterprise,
          title: 'Business & Landlord Enterprise',
          price: 'LKR 4,900 / month',
          badge: 'HIGH ROI FOR SHOPS & LANDLORDS',
          accent: AppColors.warning(context),
          features: const [
            '5 Sponsored Business Pins on Live Citizen & Transit Map',
            'Promote store offers to commuters arriving at nearby bus stops',
            '15 Property Flood-Safety & Infrastructure Valuation Reports / mo',
            'Priority 2-Hour Commercial SLA Escalation & API Webhook',
          ],
        ),
        const SizedBox(height: AppSpace.xl),

        // 2. Pay-Per-Use Micro-Transactions
        const SectionHeader(
          title: '2. Instant Pay-Per-Use Add-Ons',
          subtitle:
              'No subscription required — purchase individual certificates, passes, or map boosts',
        ),
        const SizedBox(height: AppSpace.md),
        ...SubscriptionService.marketplaceAddOns.map((addOn) {
          final isPurchased = sub.purchasedAddOnIds.contains(addOn.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.md),
            child: AppCard(
              accentBorderColor: isPurchased
                  ? AppColors.success(context)
                  : AppColors.primary(context),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            StatusChip(
                              label: addOn.badge,
                              kind: isPurchased
                                  ? StatusChipKind.resolved
                                  : StatusChipKind.info,
                            ),
                            const SizedBox(width: AppSpace.sm),
                            Text(
                              addOn.category,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpace.xs),
                        Text(
                          addOn.title,
                          style: AppTypography.subtitle.copyWith(
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: AppSpace.xs),
                        Text(
                          addOn.subtitle,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpace.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        addOn.priceLabel,
                        style: AppTypography.subtitle.copyWith(
                          color: AppColors.primary(context),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpace.sm),
                      AppButton(
                        label: isPurchased ? 'Buy Again' : 'Buy Now',
                        variant: isPurchased
                            ? AppButtonVariant.secondary
                            : AppButtonVariant.primary,
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
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  static Widget _buildPlanCard(
    BuildContext context, {
    required SubscriptionService sub,
    required SubscriptionPlan plan,
    required String title,
    required String price,
    required String badge,
    required List<String> features,
    Color? accent,
  }) {
    final isCurrent = sub.currentPlan == plan;
    return AppCard(
      accentBorderColor: isCurrent
          ? AppColors.success(context)
          : (accent ?? AppColors.outline(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusChip(
                label: isCurrent ? 'CURRENT PLAN' : badge,
                kind: isCurrent
                    ? StatusChipKind.resolved
                    : StatusChipKind.inProgress,
              ),
              const Spacer(),
              Text(
                price,
                style: AppTypography.title.copyWith(
                  color: AppColors.primary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            title,
            style: AppTypography.title.copyWith(
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpace.sm),
          ...features.map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: AppColors.success(context),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: Text(
                      f,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpace.md),
          AppButton(
            label: isCurrent ? 'Active Plan' : 'Activate $title',
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
                        content: Text('Upgraded to $title ($price)!'),
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }
}
