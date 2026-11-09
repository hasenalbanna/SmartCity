import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
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
  bool _isRegisterMode = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthService>();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = _isRegisterMode
        ? await auth.register(username, password)
        : await auth.login(username, password);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _errorMessage = success ? null : auth.lastError;
    });

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  void _continueAsGuest() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
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
