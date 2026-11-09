import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/global_regions_data.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/ui/ui.dart';
import 'main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _customAreaController =
      TextEditingController(text: 'Nintavur');

  String _selectedCountry = 'Sri Lanka';
  String _selectedCity = 'Nintavur';

  bool _isRegisterMode = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _customAreaController.dispose();
    super.dispose();
  }

  void _onCountryChanged(String newCountry) {
    final region = GlobalRegions.findCountry(newCountry);
    final defaultCity = region.cities.isNotEmpty
        ? region.cities.first.name
        : 'Downtown';
    setState(() {
      _selectedCountry = region.name;
      _selectedCity = defaultCity;
      _customAreaController.text = defaultCity;
    });
  }

  Future<void> _submit() async {
    final auth = context.read<AuthService>();
    final profile = context.read<ProfileService>();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final area = _customAreaController.text.trim().isNotEmpty
        ? _customAreaController.text.trim()
        : _selectedCity;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = _isRegisterMode
        ? await auth.register(
            username,
            password,
            country: _selectedCountry,
            city: area,
          )
        : await auth.login(
            username,
            password,
            country: _selectedCountry,
            city: area,
          );

    if (!mounted) return;

    if (success) {
      await auth.updateRegion(_selectedCountry, area);
      if (!mounted) return;
      profile.updateProfile(
        displayName: username,
        bio: profile.bio,
        location: '$area, $_selectedCountry',
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = auth.lastError;
      });
    }
  }

  Future<void> _continueAsGuest() async {
    final auth = context.read<AuthService>();
    final profile = context.read<ProfileService>();
    final area = _customAreaController.text.trim().isNotEmpty
        ? _customAreaController.text.trim()
        : _selectedCity;

    await auth.updateRegion(_selectedCountry, area);
    profile.updateProfile(
      displayName: 'Guest Citizen',
      bio: 'Exploring Smart City Worldwide',
      location: '$area, $_selectedCountry',
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(AppSpace.lg),
            constraints: const BoxConstraints(maxHeight: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Your Country',
                      style: AppTypography.title.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Text(
                  'Civic maps and hazard alerts will automatically center on your country.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: AppSpace.md),
                Expanded(
                  child: ListView.separated(
                    itemCount: GlobalRegions.countries.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: AppColors.outline(context),
                    ),
                    itemBuilder: (_, index) {
                      final c = GlobalRegions.countries[index];
                      final isSelected = c.name == _selectedCountry;
                      return ListTile(
                        leading: Text(
                          c.flag,
                          style: AppTypography.title,
                        ),
                        title: Text(
                          c.name,
                          style: AppTypography.subtitle.copyWith(
                            color: AppColors.textPrimary(context),
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '${c.cities.length} major cities & regional network',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primary(context),
                              )
                            : null,
                        onTap: () {
                          _onCountryChanged(c.name);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      maxWidth: 460,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Brand Mark — Sri Lanka Community Unity Logo on Pure White Badge
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  padding: const EdgeInsets.all(AppSpace.sm),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.lgBorder,
                    border: Border.all(color: AppColors.outline(context)),
                  ),
                  child: ClipRRect(
                    borderRadius: AppRadius.mdBorder,
                    child: Image.asset(
                      'assets/images/smart_city_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.location_city_rounded,
                        color: Colors.black,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.lg),
              Text(
                'Smart City',
                textAlign: TextAlign.center,
                style: AppTypography.display.copyWith(
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: AppSpace.xs),
              Text(
                'Report civic issues, track live buses, and receive AI hazard alerts in 2 taps.',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: AppSpace.xl),

              // Form Card
              AppCard(
                padding: const EdgeInsets.all(AppSpace.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isRegisterMode
                          ? 'Create Citizen Account'
                          : 'Sign in to Smart City',
                      style: AppTypography.title.copyWith(
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: AppSpace.lg),

                    // Worldwide Region Selection (Country & Area / City / Village)
                    Text(
                      'Your Region (Worldwide)',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    InkWell(
                      onTap: _showCountryPicker,
                      borderRadius: AppRadius.mdBorder,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.md,
                          vertical: AppSpace.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted(context),
                          borderRadius: AppRadius.mdBorder,
                          border: Border.all(color: AppColors.outline(context)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              GlobalRegions.findCountry(_selectedCountry).flag,
                              style: AppTypography.subtitle,
                            ),
                            const SizedBox(width: AppSpace.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedCountry,
                                    style: AppTypography.subtitle.copyWith(
                                      color: AppColors.textPrimary(context),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Tap to switch country',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down_rounded),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpace.md),
                    AppTextField(
                      controller: _customAreaController,
                      label: 'City, Town or Village',
                      hint: 'e.g. Nintavur, London, Brooklyn, Dubai',
                      isRequired: true,
                      prefixIcon: const Icon(Icons.location_on_outlined),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Wrap(
                      spacing: AppSpace.xs,
                      runSpacing: 4,
                      children: GlobalRegions.findCountry(_selectedCountry)
                          .cities
                          .take(5)
                          .map((city) {
                        final isSelected = _customAreaController.text
                                .trim()
                                .toLowerCase() ==
                            city.name.toLowerCase();
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCity = city.name;
                              _customAreaController.text = city.name;
                            });
                          },
                          borderRadius: AppRadius.pillBorder,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary(context)
                                  : AppColors.surfaceMuted(context),
                              borderRadius: AppRadius.pillBorder,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary(context)
                                    : AppColors.outline(context),
                              ),
                            ),
                            child: Text(
                              city.name,
                              style: AppTypography.caption.copyWith(
                                color: isSelected
                                    ? AppColors.onPrimary(context)
                                    : AppColors.textSecondary(context),
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpace.lg),
                    AppTextField(
                      controller: _usernameController,
                      label: 'Username or Email',
                      hint: 'e.g. al_banna',
                      isRequired: true,
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                    ),
                    const SizedBox(height: AppSpace.lg),
                    AppTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Minimum 8 characters',
                      isRequired: true,
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppSpace.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpace.md),
                        decoration: BoxDecoration(
                          color: AppColors.dangerBg(context),
                          borderRadius: AppRadius.smBorder,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 18,
                              color: AppColors.danger(context),
                            ),
                            const SizedBox(width: AppSpace.sm),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.danger(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpace.xl),
                    AppButton(
                      label: _isRegisterMode ? 'Create Account' : 'Sign In',
                      icon: Icons.arrow_forward_rounded,
                      isLoading: _isLoading,
                      fullWidth: true,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSpace.md),
                    AppButton(
                      label: 'Continue as Citizen Guest',
                      icon: Icons.explore_outlined,
                      variant: AppButtonVariant.secondary,
                      fullWidth: true,
                      onPressed: _continueAsGuest,
                    ),
                    const SizedBox(height: AppSpace.sm),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isRegisterMode = !_isRegisterMode;
                            _errorMessage = null;
                          });
                        },
                        child: Text(
                          _isRegisterMode
                              ? 'Already have an account? Sign In'
                              : 'New citizen? Create an account',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
