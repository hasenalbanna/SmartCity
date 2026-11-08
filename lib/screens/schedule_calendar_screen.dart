import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/clock_service.dart';
import '../services/notification_service.dart';
import '../services/payment_service.dart';

class ScheduleCalendarScreen extends StatefulWidget {
  const ScheduleCalendarScreen({super.key});

  @override
  State<ScheduleCalendarScreen> createState() => _ScheduleCalendarScreenState();
}

class _ScheduleCalendarScreenState extends State<ScheduleCalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.92);
    final textColor = isDark
        ? const Color(0xFFEAF1FF)
        : const Color(0xFF10233D);
    final mutedColor = isDark
        ? const Color(0xFFAAB8CF)
        : const Color(0xFF64748B);

    final payment = context.watch<PaymentService>();
    final clock = context.watch<ClockService>();

    final bookings = payment.bookings
        .where((b) => b.paymentStatus == 'completed')
        .toList(growable: false);

    final markedDates = <String>{
      for (final b in bookings) _dateKey(b.tripDate),
    };

    final plan = clock.activePlan;
    final planStart = clock.planStartDate;
    if (plan != null && planStart != null) {
      for (var i = 0; i < plan.itinerary.length; i++) {
        markedDates.add(_dateKey(planStart.add(Duration(days: i))));
      }
    }

    final selectedBookings = bookings
        .where((b) => _isSameDay(b.tripDate, _selectedDate))
        .toList(growable: false);

    String? selectedPlanActivity;
    int? selectedPlanDay;
    if (plan != null && planStart != null) {
      final dayOffset = _selectedDate
          .difference(DateTime(planStart.year, planStart.month, planStart.day))
          .inDays;
      if (dayOffset >= 0 && dayOffset < plan.itinerary.length) {
        selectedPlanActivity = plan.itinerary[dayOffset];
        selectedPlanDay = dayOffset + 1;
      }
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B1220)
          : const Color(0xFFF2F7FF),
      appBar: AppBar(title: const Text('Travel Calendar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : const Color(0xFFD7E5F6),
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(
                  context,
                ).colorScheme.copyWith(primary: const Color(0xFF2BC0E4)),
              ),
              child: CalendarDatePicker(
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                onDateChanged: (value) => setState(() => _selectedDate = value),
                selectableDayPredicate: (_) => true,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _legendDot('Booked trips', const Color(0xFF2BC0E4), textColor),
              _legendDot('Plan day', const Color(0xFF8A7CFF), textColor),
              _legendDot('Has event', const Color(0xFF22C55E), textColor),
            ],
          ),
          const SizedBox(height: 12),
          if (markedDates.contains(_dateKey(_selectedDate)))
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.45),
                ),
              ),
              child: Text(
                'This date has planned activity or booking.',
                style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
              ),
            ),
          const SizedBox(height: 14),
          Text(
            'Selected Day',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          if (selectedPlanActivity != null)
            _eventTile(
              context,
              icon: Icons.auto_awesome,
              title: 'Trip plan • Day $selectedPlanDay',
              subtitle: selectedPlanActivity,
              accent: const Color(0xFF8A7CFF),
              actionLabel: 'Move plan start',
              onAction: () async {
                final clockService = context.read<ClockService>();
                final notifications = context.read<NotificationService>();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: clock.planStartDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                );
                if (picked == null || plan == null) return;
                clockService.setActivePlan(plan, picked);
                if (!context.mounted) return;
                notifications.add(
                  title: 'Plan updated',
                  body:
                      'Your active itinerary now starts on ${_fmtDate(picked)}.',
                  type: NotificationType.planReminder,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Plan start date updated.')),
                );
              },
            ),
          ...selectedBookings.map(
            (booking) => _eventTile(
              context,
              icon: Icons.luggage_rounded,
              title: booking.packageTitle,
              subtitle:
                  'Trip date ${_fmtDate(booking.tripDate)} • ${booking.numberOfPeople} traveler(s)',
              accent: const Color(0xFF2BC0E4),
              actionLabel: 'Edit date',
              onAction: () async {
                final paymentService = context.read<PaymentService>();
                final note = context.read<NotificationService>();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: booking.tripDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                );
                if (picked == null) return;

                final ok = await paymentService.updateBookingTripDate(
                  booking.id,
                  picked,
                );
                if (!context.mounted) return;

                if (ok) {
                  note.add(
                    title: 'Booking updated',
                    body:
                        '${booking.packageTitle} moved to ${_fmtDate(picked)}.',
                    type: NotificationType.planReminder,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking date updated.')),
                  );
                }
              },
            ),
          ),
          if (selectedPlanActivity == null && selectedBookings.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xFFD7E5F6),
                ),
              ),
              child: Text(
                'No booking or itinerary item on this day yet.',
                style: TextStyle(color: mutedColor),
              ),
            ),
          const SizedBox(height: 14),
          Text(
            'Upcoming bookings',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          if (bookings.isEmpty)
            Text(
              'No completed bookings yet.',
              style: TextStyle(color: mutedColor),
            ),
          ...bookings
              .take(4)
              .map(
                (b) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF22C55E),
                  ),
                  title: Text(
                    b.packageTitle,
                    style: TextStyle(color: textColor),
                  ),
                  subtitle: Text(
                    _fmtDate(b.tripDate),
                    style: TextStyle(color: mutedColor),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _eventTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accent,
    required String actionLabel,
    required Future<void> Function() onAction,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? const Color(0xFFEAF1FF)
        : const Color(0xFF10233D);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.72),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }

  Widget _legendDot(String label, Color color, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: textColor, fontSize: 12)),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  String _fmtDate(DateTime d) {
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
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
