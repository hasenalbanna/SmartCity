import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/system_feature_screens.dart';
import '../services/notification_service.dart';
import '../services/subscription_service.dart';
import '../services/theme_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'premium_store_modal.dart';

class AppTopUtilities extends StatelessWidget {
  final EdgeInsetsGeometry padding;

  const AppTopUtilities({
    super.key,
    this.padding = const EdgeInsets.only(bottom: AppSpace.md),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unread = context.watch<NotificationService>().unreadCount;
    final screenW = MediaQuery.sizeOf(context).width;
    final isCompact = screenW < 440;
    final gap = screenW < 370 ? 3.0 : (isCompact ? 4.0 : AppSpace.sm);
    final boxSize = screenW < 370 ? 30.0 : (isCompact ? 34.0 : 40.0);

    final boxBg = isDark ? Colors.black : Colors.white;
    final boxBorder = isDark ? Colors.white24 : Colors.black12;
    final iconColor = isDark ? Colors.white : Colors.black;
    final badgeBg = isDark ? Colors.white : Colors.black;
    final badgeFg = isDark ? Colors.black : Colors.white;

    return Padding(
      padding: padding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top-of-page prominent Subscription & Pro Button
            _buildSubscriptionButton(context, isDark, boxSize, isCompact),
            SizedBox(width: gap),
            _buildUtilityButton(
              tooltip: 'Realtime Chat',
              icon: Icons.chat_bubble_outline_rounded,
              boxBg: boxBg,
              boxBorder: boxBorder,
              iconColor: iconColor,
              boxSize: boxSize,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatListScreen()),
              ),
            ),
          SizedBox(width: gap),
          _buildUtilityButton(
            tooltip: 'Toggle Light / Dark Mode',
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            boxBg: boxBg,
            boxBorder: boxBorder,
            iconColor: iconColor,
            boxSize: boxSize,
            onTap: () => context.read<ThemeService>().toggleTheme(),
          ),
          SizedBox(width: gap),
          _buildUtilityButton(
            tooltip: 'Schedule Calendar',
            icon: Icons.calendar_month_outlined,
            boxBg: boxBg,
            boxBorder: boxBorder,
            iconColor: iconColor,
            boxSize: boxSize,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ScheduleCalendarScreen(),
              ),
            ),
          ),
          SizedBox(width: gap),
          _buildUtilityButton(
            tooltip: 'World Clock & Timer',
            icon: Icons.access_time_outlined,
            boxBg: boxBg,
            boxBorder: boxBorder,
            iconColor: iconColor,
            boxSize: boxSize,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorldClockScreen()),
            ),
          ),
          SizedBox(width: gap),
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
                  boxSize: boxSize,
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
    ),
  );
  }

  Widget _buildSubscriptionButton(
    BuildContext context,
    bool isDark,
    double boxSize,
    bool isCompact,
  ) {
    final sub = context.watch<SubscriptionService>();
    final accentGold = AppColors.accentAmber(context);
    final isPro = sub.isProOrHigher;

    final bg = isPro
        ? (isDark ? const Color(0xFF1F1A0E) : const Color(0xFFFEF3C7))
        : (isDark ? const Color(0xFF1A1608) : const Color(0xFFFFFBEB));
    final border = isPro
        ? accentGold.withValues(alpha: 0.65)
        : accentGold.withValues(alpha: 0.85);

    return Tooltip(
      message: isPro
          ? '${sub.currentPlanName} Active • Tap for benefits'
          : 'Upgrade to Falcon Shield+ Pro (\$4.99/mo) • Unlock All Features',
      child: InkWell(
        onTap: () => PremiumStoreModal.show(context),
        borderRadius: AppRadius.mdBorder,
        child: Container(
          height: boxSize,
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? AppSpace.sm : AppSpace.md,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: AppRadius.mdBorder,
            border: Border.all(color: border, width: 1.4),
            boxShadow: [
              if (!isPro)
                BoxShadow(
                  color: accentGold.withValues(alpha: isDark ? 0.25 : 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPro ? Icons.workspace_premium_rounded : Icons.bolt_rounded,
                size: boxSize <= 34 ? 15 : 18,
                color: accentGold,
              ),
              const SizedBox(width: 5),
              Text(
                isPro
                    ? (isCompact ? 'PRO' : 'PRO ACTIVE')
                    : (isCompact ? 'UPGRADE' : '⚡ UPGRADE TO PRO'),
                style: AppTypography.caption.copyWith(
                  color: isDark ? Colors.white : const Color(0xFF78350F),
                  fontWeight: FontWeight.w900,
                  fontSize: isCompact ? 10 : 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUtilityButton({
    required String tooltip,
    required IconData icon,
    required Color boxBg,
    required Color boxBorder,
    required Color iconColor,
    required double boxSize,
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
          boxSize: boxSize,
        ),
      ),
    );
  }

  Widget _buildIconBox(
    IconData icon, {
    required Color boxBg,
    required Color boxBorder,
    required Color iconColor,
    required double boxSize,
  }) {
    return Container(
      width: boxSize,
      height: boxSize,
      decoration: BoxDecoration(
        color: boxBg,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: boxBorder),
      ),
      child: Icon(
        icon,
        size: boxSize <= 34 ? 16 : 19,
        color: iconColor,
      ),
    );
  }
}
