import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sim_provider.dart';
import '../services/auth_service.dart';
import '../services/sim_recommendation_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/ui/ui.dart';

class SIMRecommendationScreen extends StatelessWidget {
  const SIMRecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('SIM Recommendation')),
      body: const SingleChildScrollView(
        padding: AppSpace.pagePadding,
        child: SimRecommendationView(),
      ),
    );
  }
}

/// Reusable AI SIM Advisor view that can be displayed standalone or embedded
/// directly inside [ItineraryScreen].
class SimRecommendationView extends StatefulWidget {
  const SimRecommendationView({super.key});

  @override
  State<SimRecommendationView> createState() => _SimRecommendationViewState();
}

class _SimRecommendationViewState extends State<SimRecommendationView> {
  int _stayDays = 7;
  double _expectedDataGB = 10;
  double _budgetUSD = 20;
  String _usageType = 'moderate';
  final List<String> _selectedRegions = ['Western', 'Southern', 'Eastern'];
  List<SIMRecommendation>? _recommendations;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getRecommendations();
  }

  void _getRecommendations() {
    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      final service = SIMRecommendationService();
      final recommendations = service.getRecommendations(
        stayDays: _stayDays,
        expectedDataGB: _expectedDataGB,
        budgetUSD: _budgetUSD,
        visitingRegions: _selectedRegions,
        usageType: _usageType,
      );

      setState(() {
        _recommendations = recommendations;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI SIM Advisor Hero Banner with Real Cover Image
        ClipRRect(
          borderRadius: AppRadius.lgBorder,
          child: SizedBox(
            height: 120,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AdaptiveDestinationImage(
                  imageUrl: '',
                  country: auth.userCountry,
                  placeName: '${auth.userCountry} Telecom Radar',
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary(context).withValues(alpha: 0.88),
                        AppColors.warning(context).withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpace.lg),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpace.md),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: AppRadius.mdBorder,
                        ),
                        child: const Icon(
                          Icons.sim_card_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: AppSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'AI SIM Advisor',
                              style: AppTypography.title.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Get personalized eSIM & tourist SIM recommendations based on your travel plans',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.92),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpace.lg),

        // Your Travel Details
        AppCard(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Travel Details',
                style: AppTypography.title.copyWith(
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: AppSpace.md),
              _buildSliderInput(
                context: context,
                label: 'Length of Stay',
                valueLabel: '$_stayDays days',
                current: _stayDays.toDouble(),
                min: 1,
                max: 30,
                icon: Icons.calendar_today_outlined,
                onChanged: (val) => setState(() => _stayDays = val.round()),
              ),
              const SizedBox(height: AppSpace.sm),
              _buildSliderInput(
                context: context,
                label: 'Expected Data Usage',
                valueLabel: '${_expectedDataGB.toStringAsFixed(0)} GB',
                current: _expectedDataGB,
                min: 1,
                max: 50,
                icon: Icons.data_usage_rounded,
                onChanged: (val) => setState(() => _expectedDataGB = val),
              ),
              const SizedBox(height: AppSpace.sm),
              _buildSliderInput(
                context: context,
                label: 'Budget',
                valueLabel: '\$${_budgetUSD.toStringAsFixed(0)}',
                current: _budgetUSD,
                min: 3,
                max: 50,
                icon: Icons.attach_money_rounded,
                onChanged: (val) => setState(() => _budgetUSD = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.md),

        // Usage Type
        AppCard(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Usage Type',
                style: AppTypography.title.copyWith(
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: AppSpace.md),
              Row(
                children: [
                  _buildUsageChip(
                    context,
                    'light',
                    'Light',
                    Icons.wifi_1_bar_rounded,
                  ),
                  const SizedBox(width: AppSpace.sm),
                  _buildUsageChip(
                    context,
                    'moderate',
                    'Moderate',
                    Icons.wifi_2_bar_rounded,
                  ),
                  const SizedBox(width: AppSpace.sm),
                  _buildUsageChip(
                    context,
                    'heavy',
                    'Heavy',
                    Icons.wifi_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.md),

        // Visiting Regions
        AppCard(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Visiting Regions',
                style: AppTypography.title.copyWith(
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: AppSpace.md),
              Wrap(
                spacing: AppSpace.sm,
                runSpacing: AppSpace.sm,
                children: SIMRecommendationService.regions.map((region) {
                  final isSelected = _selectedRegions.contains(region);
                  return FilterChip(
                    selected: isSelected,
                    label: Text(region),
                    onSelected: (_) {
                      setState(() {
                        if (isSelected) {
                          _selectedRegions.remove(region);
                        } else {
                          _selectedRegions.add(region);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.lg),

        AppButton(
          label: _isLoading
              ? 'Analyzing Coverage...'
              : 'Get AI SIM Recommendations',
          icon: Icons.auto_awesome_rounded,
          isLoading: _isLoading,
          fullWidth: true,
          onPressed: _selectedRegions.isNotEmpty ? _getRecommendations : null,
        ),
        const SizedBox(height: AppSpace.xl),

        if (_recommendations != null && _recommendations!.isNotEmpty) ...[
          const SectionHeader(
            title: 'Top SIM Recommendations',
            subtitle: 'Ranked by 4G/5G regional coverage, data & budget fit',
          ),
          const SizedBox(height: AppSpace.md),
          ..._recommendations!.asMap().entries.map((entry) {
            final index = entry.key;
            final rec = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.md),
              child: _buildRecommendationCard(context, rec, index == 0),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildSliderInput({
    required BuildContext context,
    required String label,
    required String valueLabel,
    required double current,
    required double min,
    required double max,
    required IconData icon,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.textSecondary(context)),
                const SizedBox(width: AppSpace.sm),
                Text(
                  label,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
            StatusChip(
              label: valueLabel,
              kind: StatusChipKind.info,
            ),
          ],
        ),
        Slider(
          value: current,
          min: min,
          max: max,
          activeColor: AppColors.primary(context),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildUsageChip(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final isSelected = _usageType == value;
    final primary = AppColors.primary(context);

    return Expanded(
      child: InkWell(
        borderRadius: AppRadius.mdBorder,
        onTap: () => setState(() => _usageType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
          decoration: BoxDecoration(
            color: isSelected ? primary : AppColors.surfaceMuted(context),
            borderRadius: AppRadius.mdBorder,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : AppColors.textSecondary(context),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: isSelected
                      ? Colors.white
                      : AppColors.textPrimary(context),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    SIMRecommendation rec,
    bool isTop,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(rec.provider.logo, style: AppTypography.display),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            rec.provider.name,
                            style: AppTypography.title.copyWith(
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                        if (isTop) ...[
                          const SizedBox(width: AppSpace.sm),
                          const StatusChip(
                            label: 'BEST MATCH',
                            kind: StatusChipKind.resolved,
                            icon: Icons.verified_rounded,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      rec.package.name,
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
                    '\$${rec.package.priceUSD.toStringAsFixed(0)}',
                    style: AppTypography.title.copyWith(
                      color: AppColors.primary(context),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '${rec.matchScore.toStringAsFixed(0)}% match',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          Wrap(
            spacing: AppSpace.sm,
            runSpacing: AppSpace.xs,
            children: [
              StatusChip(
                label: '${rec.package.dataGB} GB Data',
                kind: StatusChipKind.info,
                icon: Icons.data_usage_rounded,
              ),
              StatusChip(
                label: '${rec.package.validityDays} Days',
                kind: StatusChipKind.neutral,
                icon: Icons.calendar_today_outlined,
              ),
              if (rec.package.hasUnlimitedCalls)
                const StatusChip(
                  label: 'Unlimited Calls',
                  kind: StatusChipKind.inProgress,
                  icon: Icons.phone_outlined,
                ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          Container(
            padding: const EdgeInsets.all(AppSpace.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted(context),
              borderRadius: AppRadius.smBorder,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 16,
                  color: AppColors.primary(context),
                ),
                const SizedBox(width: AppSpace.sm),
                Expanded(
                  child: Text(
                    rec.reason,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.md),
          AppButton(
            label: isTop ? 'Select This SIM Plan' : 'Select Plan',
            icon: Icons.sim_card_download_outlined,
            variant:
                isTop ? AppButtonVariant.primary : AppButtonVariant.secondary,
            fullWidth: true,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Reserved ${rec.provider.name} - ${rec.package.name} (\$${rec.package.priceUSD.toStringAsFixed(0)}) for airport pickup / eSIM!',
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

