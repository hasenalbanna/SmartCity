import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/system_feature_screens.dart';
import '../services/notification_service.dart';
import '../services/theme_service.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class AppTopUtilities extends StatelessWidget {
  const AppTopUtilities({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final unread = context.watch<NotificationService>().unreadCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.md),
      child: Row(
        children: [
          _buildUtilityButton(
            context,
            tooltip: 'Realtime Chat',
            icon: Icons.chat_bubble_outline_rounded,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatListScreen()),
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          _buildUtilityButton(
            context,
            tooltip: 'Toggle Theme',
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            onTap: () => context.read<ThemeService>().toggleTheme(),
          ),
          const SizedBox(width: AppSpace.sm),
          _buildUtilityButton(
            context,
            tooltip: 'Schedule Calendar',
            icon: Icons.calendar_month_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ScheduleCalendarScreen(),
              ),
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          _buildUtilityButton(
            context,
            tooltip: 'World Clock & Timer',
            icon: Icons.access_time_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorldClockScreen()),
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            borderRadius: AppRadius.mdBorder,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildIconBox(Icons.notifications_outlined),
                if (unread > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unread > 9 ? '9+' : '$unread',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityButton(
    BuildContext context, {
    required String tooltip,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: _buildIconBox(icon),
      ),
    );
  }

  Widget _buildIconBox(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: Colors.black12),
      ),
      child: Icon(
        icon,
        size: 19,
        color: Colors.black,
      ),
    );
  }
}
