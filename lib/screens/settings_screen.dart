import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/currency_service.dart';
import '../services/falcon_ai_service.dart';
import '../services/localization_service.dart';
import '../services/profile_service.dart';
import '../services/subscription_service.dart';
import '../services/theme_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/emergency_beacon_modal.dart';
import '../widgets/premium_store_modal.dart';
import '../widgets/ui/ui.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // Appearance & Map settings
  String _mapStyle = 'Standard Street';
  bool _highContrastMode = false;
  bool _hapticFeedback = true;
  bool _animatedRadarOverlays = true;

  // Falcon AI Voice settings
  bool _wakeWordEnabled = true;
  bool _autoPinLiveGps = true;
  bool _acousticSirenEnabled = true;
  double _wakeSensitivity = 0.85;
  double _voiceSpeechRate = 0.55;

  // Civic & Travel Notification settings
  String _selectedWard = 'Ward 04 — Addappalam';
  bool _monsoonCoastalAlerts = true;
  bool _councilTicketAlerts = true;
  bool _smartBusEtaAlerts = true;
  bool _aiPlannerWeatherAlerts = true;

  // Offline & Privacy settings
  bool _offlineMapPackEnabled = true;
  bool _anonymousHazardReporting = false;
  bool _biometricLock = false;
  double _cachedMb = 48.6;

  static const List<String> _categories = [
    'All',
    'Language',
    'Currency',
    'Appearance',
    'Falcon AI',
    'Notifications',
    'System',
  ];

  static const List<String> _wards = [
    'Ward 01 — Nintavur North',
    'Ward 02 — Hospital Road',
    'Ward 03 — Town Central',
    'Ward 04 — Addappalam',
    'Ward 05 — Coastal Belt',
  ];

  static const Map<String, Map<String, String>> _languageMeta = {
    'en': {'flag': '🇬🇧', 'native': 'English', 'sub': 'United Kingdom / US'},
    'si': {'flag': '🇱🇰', 'native': 'සිංහල', 'sub': 'Sinhala • Sri Lanka'},
    'ta': {'flag': '🇱🇰', 'native': 'தமிழ்', 'sub': 'Tamil • Sri Lanka & India'},
    'hi': {'flag': '🇮🇳', 'native': 'हिंदी', 'sub': 'Hindi • India'},
    'fr': {'flag': '🇫🇷', 'native': 'Français', 'sub': 'French • Europe'},
    'ml': {'flag': '🇮🇳', 'native': 'മലയാളം', 'sub': 'Malayalam • India'},
    'kn': {'flag': '🇮🇳', 'native': 'ಕನ್ನಡ', 'sub': 'Kannada • India'},
    'de': {'flag': '🇩🇪', 'native': 'Deutsch', 'sub': 'German • Europe'},
    'zh': {'flag': '🇨🇳', 'native': '中文', 'sub': 'Chinese • Mandarin'},
    'ja': {'flag': '🇯🇵', 'native': '日本語', 'sub': 'Japanese • Japan'},
    'ru': {'flag': '🇷🇺', 'native': 'Русский', 'sub': 'Russian • CIS'},
  };

  static const Map<String, Map<String, String>> _currencyMeta = {
    'USD': {'flag': '🇺🇸', 'symbol': '\$', 'name': 'US Dollar'},
    'LKR': {'flag': '🇱🇰', 'symbol': 'Rs', 'name': 'Sri Lankan Rupee'},
    'EUR': {'flag': '🇪🇺', 'symbol': '€', 'name': 'Euro'},
    'GBP': {'flag': '🇬🇧', 'symbol': '£', 'name': 'British Pound'},
    'AUD': {'flag': '🇦🇺', 'symbol': 'A\$', 'name': 'Australian Dollar'},
    'INR': {'flag': '🇮🇳', 'symbol': '₹', 'name': 'Indian Rupee'},
  };

  bool _matchesFilter(String sectionCategory, List<String> keywords) {
    if (_selectedCategory != 'All' && _selectedCategory != sectionCategory) {
      return false;
    }
    if (_searchQuery.trim().isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    if (sectionCategory.toLowerCase().contains(q)) return true;
    return keywords.any((k) => k.toLowerCase().contains(q));
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationService>();
    final currency = context.watch<CurrencyService>();
    final themeService = context.watch<ThemeService>();
    final falcon = context.watch<FalconAiService>();
    final subscription = context.watch<SubscriptionService>();
    final profile = context.watch<ProfileService>();
    final auth = context.watch<AuthService>();

    final userName = profile.displayName.isNotEmpty
        ? profile.displayName
        : (auth.currentUser?.username.isNotEmpty == true
              ? auth.currentUser!.username
              : 'AL Banna');

    return AppScaffold(
      appBar: AppBar(
        title: Text(localization.translate('settings')),
        actions: [
          IconButton(
            tooltip: 'Smart City Pro Store',
            onPressed: () => PremiumStoreModal.show(context),
            icon: Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.warning(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpace.md),
            child: IconButton(
              tooltip: 'Emergency SOS Beacon',
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
          AppSpace.md,
          AppSpace.lg,
          AppSpace.xxl,
        ),
        children: [
          // 1. Account & Active Configuration Summary Banner
          _buildOverviewHeroCard(
            context,
            userName: userName,
            localization: localization,
            currency: currency,
            subscription: subscription,
            themeService: themeService,
          ),
          const SizedBox(height: AppSpace.lg),

          // 2. Instant Search + Quick Category Filter Pills
          _buildSearchAndCategoryBar(context),
          const SizedBox(height: AppSpace.xl),

          // 3. Language / භාෂාව / மொழி (Compact 2-Column Grid + Live Preview)
          if (_matchesFilter('Language', [
            'language',
            'english',
            'sinhala',
            'tamil',
            'hindi',
            'french',
            'malayalam',
            'kannada',
            'german',
            'chinese',
            'japanese',
            'russian',
            'translate',
          ])) ...[
            _buildLanguageSection(context, localization),
            const SizedBox(height: AppSpace.xl),
          ],

          // 4. Multi-Currency & Live Exchange Engine
          if (_matchesFilter('Currency', [
            'currency',
            'exchange',
            'usd',
            'lkr',
            'eur',
            'gbp',
            'aud',
            'inr',
            'price',
            'money',
            'rupee',
            'dollar',
          ])) ...[
            _buildCurrencySection(context, currency),
            const SizedBox(height: AppSpace.xl),
          ],

          // 5. Appearance, Theme & Map Display Engine
          if (_matchesFilter('Appearance', [
            'theme',
            'dark',
            'light',
            'appearance',
            'map',
            'contrast',
            'display',
            'radar',
          ])) ...[
            _buildAppearanceSection(context, themeService),
            const SizedBox(height: AppSpace.xl),
          ],

          // 6. Falcon AI Voice Guardian & Emergency SOS Settings
          if (_matchesFilter('Falcon AI', [
            'falcon',
            'voice',
            'wake',
            'siren',
            'emergency',
            'sos',
            'danger',
            'gps',
            'disaster',
          ])) ...[
            _buildFalconAiSection(context, falcon),
            const SizedBox(height: AppSpace.xl),
          ],

          // 7. Smart City Notifications & Ward Preferences
          if (_matchesFilter('Notifications', [
            'notifications',
            'alerts',
            'ward',
            'monsoon',
            'flood',
            'bus',
            'council',
            'weather',
          ])) ...[
            _buildNotificationsSection(context),
            const SizedBox(height: AppSpace.xl),
          ],

          // 8. System, Offline Map Cache & Account Security
          if (_matchesFilter('System', [
            'offline',
            'cache',
            'privacy',
            'security',
            'biometric',
            'logout',
            'export',
            'storage',
          ])) ...[
            _buildSystemAndPrivacySection(context, auth),
          ],
        ],
      ),
    );
  }

  Widget _buildOverviewHeroCard(
    BuildContext context, {
    required String userName,
    required LocalizationService localization,
    required CurrencyService currency,
    required SubscriptionService subscription,
    required ThemeService themeService,
  }) {
    final currentLangMeta =
        _languageMeta[localization.currentLanguage] ?? _languageMeta['en']!;
    final currentCurrMeta =
        _currencyMeta[currency.currentCurrency] ?? _currencyMeta['USD']!;

    return AppCard(
      accentBorderColor: AppColors.primary(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary(context).withValues(alpha: 0.12),
                  borderRadius: AppRadius.mdBorder,
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary(context),
                  size: 26,
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Smart City Control Center',
                            style: AppTypography.title.copyWith(
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                        StatusChip(
                          label: subscription.isProOrHigher
                              ? 'PRO ACTIVE'
                              : 'FREE PLAN',
                          kind: subscription.isProOrHigher
                              ? StatusChipKind.resolved
                              : StatusChipKind.info,
                          icon: Icons.workspace_premium_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$userName • $_selectedWard • ${subscription.currentPlanName}',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          Divider(height: 1, color: AppColors.outline(context)),
          const SizedBox(height: AppSpace.md),
          Wrap(
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            children: [
              _buildQuickSummaryPill(
                context,
                icon: Icons.language_rounded,
                label:
                    '${currentLangMeta['flag']} ${currentLangMeta['native']} (${localization.currentLanguage.toUpperCase()})',
                onTap: () => setState(() => _selectedCategory = 'Language'),
              ),
              _buildQuickSummaryPill(
                context,
                icon: Icons.currency_exchange_rounded,
                label:
                    '${currentCurrMeta['flag']} ${currency.currentCurrency} (${currency.currentCurrencySymbol})',
                onTap: () => setState(() => _selectedCategory = 'Currency'),
              ),
              _buildQuickSummaryPill(
                context,
                icon: AppColors.isDark(context)
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                label: AppColors.isDark(context) ? 'Dark Theme' : 'Light Theme',
                onTap: () => themeService.toggleTheme(),
              ),
              _buildQuickSummaryPill(
                context,
                icon: Icons.record_voice_over_rounded,
                label: _wakeWordEnabled ? 'Falcon AI: Armed' : 'Falcon AI: Off',
                onTap: () => setState(() => _selectedCategory = 'Falcon AI'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSummaryPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.pillBorder,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.md,
          vertical: AppSpace.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted(context),
          borderRadius: AppRadius.pillBorder,
          border: Border.all(color: AppColors.outline(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.primary(context)),
            const SizedBox(width: AppSpace.xs),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndCategoryBar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: (val) => setState(() => _searchQuery = val),
          style: AppTypography.body.copyWith(
            color: AppColors.textPrimary(context),
          ),
          decoration: InputDecoration(
            hintText:
                'Search language, currency, Falcon AI, theme, or alerts...',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary(context),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () => setState(() => _searchQuery = ''),
                  )
                : null,
            filled: true,
            fillColor: AppColors.surface(context),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpace.md,
              vertical: AppSpace.md,
            ),
            border: OutlineInputBorder(
              borderRadius: AppRadius.mdBorder,
              borderSide: BorderSide(color: AppColors.outline(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdBorder,
              borderSide: BorderSide(color: AppColors.outline(context)),
            ),
          ),
        ),
        const SizedBox(height: AppSpace.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((cat) {
              final selected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpace.sm),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  selectedColor: AppColors.primary(context),
                  backgroundColor: AppColors.surface(context),
                  labelStyle: AppTypography.caption.copyWith(
                    color: selected
                        ? Colors.white
                        : AppColors.textPrimary(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection(
    BuildContext context,
    LocalizationService localization,
  ) {
    final entries = LocalizationService.supportedLanguages.entries.where((e) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final meta = _languageMeta[e.key];
      return e.key.toLowerCase().contains(q) ||
          e.value.toLowerCase().contains(q) ||
          (meta?['sub']?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Language / භාෂාව / மொழி',
          subtitle:
              'Select your preferred display & voice assistant language (${entries.length} languages)',
          actionLabel: localization.currentLanguage.toUpperCase(),
        ),
        const SizedBox(height: AppSpace.md),

        // Live Translation Preview Strip
        Container(
          padding: const EdgeInsets.all(AppSpace.md),
          decoration: BoxDecoration(
            color: AppColors.primary(context).withValues(alpha: 0.08),
            borderRadius: AppRadius.mdBorder,
            border: Border.all(
              color: AppColors.primary(context).withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.translate_rounded,
                color: AppColors.primary(context),
                size: 20,
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Wrap(
                  spacing: AppSpace.md,
                  runSpacing: AppSpace.xs,
                  children: [
                    Text(
                      '${localization.translate('home')} • ${localization.translate('explore')} • ${localization.translate('ai_planner')} • ${localization.translate('hotel_booking')}',
                      style: AppTypography.bodyStrong.copyWith(
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.md),

        // Responsive 2-Column / 3-Column Compact Language Grid
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 720
                ? 3
                : constraints.maxWidth >= 340
                ? 2
                : 1;
            const spacing = AppSpace.sm;
            final itemWidth =
                (constraints.maxWidth - (spacing * (columns - 1))) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: entries.map((entry) {
                final code = entry.key;
                final isSelected = localization.currentLanguage == code;
                final meta =
                    _languageMeta[code] ??
                    {'flag': '🌐', 'native': entry.value, 'sub': code};

                return SizedBox(
                  width: itemWidth,
                  child: InkWell(
                    onTap: () {
                      localization.setLanguage(code);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Language updated to ${entry.value}',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    borderRadius: AppRadius.mdBorder,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.md,
                        vertical: AppSpace.md,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary(context).withValues(alpha: 0.12)
                            : AppColors.surface(context),
                        borderRadius: AppRadius.mdBorder,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary(context)
                              : AppColors.outline(context),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            meta['flag']!,
                            style: AppTypography.title,
                          ),
                          const SizedBox(width: AppSpace.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  meta['native']!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.bodyStrong.copyWith(
                                    color: isSelected
                                        ? AppColors.primary(context)
                                        : AppColors.textPrimary(context),
                                  ),
                                ),
                                Text(
                                  meta['sub']!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpace.xs),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary(context),
                              size: 20,
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted(context),
                                borderRadius: AppRadius.smBorder,
                              ),
                              child: Text(
                                code.toUpperCase(),
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary(context),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCurrencySection(
    BuildContext context,
    CurrencyService currency,
  ) {
    final entries = CurrencyService.supportedCurrencies.entries.toList();
    final sampleHotel = currency
        .convertFromUsd(120)
        .toStringAsFixed(currency.currentCurrency == 'LKR' ? 0 : 2);
    final sampleTrip = currency
        .convertFromUsd(850)
        .toStringAsFixed(currency.currentCurrency == 'LKR' ? 0 : 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Multi-Currency & Exchange Rates',
          subtitle:
              'Auto-converts hotel rates, AI Trip Planner budgets, and SIM packages',
          actionLabel: currency.currentCurrency,
        ),
        const SizedBox(height: AppSpace.md),

        // Live Conversion Preview Card
        AppCard(
          padding: const EdgeInsets.all(AppSpace.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.success(context).withValues(alpha: 0.12),
                  borderRadius: AppRadius.smBorder,
                ),
                child: Icon(
                  Icons.currency_exchange_rounded,
                  color: AppColors.success(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Rate: \$1.00 USD = ${currency.currentCurrencySymbol}${currency.currentExchangeRate.toStringAsFixed(2)} ${currency.currentCurrency}',
                      style: AppTypography.bodyStrong.copyWith(
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    Text(
                      'Sample Hotel (\$120): ${currency.currentCurrencySymbol}$sampleHotel • Sample 5-Day Trip (\$850): ${currency.currentCurrencySymbol}$sampleTrip',
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

        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 680
                ? 3
                : constraints.maxWidth >= 340
                ? 2
                : 1;
            const spacing = AppSpace.sm;
            final itemWidth =
                (constraints.maxWidth - (spacing * (columns - 1))) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: entries.map((entry) {
                final code = entry.key;
                final isSelected = currency.currentCurrency == code;
                final meta =
                    _currencyMeta[code] ??
                    {'flag': '💱', 'symbol': code, 'name': entry.value};
                final rate = CurrencyService.exchangeRates[code] ?? 1.0;

                return SizedBox(
                  width: itemWidth,
                  child: InkWell(
                    onTap: () {
                      currency.setCurrency(code);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Active currency set to $code'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    borderRadius: AppRadius.mdBorder,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(AppSpace.md),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary(context).withValues(alpha: 0.12)
                            : AppColors.surface(context),
                        borderRadius: AppRadius.mdBorder,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary(context)
                              : AppColors.outline(context),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(meta['flag']!, style: AppTypography.title),
                          const SizedBox(width: AppSpace.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$code (${meta['symbol']})',
                                  style: AppTypography.bodyStrong.copyWith(
                                    color: isSelected
                                        ? AppColors.primary(context)
                                        : AppColors.textPrimary(context),
                                  ),
                                ),
                                Text(
                                  '${meta['name']} • ${rate.toStringAsFixed(rate >= 10 ? 0 : 2)}/USD',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primary(context),
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    ThemeService themeService,
  ) {
    final isDark = AppColors.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Appearance, Theme & Map Layer',
          subtitle: 'Customize visual mode, map tiles, and interface density',
        ),
        const SizedBox(height: AppSpace.md),
        Row(
          children: [
            Expanded(
              child: _buildThemeOptionCard(
                context,
                title: 'Light Civic Mode',
                subtitle: 'Daylight high-legibility slate & teal',
                icon: Icons.light_mode_rounded,
                selected: !isDark,
                onTap: () {
                  if (isDark) themeService.toggleTheme();
                },
              ),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: _buildThemeOptionCard(
                context,
                title: 'Dark Night-Ops Mode',
                subtitle: 'Low-glare dark canvas for night reporting',
                icon: Icons.dark_mode_rounded,
                selected: isDark,
                onTap: () {
                  if (!isDark) themeService.toggleTheme();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.md),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.layers_outlined,
                  color: AppColors.primary(context),
                ),
                title: Text(
                  'Default OpenStreetMap Tile Style',
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                subtitle: Text(
                  'Used across Smart Bus, Hotel Explorer, and Trip Planner',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _mapStyle,
                    borderRadius: AppRadius.mdBorder,
                    items: const [
                      DropdownMenuItem(
                        value: 'Standard Street',
                        child: Text('Standard Street'),
                      ),
                      DropdownMenuItem(
                        value: 'Transit Radar',
                        child: Text('Transit Radar'),
                      ),
                      DropdownMenuItem(
                        value: 'Terrain Contours',
                        child: Text('Terrain Contours'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _mapStyle = v);
                    },
                  ),
                ),
              ),
              Divider(height: 1, color: AppColors.outline(context)),
              SwitchListTile(
                secondary: Icon(
                  Icons.radar_rounded,
                  color: AppColors.primary(context),
                ),
                title: Text(
                  'Animated Weather & Flood Radar Pulses',
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                subtitle: Text(
                  'Render live telemetry rings on coastal hazard pins',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                value: _animatedRadarOverlays,
                onChanged: (v) => setState(() => _animatedRadarOverlays = v),
              ),
              Divider(height: 1, color: AppColors.outline(context)),
              SwitchListTile(
                secondary: Icon(
                  Icons.contrast_rounded,
                  color: AppColors.primary(context),
                ),
                title: Text(
                  'High-Contrast Accessibility Typography',
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                subtitle: Text(
                  'Boost border contrast and badge legibility outdoors',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                value: _highContrastMode,
                onChanged: (v) => setState(() => _highContrastMode = v),
              ),
              Divider(height: 1, color: AppColors.outline(context)),
              SwitchListTile(
                secondary: Icon(
                  Icons.vibration_rounded,
                  color: AppColors.primary(context),
                ),
                title: Text(
                  'Haptic Tactile Feedback',
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                subtitle: Text(
                  'Vibrate on report submission, upvote, and SOS triggers',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                value: _hapticFeedback,
                onChanged: (v) => setState(() => _hapticFeedback = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdBorder,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpace.md),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary(context).withValues(alpha: 0.12)
              : AppColors.surface(context),
          borderRadius: AppRadius.mdBorder,
          border: Border.all(
            color: selected
                ? AppColors.primary(context)
                : AppColors.outline(context),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: selected
                      ? AppColors.primary(context)
                      : AppColors.textSecondary(context),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary(context),
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              title,
              style: AppTypography.bodyStrong.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFalconAiSection(BuildContext context, FalconAiService falcon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Falcon AI Voice Guardian & SOS Calibration',
          subtitle:
              'Configure "Hey Falcon, wake up" voice trigger, live GPS lock, and acoustic siren',
        ),
        const SizedBox(height: AppSpace.md),
        AppCard(
          accentBorderColor: falcon.isSirenActive
              ? AppColors.danger(context)
              : AppColors.primary(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.danger(context).withValues(alpha: 0.12),
                      borderRadius: AppRadius.smBorder,
                    ),
                    child: Icon(
                      Icons.record_voice_over_rounded,
                      color: AppColors.danger(context),
                    ),
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Falcon AI Disaster Guardian',
                          style: AppTypography.subtitle.copyWith(
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        Text(
                          falcon.statusHeadline,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(
                    label: falcon.state.name.toUpperCase(),
                    kind: falcon.isSirenActive
                        ? StatusChipKind.pending
                        : StatusChipKind.info,
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.md),
              Wrap(
                spacing: AppSpace.sm,
                runSpacing: AppSpace.sm,
                children: [
                  AppButton(
                    label: 'Test "Hey Falcon, wake up"',
                    icon: Icons.mic_none_rounded,
                    variant: AppButtonVariant.secondary,
                    onPressed: () {
                      falcon.wakeUpFalcon();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Falcon AI Awake: "What happened, Master?"',
                          ),
                        ),
                      );
                    },
                  ),
                  if (falcon.isSirenActive)
                    AppButton(
                      label: 'Stop Active Siren',
                      icon: Icons.volume_off_rounded,
                      variant: AppButtonVariant.danger,
                      onPressed: () => falcon.stopSiren(),
                    ),
                ],
              ),
              const SizedBox(height: AppSpace.md),
              Divider(height: 1, color: AppColors.outline(context)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Hands-Free Wake Word ("Hey Falcon, wake up")',
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                subtitle: Text(
                  'Wake Falcon AI by voice and hear "What happened, Master?"',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                value: _wakeWordEnabled,
                onChanged: (v) => setState(() => _wakeWordEnabled = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Auto-Lock Live GPS on "I\'m in a danger, report this"',
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                subtitle: Text(
                  'Automatically pin exact coordinates on the emergency map',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                value: _autoPinLiveGps,
                onChanged: (v) => setState(() => _autoPinLiveGps = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Acoustic Emergency Siren & Haptic Strobe',
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                subtitle: Text(
                  'Sound high-decibel alert cadence when danger is reported',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                value: _acousticSirenEnabled,
                onChanged: (v) => setState(() => _acousticSirenEnabled = v),
              ),
              const SizedBox(height: AppSpace.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Wake-Word Mic Sensitivity',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${(_wakeSensitivity * 100).round()}%',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _wakeSensitivity,
                min: 0.4,
                max: 1.0,
                divisions: 12,
                activeColor: AppColors.primary(context),
                onChanged: (v) => setState(() => _wakeSensitivity = v),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Falcon Voice Response Speed (TTS)',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${(_voiceSpeechRate * 1.8).toStringAsFixed(1)}x',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primary(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _voiceSpeechRate,
                min: 0.3,
                max: 0.9,
                divisions: 6,
                activeColor: AppColors.primary(context),
                onChanged: (v) => setState(() => _voiceSpeechRate = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Smart City Notifications & Ward Alerts',
          subtitle:
              'Configure municipal ward priority and real-time push channels',
        ),
        const SizedBox(height: AppSpace.md),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.location_city_rounded,
                  color: AppColors.primary(context),
                ),
                title: Text(
                  'Primary Municipal Ward',
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                subtitle: Text(
                  'Prioritizes drainage, road, and coastal alerts for this ward',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedWard,
                    borderRadius: AppRadius.mdBorder,
                    items: _wards
                        .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedWard = v);
                    },
                  ),
                ),
              ),
              Divider(height: 1, color: AppColors.outline(context)),
              SwitchListTile(
                secondary: Icon(
                  Icons.thunderstorm_outlined,
                  color: AppColors.warning(context),
                ),
                title: Text(
                  'Monsoon & Coastal Surge Warnings (117 DMC)',
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                subtitle: Text(
                  'Instant red/amber weather broadcasts for $_selectedWard',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                value: _monsoonCoastalAlerts,
                onChanged: (v) => setState(() => _monsoonCoastalAlerts = v),
              ),
              Divider(height: 1, color: AppColors.outline(context)),
              SwitchListTile(
                secondary: Icon(
                  Icons.confirmation_number_outlined,
                  color: AppColors.success(context),
                ),
                title: Text(
                  'Council Work Order Resolution Updates',
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                subtitle: Text(
                  'Notify when engineers verify or resolve your reported issues',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                value: _councilTicketAlerts,
                onChanged: (v) => setState(() => _councilTicketAlerts = v),
              ),
              Divider(height: 1, color: AppColors.outline(context)),
              SwitchListTile(
                secondary: Icon(
                  Icons.directions_bus_outlined,
                  color: AppColors.primary(context),
                ),
                title: Text(
                  'Smart Bus Route 22 & 48 Live Arrival Alerts',
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                subtitle: Text(
                  'Alert 5 minutes before bus arrival at your saved stop',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                value: _smartBusEtaAlerts,
                onChanged: (v) => setState(() => _smartBusEtaAlerts = v),
              ),
              Divider(height: 1, color: AppColors.outline(context)),
              SwitchListTile(
                secondary: Icon(
                  Icons.auto_awesome_outlined,
                  color: AppColors.primary(context),
                ),
                title: Text(
                  'AI Trip Planner Weather & Crowd Advisories',
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                subtitle: Text(
                  'Notify when Sigiriya, Ella, or Galle Fort crowd levels drop',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                value: _aiPlannerWeatherAlerts,
                onChanged: (v) => setState(() => _aiPlannerWeatherAlerts = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSystemAndPrivacySection(
    BuildContext context,
    AuthService auth,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Offline Map Cache, Privacy & Security',
          subtitle:
              'Manage offline OpenStreetMap tiles, privacy controls, and session',
        ),
        const SizedBox(height: AppSpace.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Offline Map & Telemetry Storage',
                    style: AppTypography.bodyStrong.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  Text(
                    '${_cachedMb.toStringAsFixed(1)} MB / 250 MB',
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
                  value: (_cachedMb / 250.0).clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: AppColors.outline(context),
                  color: AppColors.primary(context),
                ),
              ),
              const SizedBox(height: AppSpace.sm),
              Text(
                'Caches Nintavur, Sigiriya, Kandy, Ella & Galle Fort map tiles for offline navigation during monsoon outages.',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: AppSpace.md),
              Wrap(
                spacing: AppSpace.sm,
                runSpacing: AppSpace.sm,
                children: [
                  AppButton(
                    label: 'Sync Sri Lanka Offline Pack',
                    icon: Icons.cloud_download_outlined,
                    variant: AppButtonVariant.secondary,
                    onPressed: () {
                      setState(() => _cachedMb = 112.4);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Offline Map Pack synced (112.4 MB cached).',
                          ),
                        ),
                      );
                    },
                  ),
                  AppButton(
                    label: 'Clear Tile Cache',
                    icon: Icons.cleaning_services_outlined,
                    variant: AppButtonVariant.ghost,
                    onPressed: () {
                      setState(() => _cachedMb = 4.2);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Temporary map tile cache cleared.'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.md),
              Divider(height: 1, color: AppColors.outline(context)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Offline Report Queueing',
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                subtitle: Text(
                  'Save hazard reports on device when offline and auto-send on reconnect',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                value: _offlineMapPackEnabled,
                onChanged: (v) => setState(() => _offlineMapPackEnabled = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Anonymous Public Issue Reporting',
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                subtitle: Text(
                  'Hide your citizen display name on the public community feed',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                value: _anonymousHazardReporting,
                onChanged: (v) => setState(() => _anonymousHazardReporting = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Biometric / PIN App Lock',
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                subtitle: Text(
                  'Require device authentication before opening Smart Transit Wallet',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                value: _biometricLock,
                onChanged: (v) => setState(() => _biometricLock = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Export Citizen Data (PDF/JSON)',
                icon: Icons.download_rounded,
                variant: AppButtonVariant.secondary,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Citizen activity & work order archive exported.',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: AppButton(
                label: 'Sign Out',
                icon: Icons.logout_rounded,
                variant: AppButtonVariant.danger,
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
            ),
          ],
        ),
      ],
    );
  }
}
