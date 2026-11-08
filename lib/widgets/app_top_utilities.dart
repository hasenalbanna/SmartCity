import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/chat_list_screen.dart';
import '../screens/schedule_calendar_screen.dart';
import '../screens/world_clock_screen.dart';
import '../screens/notifications_screen.dart';
import '../services/theme_service.dart';
import '../services/notification_service.dart';

class AppTopUtilities extends StatelessWidget {
  const AppTopUtilities({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final unread = context.watch<NotificationService>().unreadCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _btn(
            context,
            icon: Icons.chat_bubble_outline,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatListScreen()),
            ),
          ),
          const SizedBox(width: 8),
          _btn(
            context,
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            onTap: () => context.read<ThemeService>().toggleTheme(),
          ),
          const SizedBox(width: 8),
          _btn(
            context,
            icon: Icons.calendar_month_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScheduleCalendarScreen()),
            ),
          ),
          const SizedBox(width: 8),
          _btn(
            context,
            icon: Icons.access_time_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorldClockScreen()),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _box(context, Icons.notifications_outlined),
                if (unread > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFF7BC1), Color(0xFF8A7CFF)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          unread > 9 ? '9+' : '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
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

  Widget _btn(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) => GestureDetector(onTap: onTap, child: _box(context, icon));

  Widget _box(BuildContext context, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : const Color(0xFF2BC0E4).withValues(alpha: 0.14),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 18,
        color: isDark ? const Color(0xFFE9EDF5) : const Color(0xFF10233D),
      ),
    );
  }
}
