import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/localization_service.dart';
import '../services/currency_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        title: Consumer<LocalizationService>(
          builder: (context, loc, _) => Text(loc.translate('settings')),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Consumer2<LocalizationService, CurrencyService>(
        builder: (context, localization, currencyService, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Language Section
                _buildSectionTitle('Language / භාෂාව / மொழி'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: LocalizationService.supportedLanguages.entries
                        .map((entry) {
                          final isSelected =
                              localization.currentLanguage == entry.key;
                          return _buildLanguageOption(
                            context,
                            entry.key,
                            entry.value,
                            isSelected,
                            () => localization.setLanguage(entry.key),
                          );
                        })
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Currency Section
                _buildSectionTitle(localization.currentLanguage == 'si' 
                  ? 'මුදල් වර්ගය' 
                  : localization.currentLanguage == 'ta' ? 'நாணயம்' : 'Currency'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: CurrencyService.supportedCurrencies.entries
                        .map((entry) {
                          final isSelected =
                              currencyService.currentCurrency == entry.key;
                          return _buildCurrencyOption(
                            context,
                            entry.key,
                            entry.value,
                            isSelected,
                            () => currencyService.setCurrency(entry.key),
                          );
                        })
                        .toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // App Settings
                _buildSectionTitle(localization.translate('settings')),
                const SizedBox(height: 8),
                _buildSettingsCard([
                  _buildSettingsTile(
                    Icons.notifications_outlined,
                    'Push Notifications',
                    trailing: Switch(
                      value: true,
                      onChanged: (_) {},
                      activeThumbColor: const Color(0xFF87CEEB),
                    ),
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    Icons.dark_mode_outlined,
                    'Dark Mode',
                    trailing: Switch(
                      value: false,
                      onChanged: (_) {},
                      activeThumbColor: const Color(0xFF87CEEB),
                    ),
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    Icons.location_on_outlined,
                    'Location Services',
                    trailing: Switch(
                      value: true,
                      onChanged: (_) {},
                      activeThumbColor: const Color(0xFF87CEEB),
                    ),
                  ),
                ]),
                const SizedBox(height: 24),

                // Account
                _buildSectionTitle('Account'),
                const SizedBox(height: 8),
                _buildSettingsCard([
                  _buildSettingsTile(
                    Icons.person_outline,
                    'Edit Profile',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    Icons.lock_outline,
                    'Change Password',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    Icons.credit_card_outlined,
                    'Payment Methods',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 24),

                // Support
                _buildSectionTitle('Support'),
                const SizedBox(height: 8),
                _buildSettingsCard([
                  _buildSettingsTile(
                    Icons.help_outline,
                    'Help Center',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    Icons.chat_bubble_outline,
                    'Contact Us',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    Icons.privacy_tip_outlined,
                    'Privacy Policy',
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _buildSettingsTile(
                    Icons.description_outlined,
                    'Terms of Service',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 24),

                // App Info
                _buildSettingsCard([
                  _buildSettingsTile(
                    Icons.info_outline,
                    'App Version',
                    subtitle: '1.0.0',
                  ),
                ]),
                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text(
                            'Are you sure you want to logout?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                // Handle logout
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text(
                                'Logout',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String code,
    String name,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final flag = _getLanguageFlag(code);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    code.toUpperCase(),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF87CEEB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(
    BuildContext context,
    String code,
    String name,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF87CEEB).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name.split(' ')[0],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF87CEEB),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    code,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF87CEEB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  String _getLanguageFlag(String code) {
    switch (code) {
      case 'en':
        return '🇬🇧';
      case 'si':
        return '🇱🇰';
      case 'ta':
        return '🇮🇳';
      case 'hi':
        return '🇮🇳';
      case 'fr':
        return '🇫🇷';
      case 'ml':
        return '🇮🇳';
      case 'kn':
        return '🇮🇳';
      case 'de':
        return '🇩🇪';
      case 'zh':
        return '🇨🇳';
      case 'ja':
        return '🇯🇵';
      case 'ru':
        return '🇷🇺';
      default:
        return '🌐';
    }
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title, {
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF87CEEB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF87CEEB), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (onTap != null)
              Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
