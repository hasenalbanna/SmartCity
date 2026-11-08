import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mock_data.dart';
import '../models/travel_package.dart';
import '../services/clock_service.dart';
import '../services/notification_service.dart';
import '../services/payment_service.dart';
import '../widgets/liquid_background.dart';

// ══════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class WorldClockScreen extends StatelessWidget {
  const WorldClockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? const Color(0xFFEAF1FF)
        : const Color(0xFF10233D);
    final mutedColor = isDark
        ? const Color(0xFFB8C1D1)
        : const Color(0xFF74829B);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: LiquidBackground(
          child: SafeArea(
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      _backBtn(context, isDark, textColor),
                      const SizedBox(width: 14),
                      Text(
                        'World Clock',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2BC0E4), Color(0xFF8A7CFF)],
                          ),
                          borderRadius: BorderRadius.circular(19),
                        ),
                        child: const Icon(
                          Icons.public,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // ── Tab bar ──────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.white.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2BC0E4), Color(0xFF8A7CFF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: mutedColor,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: '🌍  Clocks'),
                      Tab(text: '⏱  Timer'),
                      Tab(text: '📅  Reminders'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // ── Tab views ────────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    children: [
                      _ClocksTab(
                        isDark: isDark,
                        textColor: textColor,
                        mutedColor: mutedColor,
                      ),
                      _TimerTab(
                        isDark: isDark,
                        textColor: textColor,
                        mutedColor: mutedColor,
                      ),
                      _RemindersTab(
                        isDark: isDark,
                        textColor: textColor,
                        mutedColor: mutedColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _backBtn(BuildContext context, bool isDark, Color textColor) {
    return GestureDetector(
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
            color: isDark ? Colors.white.withValues(alpha: 0.18) : Colors.white,
          ),
        ),
        child: Icon(Icons.arrow_back_ios_new, size: 16, color: textColor),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB 1 — CLOCKS
// ══════════════════════════════════════════════════════════════════════════════
class _ClocksTab extends StatelessWidget {
  final bool isDark;
  final Color textColor, mutedColor;
  const _ClocksTab({
    required this.isDark,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    final clock = context.watch<ClockService>();
    final clocks = clock.clocks;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        ...List.generate(
          clocks.length,
          (i) => _ClockCard(
            entry: clocks[i],
            time: clocks[i].currentTime,
            isDark: isDark,
            textColor: textColor,
            mutedColor: mutedColor,
            isPrimary: i == 0,
            onDelete: i == 0 ? null : () => clock.removeClock(i),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showAddSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF2BC0E4).withValues(alpha: 0.45),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2BC0E4), Color(0xFF8A7CFF)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Add City / Country',
                  style: TextStyle(
                    color: Color(0xFF2BC0E4),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddClockSheet(
        isDark: isDark,
        textColor: textColor,
        mutedColor: mutedColor,
        clock: context.read<ClockService>(),
      ),
    );
  }
}

// ── Clock card ──────────────────────────────────────────────────────────────
class _ClockCard extends StatelessWidget {
  final ClockEntry entry;
  final DateTime time;
  final bool isDark, isPrimary;
  final Color textColor, mutedColor;
  final VoidCallback? onDelete;

  const _ClockCard({
    required this.entry,
    required this.time,
    required this.isDark,
    required this.isPrimary,
    required this.textColor,
    required this.mutedColor,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final s = time.second.toString().padLeft(2, '0');
    final accent = isPrimary
        ? const Color(0xFF2BC0E4)
        : const Color(0xFF8A7CFF);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPrimary
              ? accent.withValues(alpha: 0.55)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.85)),
        ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Analog clock
          SizedBox(
            width: 72,
            height: 72,
            child: CustomPaint(
              painter: _AnalogPainter(
                time: time,
                isDark: isDark,
                accent: accent,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(entry.flag, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        entry.city,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isPrimary)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2BC0E4), Color(0xFF8A7CFF)],
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Text(
                          'HOME',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  entry.country,
                  style: TextStyle(fontSize: 12, color: mutedColor),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$h:$m',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      ':$s',
                      style: TextStyle(
                        fontSize: 16,
                        color: mutedColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  entry.formattedOffset,
                  style: TextStyle(
                    fontSize: 11,
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: Icon(Icons.close, size: 18, color: mutedColor),
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}

// ── Add clock bottom sheet ──────────────────────────────────────────────────
class _AddClockSheet extends StatefulWidget {
  final bool isDark;
  final Color textColor, mutedColor;
  final ClockService clock;
  const _AddClockSheet({
    required this.isDark,
    required this.textColor,
    required this.mutedColor,
    required this.clock,
  });
  @override
  State<_AddClockSheet> createState() => _AddClockSheetState();
}

class _AddClockSheetState extends State<_AddClockSheet> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final zones = ClockEntry.availableZones
        .where(
          (z) =>
              _q.isEmpty ||
              z.city.toLowerCase().contains(_q.toLowerCase()) ||
              z.country.toLowerCase().contains(_q.toLowerCase()),
        )
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0xFF1A1F2E)
            : const Color(0xFFF4FBFF),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.mutedColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Add a City',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: widget.textColor,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) => setState(() => _q = v),
            style: TextStyle(color: widget.textColor),
            decoration: InputDecoration(
              hintText: 'Search city or country…',
              hintStyle: TextStyle(color: widget.mutedColor),
              prefixIcon: Icon(Icons.search, color: widget.mutedColor),
              filled: true,
              fillColor: widget.isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: zones.length,
              itemBuilder: (_, i) {
                final z = zones[i];
                final added = widget.clock.clocks.any((c) => c.city == z.city);
                return ListTile(
                  leading: Text(z.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(
                    z.city,
                    style: TextStyle(
                      color: widget.textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    '${z.country} · ${z.formattedOffset}',
                    style: TextStyle(color: widget.mutedColor, fontSize: 12),
                  ),
                  trailing: added
                      ? const Icon(
                          Icons.check_circle,
                          color: Color(0xFF2BC0E4),
                          size: 20,
                        )
                      : Icon(
                          Icons.add_circle_outline,
                          color: widget.mutedColor,
                          size: 20,
                        ),
                  onTap: added
                      ? null
                      : () {
                          widget.clock.addClock(z);
                          Navigator.pop(context);
                        },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ANALOG CLOCK PAINTER
// ══════════════════════════════════════════════════════════════════════════════
class _AnalogPainter extends CustomPainter {
  final DateTime time;
  final bool isDark;
  final Color accent;
  _AnalogPainter({
    required this.time,
    required this.isDark,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Background
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: isDark
              ? [const Color(0xFF2A3050), const Color(0xFF1A1F2E)]
              : [Colors.white, const Color(0xFFE8F4FD)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    // Rim
    canvas.drawCircle(
      c,
      r - 1,
      Paint()
        ..color = accent.withValues(alpha: isDark ? 0.5 : 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Hour marks
    final markPaint = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF2D3436)).withValues(
        alpha: 0.45,
      )
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 12; i++) {
      final a = (i * 30 - 90) * math.pi / 180;
      canvas.drawLine(
        Offset(c.dx + (r - 10) * math.cos(a), c.dy + (r - 10) * math.sin(a)),
        Offset(c.dx + (r - 4) * math.cos(a), c.dy + (r - 4) * math.sin(a)),
        markPaint,
      );
    }

    // Hands
    _hand(
      canvas,
      c,
      ((time.hour % 12) + time.minute / 60) * 30 * math.pi / 180 - math.pi / 2,
      r * 0.50,
      Paint()
        ..color = isDark ? const Color(0xFFEAF1FF) : const Color(0xFF2D3436)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    _hand(
      canvas,
      c,
      (time.minute + time.second / 60) * 6 * math.pi / 180 - math.pi / 2,
      r * 0.70,
      Paint()
        ..color = isDark ? const Color(0xFFB8C1D1) : const Color(0xFF74829B)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    _hand(
      canvas,
      c,
      time.second * 6 * math.pi / 180 - math.pi / 2,
      r * 0.80,
      Paint()
        ..color = accent
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    // Centre dot
    canvas.drawCircle(c, 4, Paint()..color = accent);
    canvas.drawCircle(c, 2, Paint()..color = Colors.white);
  }

  void _hand(Canvas canvas, Offset c, double angle, double len, Paint paint) =>
      canvas.drawLine(
        c,
        Offset(c.dx + len * math.cos(angle), c.dy + len * math.sin(angle)),
        paint,
      );

  @override
  bool shouldRepaint(_AnalogPainter old) => old.time.second != time.second;
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB 2 — TIMER
// ══════════════════════════════════════════════════════════════════════════════
class _TimerTab extends StatelessWidget {
  final bool isDark;
  final Color textColor, mutedColor;
  const _TimerTab({
    required this.isDark,
    required this.textColor,
    required this.mutedColor,
  });

  static const _presets = [
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 10),
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(hours: 1),
  ];

  @override
  Widget build(BuildContext context) {
    final clock = context.watch<ClockService>();
    final notifications = context.watch<NotificationService>();
    final remaining = clock.timerRemaining;
    final total = clock.timerDuration;
    final progress = total.inSeconds > 0
        ? remaining.inSeconds / total.inSeconds
        : 0.0;
    final finished = clock.timerFinished;
    final completedAt = clock.lastTimerCompletedAt;
    if (finished && completedAt != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifications.addUnique(
          dedupeKey: 'timer_done_${completedAt.millisecondsSinceEpoch}',
          title: 'Timer completed',
          body: 'Your countdown has finished.',
          type: NotificationType.planReminder,
        );
      });
    }
    final mm = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        children: [
          // ── Circular progress ─────────────────────────────────────
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.10)
                        : Colors.grey.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      finished ? Colors.redAccent : const Color(0xFF2BC0E4),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$mm:$ss',
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: finished ? Colors.redAccent : textColor,
                        letterSpacing: -1,
                      ),
                    ),
                    if (finished)
                      const Text(
                        'Time\'s up! 🎉',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // ── Controls ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ctrlBtn(
                Icons.refresh,
                mutedColor,
                () => context.read<ClockService>().resetTimer(),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  final cs = context.read<ClockService>();
                  if (cs.timerRunning) {
                    cs.pauseTimer();
                  } else {
                    if (cs.timerFinished) cs.resetTimer();
                    cs.startTimer();
                  }
                },
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2BC0E4), Color(0xFF8A7CFF)],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2BC0E4).withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    clock.timerRunning ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              _ctrlBtn(Icons.stop, mutedColor, () {
                final cs = context.read<ClockService>();
                cs.pauseTimer();
                cs.resetTimer();
              }),
            ],
          ),
          const SizedBox(height: 28),
          // ── Quick presets ─────────────────────────────────────────
          Text(
            'Quick Presets',
            style: TextStyle(
              color: mutedColor,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _presets.map((d) {
              final label = d.inHours >= 1
                  ? '${d.inHours}h'
                  : '${d.inMinutes}m';
              final selected = clock.timerDuration == d;
              return GestureDetector(
                onTap: () => context.read<ClockService>().setTimerDuration(d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            colors: [Color(0xFF2BC0E4), Color(0xFF8A7CFF)],
                          )
                        : null,
                    color: selected
                        ? null
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.07)
                              : Colors.white.withValues(alpha: 0.72)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.85)),
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.white : textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          // ── Custom duration ───────────────────────────────────────
          GestureDetector(
            onTap: () => _showCustomDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.85),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_outlined, size: 16, color: mutedColor),
                  const SizedBox(width: 8),
                  Text(
                    'Custom Duration',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ctrlBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, size: 22, color: color),
        ),
      );

  void _showCustomDialog(BuildContext ctx) {
    int mins = 0, secs = 0;
    showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(
        builder: (dCtx, setS) => AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1A1F2E) : Colors.white,
          title: Text(
            'Custom Duration',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
          ),
          content: Row(
            children: [
              Expanded(
                child: _CounterField(
                  label: 'Minutes',
                  value: mins,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  onChanged: (v) => setS(() => mins = v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _CounterField(
                  label: 'Seconds',
                  value: secs,
                  textColor: textColor,
                  mutedColor: mutedColor,
                  onChanged: (v) => setS(() => secs = v),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dCtx),
              child: Text('Cancel', style: TextStyle(color: mutedColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2BC0E4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                final d = Duration(minutes: mins, seconds: secs);
                if (d.inSeconds > 0) {
                  ctx.read<ClockService>().setTimerDuration(d);
                }
                Navigator.pop(dCtx);
              },
              child: const Text('Set', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterField extends StatelessWidget {
  final String label;
  final int value;
  final Color textColor, mutedColor;
  final ValueChanged<int> onChanged;
  const _CounterField({
    required this.label,
    required this.value,
    required this.textColor,
    required this.mutedColor,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        style: TextStyle(
          color: mutedColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 4),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.remove_circle_outline, color: mutedColor),
            onPressed: value > 0 ? () => onChanged(value - 1) : null,
          ),
          Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF2BC0E4),
            ),
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    ],
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// TAB 3 — REMINDERS
// ══════════════════════════════════════════════════════════════════════════════
class _RemindersTab extends StatelessWidget {
  final bool isDark;
  final Color textColor, mutedColor;
  const _RemindersTab({
    required this.isDark,
    required this.textColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    final clock = context.watch<ClockService>();
    final notifications = context.watch<NotificationService>();
    final payment = context.watch<PaymentService>();
    final plan = clock.activePlan;
    final activity = clock.todaysPlanActivity;
    final dayIdx = clock.currentPlanDay;
    final completedBookings =
        payment.bookings
            .where((b) => b.paymentStatus == 'completed')
            .toList(growable: false)
          ..sort((a, b) => a.tripDate.compareTo(b.tripDate));

    // Auto-queue today's plan reminder notification (idempotent)
    if (plan != null && activity != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifications.checkPlanReminder(
          packageId: plan.id,
          packageTitle: plan.title,
          dayIndex: dayIdx,
          activity: activity,
        );
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Active plan card ──────────────────────────────────────
          if (plan != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2BC0E4), Color(0xFF8A7CFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2BC0E4).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🗺️', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          plan.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            context.read<ClockService>().clearActivePlan(),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (dayIdx < 0)
                    const Text(
                      'Plan hasn\'t started yet',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    )
                  else if (activity != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Day ${dayIdx + 1} — Today',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activity,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const Text(
                      '🎉 Plan completed!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    'Started: ${clock.planStartDate != null ? _fmtDate(clock.planStartDate!) : '—'}',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── Itinerary list ────────────────────────────────────
            Text(
              'Full Itinerary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            ...List.generate(plan.itinerary.length, (i) {
              final isToday = i == dayIdx;
              final isPast = i < dayIdx;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: isToday
                      ? const LinearGradient(
                          colors: [Color(0xFF2BC0E4), Color(0xFF8A7CFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isToday
                      ? null
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.07)
                            : Colors.white.withValues(alpha: 0.75)),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isToday
                        ? Colors.transparent
                        : (isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.85)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isToday
                            ? Colors.white.withValues(alpha: 0.25)
                            : (isPast
                                  ? const Color(
                                      0xFF2BC0E4,
                                    ).withValues(alpha: 0.15)
                                  : (isDark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.grey.withValues(alpha: 0.12))),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: isPast && !isToday
                            ? const Icon(
                                Icons.check,
                                size: 14,
                                color: Color(0xFF2BC0E4),
                              )
                            : Text(
                                '${i + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isToday ? Colors.white : textColor,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        plan.itinerary[i],
                        style: TextStyle(
                          color: isToday ? Colors.white : textColor,
                          fontWeight: isToday
                              ? FontWeight.w700
                              : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (isToday)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'TODAY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ] else ...[
            // ── No active plan ─────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.85),
                ),
              ),
              child: Column(
                children: [
                  const Text('🗺️', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    'No active plan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Set a travel plan to get daily reminders',
                    style: TextStyle(color: mutedColor, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (completedBookings.isNotEmpty) ...[
            Text(
              'Booked Trips',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 10),
            ...completedBookings.take(4).map((booking) {
              final tripDate = booking.tripDate;
              final isUpcoming = tripDate.isAfter(DateTime.now());
              if (isUpcoming) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  notifications.addUnique(
                    dedupeKey:
                        'booking_${booking.id}_${tripDate.year}${tripDate.month}${tripDate.day}',
                    title: 'Upcoming trip',
                    body:
                        '${booking.packageTitle} starts on ${_fmtDate(tripDate)}.',
                    type: NotificationType.planReminder,
                  );
                });
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.luggage, color: Color(0xFF2BC0E4)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.packageTitle,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            _fmtDate(tripDate),
                            style: TextStyle(color: mutedColor, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final paymentService = context.read<PaymentService>();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tripDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 3),
                          ),
                        );
                        if (picked == null) return;
                        await paymentService.updateBookingTripDate(
                          booking.id,
                          picked,
                        );
                        if (!context.mounted) return;
                        notifications.add(
                          title: 'Booking updated',
                          body:
                              '${booking.packageTitle} moved to ${_fmtDate(picked)}.',
                          type: NotificationType.planReminder,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Trip date updated.')),
                        );
                      },
                      child: const Text('Edit'),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
          // ── Set / change plan button ──────────────────────────────
          GestureDetector(
            onTap: () => _showPlanSheet(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2BC0E4), Color(0xFF8A7CFF)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2BC0E4).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  plan != null ? '🔄  Change Plan' : '+  Set Active Plan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const m = [
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
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  void _showPlanSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelectPlanSheet(
        isDark: isDark,
        textColor: textColor,
        mutedColor: mutedColor,
      ),
    );
  }
}

// ── Select plan sheet ────────────────────────────────────────────────────────
class _SelectPlanSheet extends StatefulWidget {
  final bool isDark;
  final Color textColor, mutedColor;
  const _SelectPlanSheet({
    required this.isDark,
    required this.textColor,
    required this.mutedColor,
  });
  @override
  State<_SelectPlanSheet> createState() => _SelectPlanSheetState();
}

class _SelectPlanSheetState extends State<_SelectPlanSheet> {
  TravelPackage? _selected;
  DateTime _startDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0xFF1A1F2E)
            : const Color(0xFFF4FBFF),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.mutedColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Choose a Travel Plan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: widget.textColor,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 240,
            child: ListView.builder(
              itemCount: mockPackages.length,
              itemBuilder: (_, i) {
                final pkg = mockPackages[i];
                final sel = _selected?.id == pkg.id;
                return GestureDetector(
                  onTap: () => setState(() => _selected = pkg),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: sel
                          ? const LinearGradient(
                              colors: [Color(0xFF2BC0E4), Color(0xFF8A7CFF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: sel
                          ? null
                          : (widget.isDark
                                ? Colors.white.withValues(alpha: 0.07)
                                : Colors.white.withValues(alpha: 0.75)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: sel
                            ? Colors.transparent
                            : (widget.isDark
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : Colors.white.withValues(alpha: 0.85)),
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            pkg.imageAsset,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey[300],
                              child: const Icon(Icons.landscape),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pkg.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: sel ? Colors.white : widget.textColor,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                pkg.duration,
                                style: TextStyle(
                                  color: sel
                                      ? Colors.white70
                                      : widget.mutedColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (sel)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_selected != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2030),
                );
                if (d != null) setState(() => _startDate = d);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Color(0xFF2BC0E4),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Start: ${_fmtDate(_startDate)}',
                      style: TextStyle(
                        color: widget.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: widget.mutedColor),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                context.read<ClockService>().setActivePlan(
                  _selected!,
                  _startDate,
                );
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2BC0E4), Color(0xFF8A7CFF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Activate Plan 🚀',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const m = [
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
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }
}
