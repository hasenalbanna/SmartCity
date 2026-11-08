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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unread = context.watch<NotificationService>().unreadCount;

    final boxBg = isDark ? Colors.black : Colors.white;
    final boxBorder = isDark ? Colors.white24 : Colors.black12;
    final iconColor = isDark ? Colors.white : Colors.black;
    final badgeBg = isDark ? Colors.white : Colors.black;
    final badgeFg = isDark ? Colors.black : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.md),
      child: Row(
        children: [
          _buildUtilityButton(
            tooltip: 'Realtime Chat',
            icon: Icons.chat_bubble_outline_rounded,
            boxBg: boxBg,
            boxBorder: boxBorder,
            iconColor: iconColor,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatListScreen()),
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          _buildUtilityButton(
            tooltip: 'Toggle Light / Dark Mode',
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            boxBg: boxBg,
            boxBorder: boxBorder,
            iconColor: iconColor,
            onTap: () => context.read<ThemeService>().toggleTheme(),
          ),
          const SizedBox(width: AppSpace.sm),
          _buildUtilityButton(
            tooltip: 'Schedule Calendar',
            icon: Icons.calendar_month_outlined,
            boxBg: boxBg,
            boxBorder: boxBorder,
            iconColor: iconColor,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ScheduleCalendarScreen(),
              ),
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          _buildUtilityButton(
            tooltip: 'World Clock & Timer',
            icon: Icons.access_time_outlined,
            boxBg: boxBg,
            boxBorder: boxBorder,
            iconColor: iconColor,
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
                _buildIconBox(
                  Icons.notifications_outlined,
                  boxBg: boxBg,
                  boxBorder: boxBorder,
                  iconColor: iconColor,
                ),
                if (unread > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: boxBg, width: 1.5),
                      ),
                      child: Text(
                        unread > 9 ? '9+' : '$unread',
                        style: AppTypography.caption.copyWith(
                          color: badgeFg,
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

  Widget _buildUtilityButton({
    required String tooltip,
    required IconData icon,
    required Color boxBg,
    required Color boxBorder,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: _buildIconBox(
          icon,
          boxBg: boxBg,
          boxBorder: boxBorder,
          iconColor: iconColor,
        ),
      ),
    );
  }

  Widget _buildIconBox(
    IconData icon, {
    required Color boxBg,
    required Color boxBorder,
    required Color iconColor,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: boxBorder),
      ),
      child: Icon(
        icon,
        size: 19,
        color: iconColor,
      ),
    );
  }
}
