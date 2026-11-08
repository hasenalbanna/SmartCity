import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../services/notification_service.dart';
import '../services/social_service.dart';
import '../widgets/liquid_background.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? const Color(0xFFEAF1FF)
        : const Color(0xFF10233D);
    final mutedColor = isDark
        ? const Color(0xFFB8C1D1)
        : const Color(0xFF74829B);
    final ns = context.watch<NotificationService>();
    final notifications = ns.notifications;

    return Scaffold(
      body: LiquidBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.09)
                              : Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.18)
                                : Colors.white,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                    ),
                    const Spacer(),
                    if (notifications.isNotEmpty) ...[
                      GestureDetector(
                        onTap: () =>
                            context.read<NotificationService>().markAllRead(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.09)
                                : Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Mark all read',
                            style: TextStyle(
                              color: Color(0xFF2BC0E4),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () =>
                            context.read<NotificationService>().clearAll(),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.09)
                                : Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: mutedColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // ── List ────────────────────────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                  children: [
                    _buildSocialRealtimeSection(
                      context,
                      isDark,
                      textColor,
                      mutedColor,
                    ),
                    const SizedBox(height: 12),
                    if (notifications.isNotEmpty)
                      ...notifications.map((n) {
                        return GestureDetector(
                          onTap: () => context
                              .read<NotificationService>()
                              .markRead(n.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: n.isRead
                                  ? (isDark
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.white.withValues(alpha: 0.65))
                                  : (isDark
                                        ? const Color(
                                            0xFF2BC0E4,
                                          ).withValues(alpha: 0.12)
                                        : const Color(
                                            0xFF2BC0E4,
                                          ).withValues(alpha: 0.07)),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.title,
                                  style: TextStyle(
                                    fontWeight: n.isRead
                                        ? FontWeight.w600
                                        : FontWeight.w800,
                                    color: textColor,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  n.body,
                                  style: TextStyle(
                                    color: mutedColor,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _relTime(n.time),
                                  style: TextStyle(
                                    color: mutedColor.withValues(alpha: 0.7),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    if (notifications.isEmpty)
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔔', style: TextStyle(fontSize: 52)),
                            const SizedBox(height: 12),
                            Text(
                              'No local notifications yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: textColor,
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
    );
  }

  Widget _buildSocialRealtimeSection(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color mutedColor,
  ) {
    final social = context.read<SocialService>();

    return StreamBuilder(
      stream: social.notificationsStream(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? const [];
        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('No social notifications yet.'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Realtime Social',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ...docs.map((doc) {
              final data = doc.data();
              final raw = data['createdAt'];
              final dt = raw is DateTime
                  ? raw
                  : DateTime.tryParse('$raw') ?? DateTime.now();
              final isRead = data['isRead'] == true;

              return GestureDetector(
                onTap: () => social.markNotificationRead(doc.id),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isRead
                        ? (isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.white)
                        : const Color(0xFF2BC0E4).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${data['title'] ?? 'Update'}',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${data['body'] ?? ''}',
                        style: TextStyle(color: mutedColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _relTime(dt),
                        style: TextStyle(color: mutedColor, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  String _relTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}
