import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../data/hotels_data.dart';
import '../data/mock_data.dart';
import '../data/sri_lanka_places.dart';
import '../models/guide.dart';
import '../services/clock_service.dart';
import '../services/community_issue_service.dart';
import '../services/currency_service.dart';
import '../services/notification_service.dart';
import '../services/subscription_service.dart';
import '../services/theme_service.dart';
import '../services/trip_history_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/instagram_feed_section.dart';
import '../widgets/premium_store_modal.dart';
import '../widgets/ui/ui.dart';
import 'hotel_detail_screen.dart';
import 'itinerary_screen.dart';

// ============================================================================
// 1. FULL-SCREEN INTERACTIVE ISLAND & SMART CITY MAP SCREEN
// ============================================================================
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  String _selectedFilter = 'All';
  SriLankaPlace? _selectedPlace;

  static const List<String> _filters = [
    'All',
    'UNESCO Heritage',
    'Beaches',
    'Wildlife',
    'Civic Issues',
  ];

  @override
  Widget build(BuildContext context) {
    final issueService = context.watch<CommunityIssueService>();
    final places = sriLankaPlaces.where((p) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Civic Issues') return false;
      return p.category.toLowerCase().contains(_selectedFilter.toLowerCase());
    }).toList();

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Interactive Island & Smart City Map'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ItineraryScreen()),
              );
            },
            icon: const Icon(Icons.route_outlined, size: 18),
            label: const Text('Route Planner'),
          ),
          const SizedBox(width: AppSpace.sm),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.lg,
              AppSpace.sm,
              AppSpace.lg,
              AppSpace.sm,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final selected = _selectedFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpace.sm),
                    child: ChoiceChip(
                      label: Text(f),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedFilter = f),
                      selectedColor: AppColors.primary(context),
                      labelStyle: AppTypography.caption.copyWith(
                        color: selected
                            ? Colors.white
                            : AppColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.lg,
                0,
                AppSpace.lg,
                AppSpace.lg,
              ),
              child: ClipRRect(
                borderRadius: AppRadius.lgBorder,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: const MapOptions(
                        initialCenter: LatLng(7.55, 80.75),
                        initialZoom: 7.4,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.smartcity.app',
                        ),
                        MarkerLayer(
                          markers: [
                            ...places.map(
                              (place) => Marker(
                                point: place.location,
                                width: 110,
                                height: 44,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedPlace = place),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpace.sm,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary(context),
                                      borderRadius: AppRadius.pillBorder,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(place.emoji),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            place.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.caption
                                                .copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_selectedFilter == 'All' ||
                                _selectedFilter == 'Civic Issues')
                              ...issueService.issues.map(
                                (issue) => Marker(
                                  point: issue.location,
                                  width: 36,
                                  height: 36,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.danger(context),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.report_problem_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    if (_selectedPlace != null)
                      Positioned(
                        left: AppSpace.md,
                        right: AppSpace.md,
                        bottom: AppSpace.md,
                        child: AppCard(
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: AppRadius.smBorder,
                                child: Image.asset(
                                  _selectedPlace!.imageUrl,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    width: 72,
                                    height: 72,
                                    color: AppColors.surfaceMuted(context),
                                    child: const Icon(Icons.landscape_outlined),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpace.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${_selectedPlace!.emoji} ${_selectedPlace!.name}',
                                      style: AppTypography.subtitle.copyWith(
                                        color: AppColors.textPrimary(context),
                                      ),
                                    ),
                                    Text(
                                      _selectedPlace!.shortDescription,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textSecondary(context),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Best time: ${_selectedPlace!.bestTimeToVisit} • ★ ${_selectedPlace!.rating}',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.primary(context),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () =>
                                    setState(() => _selectedPlace = null),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// MINIMAL BLACK & WHITE PRIMITIVES FOR TOP UTILITY PAGES
// (Chat, Calendar, World Clock & Notifications)
// Light Mode: Pure White BG + Black Text + Solid Black Buttons with White Text
// Dark Mode:  Pure Black BG + White Text + Solid White/Black Monochrome Buttons
// Zero Extra Color — Clean Minimal & Premium
// ============================================================================
class _MinimalMonochromeScaffold extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget body;

  const _MinimalMonochromeScaffold({
    required this.title,
    this.actions,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final bg = isDark ? Colors.black : Colors.white;
    final fg = isDark ? Colors.white : Colors.black;
    final dividerColor = isDark ? Colors.white24 : Colors.black12;

    return Theme(
      data: (isDark ? ThemeData.dark() : ThemeData.light()).copyWith(
        scaffoldBackgroundColor: bg,
        colorScheme: isDark
            ? const ColorScheme.dark(
                primary: Colors.white,
                onPrimary: Colors.black,
                surface: Colors.black,
                onSurface: Colors.white,
              )
            : const ColorScheme.light(
                primary: Colors.black,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
      ),
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            title,
            style: AppTypography.title.copyWith(color: fg),
          ),
          actions: [
            IconButton(
              tooltip: 'Toggle Light / Dark Mode',
              onPressed: () => context.read<ThemeService>().toggleTheme(),
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: fg,
              ),
            ),
            ...?actions,
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: dividerColor),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: body,
          ),
        ),
      ),
    );
  }
}

class _MinimalBlackButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool outlined;

  const _MinimalBlackButton({
    required this.label,
    this.icon,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // In Light Mode: Solid Black button + White text (or White outlined with Black text)
    // In Dark Mode:  Solid White button + Black text (or Black outlined with White text)
    final Color fill = outlined
        ? (isDark ? Colors.black : Colors.white)
        : (isDark ? Colors.white : Colors.black);
    final Color textCol = outlined
        ? (isDark ? Colors.white : Colors.black)
        : (isDark ? Colors.black : Colors.white);
    final Color borderCol = isDark ? Colors.white : Colors.black;

    return InkWell(
      onTap: onPressed,
      borderRadius: AppRadius.mdBorder,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.lg,
          vertical: AppSpace.md,
        ),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: AppRadius.mdBorder,
          border: Border.all(color: borderCol, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: textCol,
              ),
              const SizedBox(width: AppSpace.xs),
            ],
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: textCol,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MinimalPremiumStrip extends StatelessWidget {
  final String title;
  final String subtitle;

  const _MinimalPremiumStrip({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sub = context.watch<SubscriptionService>();
    final bg = isDark ? Colors.black : Colors.white;
    final fg = isDark ? Colors.white : Colors.black;
    final muted = isDark ? Colors.white70 : Colors.black54;
    final border = isDark ? Colors.white24 : Colors.black26;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.lg),
      padding: const EdgeInsets.all(AppSpace.lg),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: fg,
              borderRadius: AppRadius.smBorder,
            ),
            child: Icon(
              Icons.workspace_premium_rounded,
              size: 20,
              color: bg,
            ),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyStrong.copyWith(color: fg),
                ),
                Text(
                  '${sub.currentPlanName} • $subtitle',
                  style: AppTypography.caption.copyWith(color: muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          _MinimalBlackButton(
            label: sub.isProOrHigher ? 'Pro Active' : 'Upgrade Pro',
            onPressed: () => PremiumStoreModal.show(context),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. TRAVEL & CIVIC SCHEDULE CALENDAR SCREEN (ULTRA-MINIMAL WHITE / BLACK)
// ============================================================================
class ScheduleCalendarScreen extends StatefulWidget {
  const ScheduleCalendarScreen({super.key});

  @override
  State<ScheduleCalendarScreen> createState() => _ScheduleCalendarScreenState();
}

class _ScheduleCalendarScreenState extends State<ScheduleCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<Map<String, String>> _events = [
    {
      'time': '06:30 AM',
      'title': 'Sigiriya Lion Rock Sunrise Ascent',
      'location': 'Central Province • UNESCO Heritage',
      'type': 'Itinerary',
    },
    {
      'time': '10:30 AM',
      'title': 'Nintavur Ward 04 Drainage & Road Inspection',
      'location': 'Addappalam Main Corridor',
      'type': 'Civic Ops',
    },
    {
      'time': '02:00 PM',
      'title': 'Kandy to Ella Scenic Highland Train',
      'location': 'Nanu Oya — Nine Arch Bridge',
      'type': 'Transit',
    },
    {
      'time': '06:00 PM',
      'title': 'Galle Fort Ramparts Sunset Walk & Dinner',
      'location': 'Southern Province',
      'type': 'Itinerary',
    },
  ];

  void _addScheduleItem() {
    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController(text: '09:00 AM');
    final locCtrl = TextEditingController(text: 'Colombo / Nintavur');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : Colors.white;
    final fg = isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgBorder,
          side: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
        ),
        title: Text(
          'Add Schedule Item',
          style: AppTypography.title.copyWith(color: fg),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              style: AppTypography.body.copyWith(color: fg),
              decoration: const InputDecoration(
                labelText: 'Activity Title',
                hintText: 'e.g. Yala Safari Morning Drive',
              ),
            ),
            const SizedBox(height: AppSpace.md),
            TextField(
              controller: timeCtrl,
              style: AppTypography.body.copyWith(color: fg),
              decoration: const InputDecoration(labelText: 'Time'),
            ),
            const SizedBox(height: AppSpace.md),
            TextField(
              controller: locCtrl,
              style: AppTypography.body.copyWith(color: fg),
              decoration: const InputDecoration(labelText: 'Location'),
            ),
          ],
        ),
        actions: [
          _MinimalBlackButton(
            label: 'Cancel',
            outlined: true,
            onPressed: () => Navigator.pop(ctx),
          ),
          _MinimalBlackButton(
            label: 'Save Event',
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _events.add({
                    'time': timeCtrl.text.trim(),
                    'title': titleCtrl.text.trim(),
                    'location': locCtrl.text.trim(),
                    'type': 'Custom',
                  });
                });
              }
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final bg = isDark ? Colors.black : Colors.white;
    final fg = isDark ? Colors.white : Colors.black;
    final muted = isDark ? Colors.white70 : Colors.black54;
    final border = isDark ? Colors.white24 : Colors.black12;

    return _MinimalMonochromeScaffold(
      title: 'Calendar',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpace.md),
          child: Center(
            child: _MinimalBlackButton(
              label: '+ Add Event',
              onPressed: _addScheduleItem,
            ),
          ),
        ),
      ],
      body: ListView(
        padding: AppSpace.pagePadding,
        children: [
          const _MinimalPremiumStrip(
            title: 'Smart Schedule & Priority SMS Reminders',
            subtitle: 'Auto-sync flights, trains & municipal inspections',
          ),
          Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppRadius.lgBorder,
              border: Border.all(color: border),
            ),
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime(2024),
              lastDate: DateTime(2030),
              onDateChanged: (d) => setState(() => _selectedDate = d),
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Schedule for ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                style: AppTypography.title.copyWith(color: fg),
              ),
              Text(
                '${_events.length} items',
                style: AppTypography.caption.copyWith(color: muted),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          ..._events.map(
            (ev) => Container(
              margin: const EdgeInsets.only(bottom: AppSpace.md),
              padding: const EdgeInsets.all(AppSpace.lg),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: AppRadius.mdBorder,
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.md,
                      vertical: AppSpace.xs,
                    ),
                    decoration: BoxDecoration(
                      color: fg,
                      borderRadius: AppRadius.smBorder,
                    ),
                    child: Text(
                      ev['time']!,
                      style: AppTypography.caption.copyWith(
                        color: bg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ev['title']!,
                          style: AppTypography.subtitle.copyWith(
                            color: fg,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ev['location']!,
                          style: AppTypography.caption.copyWith(
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: AppRadius.smBorder,
                      border: Border.all(color: border),
                    ),
                    child: Text(
                      ev['type']!,
                      style: AppTypography.caption.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w700,
                      ),
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
}

// ============================================================================
// 3. WORLD CLOCK & TRAVEL TIMER SCREEN (ULTRA-MINIMAL WHITE / BLACK)
// ============================================================================
class WorldClockScreen extends StatelessWidget {
  const WorldClockScreen({super.key});

  String _formatClockTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final clockService = context.watch<ClockService>();
    final isDark = context.watch<ThemeService>().isDarkMode;
    final bg = isDark ? Colors.black : Colors.white;
    final fg = isDark ? Colors.white : Colors.black;
    final muted = isDark ? Colors.white70 : Colors.black54;
    final border = isDark ? Colors.white24 : Colors.black12;

    return _MinimalMonochromeScaffold(
      title: 'World Clock & Timer',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpace.md),
          child: Center(
            child: _MinimalBlackButton(
              label: '+ Add City',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: bg,
                  builder: (ctx) => ListView(
                    padding: AppSpace.pagePadding,
                    children: ClockEntry.availableZones.map((zone) {
                      return ListTile(
                        leading: Text(zone.flag, style: AppTypography.title),
                        title: Text(
                          '${zone.city}, ${zone.country}',
                          style: AppTypography.bodyStrong.copyWith(
                            color: fg,
                          ),
                        ),
                        subtitle: Text(
                          zone.formattedOffset,
                          style: AppTypography.caption.copyWith(
                            color: muted,
                          ),
                        ),
                        trailing: _MinimalBlackButton(
                          label: 'Add',
                          onPressed: () {
                            clockService.addClock(zone);
                            Navigator.pop(ctx);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ),
      ],
      body: ListView(
        padding: AppSpace.pagePadding,
        children: [
          const _MinimalPremiumStrip(
            title: 'Multi-Zone Flight & Excursion Sync',
            subtitle: 'Unlimited global time zones & automated transit alerts',
          ),
          Text(
            'Time Zones',
            style: AppTypography.title.copyWith(color: fg),
          ),
          const SizedBox(height: 4),
          Text(
            'Live global clocks synchronized with Colombo (UTC+05:30)',
            style: AppTypography.caption.copyWith(color: muted),
          ),
          const SizedBox(height: AppSpace.md),
          ...clockService.clocks.asMap().entries.map((entry) {
            final idx = entry.key;
            final clock = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpace.md),
              padding: const EdgeInsets.all(AppSpace.lg),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: AppRadius.mdBorder,
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Text(clock.flag, style: AppTypography.display),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clock.city,
                          style: AppTypography.title.copyWith(
                            color: fg,
                          ),
                        ),
                        Text(
                          '${clock.country} • ${clock.formattedOffset}',
                          style: AppTypography.caption.copyWith(
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.md,
                      vertical: AppSpace.sm,
                    ),
                    decoration: BoxDecoration(
                      color: fg,
                      borderRadius: AppRadius.smBorder,
                    ),
                    child: Text(
                      _formatClockTime(clock.currentTime),
                      style: AppTypography.subtitle.copyWith(
                        fontFamily: 'monospace',
                        color: bg,
                      ),
                    ),
                  ),
                  if (idx > 0) ...[
                    const SizedBox(width: AppSpace.xs),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: fg,
                      ),
                      onPressed: () => clockService.removeClock(idx),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: AppSpace.xl),
          Text(
            'Countdown Timer',
            style: AppTypography.title.copyWith(color: fg),
          ),
          const SizedBox(height: 4),
          Text(
            'Minimal excursion & transit timer',
            style: AppTypography.caption.copyWith(color: muted),
          ),
          const SizedBox(height: AppSpace.md),
          Container(
            padding: const EdgeInsets.all(AppSpace.xl),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppRadius.lgBorder,
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                Text(
                  _formatDuration(clockService.timerRemaining),
                  style: AppTypography.display.copyWith(
                    fontFamily: 'monospace',
                    color: fg,
                  ),
                ),
                const SizedBox(height: AppSpace.lg),
                Wrap(
                  spacing: AppSpace.sm,
                  runSpacing: AppSpace.sm,
                  alignment: WrapAlignment.center,
                  children: [
                    _MinimalBlackButton(
                      label: clockService.timerRunning ? 'Pause' : 'Start',
                      icon: clockService.timerRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      onPressed: clockService.timerRunning
                          ? clockService.pauseTimer
                          : clockService.startTimer,
                    ),
                    _MinimalBlackButton(
                      label: 'Reset',
                      icon: Icons.refresh_rounded,
                      outlined: true,
                      onPressed: clockService.resetTimer,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.md),
                Wrap(
                  spacing: AppSpace.sm,
                  runSpacing: AppSpace.sm,
                  alignment: WrapAlignment.center,
                  children: [5, 15, 30, 60].map((mins) {
                    final isCurrent =
                        clockService.timerDuration.inMinutes == mins;
                    return _MinimalBlackButton(
                      label: '$mins min',
                      outlined: !isCurrent,
                      onPressed: () => clockService.setTimerDuration(
                        Duration(minutes: mins),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 4. COMMUNITY FEED SCREEN (FULL-SCREEN INSTAGRAM CITIZEN FEED)
// ============================================================================
class CommunityFeedScreen extends StatelessWidget {
  const CommunityFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Locals by AI • Citizen Social Feed'),
      ),
      body: ListView(
        padding: AppSpace.pagePadding,
        children: const [
          InstagramFeedSection(),
        ],
      ),
    );
  }
}

// ============================================================================
// 5. REALTIME CITIZEN & GUIDE CHAT SCREEN (ULTRA-MINIMAL WHITE / BLACK)
// ============================================================================
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _selectedThread = 0;
  final TextEditingController _msgCtrl = TextEditingController();

  final List<Map<String, dynamic>> _threads = [
    {
      'name': 'Municipal Dispatch',
      'role': 'Nintavur Smart City Desk',
      'messages': <Map<String, dynamic>>[
        {
          'sender': 'Dispatch Desk',
          'text':
              'Welcome to Smart City Live Chat. How can our team assist you today?',
          'isMe': false,
        },
      ],
    },
    {
      'name': 'Nimal Perera',
      'role': 'Cultural Triangle Guide',
      'messages': <Map<String, dynamic>>[
        {
          'sender': 'Nimal Perera',
          'text':
              'Ayubowan! I recommend starting the Sigiriya climb at 6:15 AM tomorrow.',
          'isMe': false,
        },
      ],
    },
    {
      'name': 'Sara Fernando',
      'role': 'Yala Wildlife Tracker',
      'messages': <Map<String, dynamic>>[
        {
          'sender': 'Sara Fernando',
          'text':
              'Block 1 at Yala had two leopard sightings near the waterhole this morning!',
          'isMe': false,
        },
      ],
    },
  ];

  void _sendMessage() {
    final txt = _msgCtrl.text.trim();
    if (txt.isEmpty) return;
    final thread = _threads[_selectedThread];
    final msgs = thread['messages'] as List<Map<String, dynamic>>;
    setState(() {
      msgs.add({'sender': 'You', 'text': txt, 'isMe': true});
      _msgCtrl.clear();
      msgs.add({
        'sender': thread['name'],
        'text':
            'Received: "$txt" — Our team has logged your message and is responding shortly.',
        'isMe': false,
      });
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeThread = _threads[_selectedThread];
    final messages = activeThread['messages'] as List<Map<String, dynamic>>;
    final isDark = context.watch<ThemeService>().isDarkMode;
    final bg = isDark ? Colors.black : Colors.white;
    final fg = isDark ? Colors.white : Colors.black;
    final muted = isDark ? Colors.white70 : Colors.black54;
    final border = isDark ? Colors.white24 : Colors.black12;

    return _MinimalMonochromeScaffold(
      title: 'Realtime Chat',
      body: Padding(
        padding: AppSpace.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _MinimalPremiumStrip(
              title: '24/7 Priority Concierge & Verified Guide Chat',
              subtitle: 'Instant municipal engineer & local guide line',
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_threads.length, (idx) {
                  final t = _threads[idx];
                  final selected = _selectedThread == idx;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpace.sm),
                    child: _MinimalBlackButton(
                      label: t['name'] as String,
                      outlined: !selected,
                      onPressed: () => setState(() => _selectedThread = idx),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppSpace.md),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(AppSpace.lg),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: AppRadius.lgBorder,
                  border: Border.all(color: border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: fg,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (activeThread['name'] as String)[0],
                              style: AppTypography.bodyStrong.copyWith(
                                color: bg,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeThread['name'] as String,
                                style: AppTypography.subtitle.copyWith(
                                  color: fg,
                                ),
                              ),
                              Text(
                                activeThread['role'] as String,
                                style: AppTypography.caption.copyWith(
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpace.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: fg,
                            borderRadius: AppRadius.smBorder,
                          ),
                          child: Text(
                            'ONLINE',
                            style: AppTypography.caption.copyWith(
                              color: bg,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.md),
                    Container(height: 1, color: border),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpace.md,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, idx) {
                          final m = messages[idx];
                          final isMe = m['isMe'] as bool;
                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(
                                bottom: AppSpace.sm,
                              ),
                              padding: const EdgeInsets.all(AppSpace.md),
                              constraints: const BoxConstraints(maxWidth: 420),
                              decoration: BoxDecoration(
                                color: isMe ? fg : bg,
                                borderRadius: AppRadius.mdBorder,
                                border: Border.all(color: fg),
                              ),
                              child: Text(
                                m['text'] as String,
                                style: AppTypography.body.copyWith(
                                  color: isMe ? bg : fg,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _msgCtrl,
                            onSubmitted: (_) => _sendMessage(),
                            style: AppTypography.body.copyWith(
                              color: fg,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Write a message...',
                              hintStyle: AppTypography.body.copyWith(
                                color: muted,
                              ),
                              filled: true,
                              fillColor: bg,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpace.md,
                                vertical: AppSpace.md,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.mdBorder,
                                borderSide: BorderSide(color: border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppRadius.mdBorder,
                                borderSide: BorderSide(color: border),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpace.sm),
                        _MinimalBlackButton(
                          label: 'Send',
                          icon: Icons.send_rounded,
                          onPressed: _sendMessage,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 6. SAVED TRIPS, PLACES & HOTELS SCREEN
// ============================================================================
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tripHistory = context.watch<TripHistoryService>();

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Saved Trips, Places & Stays'),
      ),
      body: ListView(
        padding: AppSpace.pagePadding,
        children: [
          SectionHeader(
            title: 'Saved Trips (${tripHistory.trips.length})',
            subtitle: 'Recent routes and planned journeys across Sri Lanka',
            actionLabel: 'Open Planner',
            onAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ItineraryScreen()),
              );
            },
          ),
          const SizedBox(height: AppSpace.md),
          ...tripHistory.trips.map(
            (trip) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.md),
              child: AppCard(
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.smBorder,
                      child: Image.asset(
                        trip.mapPreviewUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          width: 72,
                          height: 72,
                          color: AppColors.surfaceMuted(context),
                          child: const Icon(Icons.route_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${trip.fromLocation} → ${trip.toLocation}',
                            style: AppTypography.subtitle.copyWith(
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          Text(
                            '${trip.vehicle} • ${trip.distanceKm.toStringAsFixed(1)} km • ${trip.timeTaken.inHours}h ${trip.timeTaken.inMinutes.remainder(60)}m',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const StatusChip(
                      label: 'Saved',
                      kind: StatusChipKind.resolved,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          const SectionHeader(
            title: 'Bookmarked Stays & Heritage Sites',
            subtitle: 'Quick access to top-rated Sri Lankan properties',
          ),
          const SizedBox(height: AppSpace.md),
          ...allHotels.take(4).map(
            (hotel) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.md),
              child: AppCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HotelDetailScreen(hotel: hotel),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.hotel_rounded,
                      color: AppColors.primary(context),
                    ),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hotel.name,
                            style: AppTypography.subtitle.copyWith(
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          Text(
                            '${hotel.city} • ★ ${hotel.rating}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      hotel.priceRange,
                      style: AppTypography.bodyStrong.copyWith(
                        color: AppColors.primary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 7. TRIP JOURNAL & FIELD NOTES SCREEN
// ============================================================================
class TripJournalScreen extends StatefulWidget {
  const TripJournalScreen({super.key});

  @override
  State<TripJournalScreen> createState() => _TripJournalScreenState();
}

class _TripJournalScreenState extends State<TripJournalScreen> {
  void _addNewEntry(BuildContext context, TripHistoryService service) {
    final fromCtrl = TextEditingController(text: 'Nintavur');
    final toCtrl = TextEditingController(text: 'Arugam Bay');
    final noteCtrl = TextEditingController(text: 'Scenic coastal drive');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log New Trip Journal Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(controller: fromCtrl, label: 'Origin'),
            const SizedBox(height: AppSpace.md),
            AppTextField(controller: toCtrl, label: 'Destination'),
            const SizedBox(height: AppSpace.md),
            AppTextField(controller: noteCtrl, label: 'Journal Title / Notes'),
          ],
        ),
        actions: [
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.pop(ctx),
          ),
          AppButton(
            label: 'Save Entry',
            onPressed: () {
              service.addTrip(
                TripHistoryItem(
                  id: const Uuid().v4(),
                  fromLocation: fromCtrl.text.trim(),
                  toLocation: toCtrl.text.trim(),
                  vehicle: 'Car',
                  distanceKm: 64.0,
                  timeTaken: const Duration(hours: 1, minutes: 25),
                  date: DateTime.now(),
                  mapPreviewUrl: 'assets/eastern province/arugam bay.jpg',
                  tripName: noteCtrl.text.trim(),
                ),
              );
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripService = context.watch<TripHistoryService>();

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Trip Journal & Travel Memories'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNewEntry(context, tripService),
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_note_rounded),
        label: const Text('New Journal Entry'),
      ),
      body: ListView(
        padding: AppSpace.pagePadding,
        children: [
          const SectionHeader(
            title: 'My Sri Lanka Travel & Field Journal',
            subtitle: 'Documented routes, distances, and travel milestones',
          ),
          const SizedBox(height: AppSpace.md),
          ...tripService.trips.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.md),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.mdBorder,
                      child: Image.asset(
                        item.mapPreviewUrl,
                        height: 170,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          height: 170,
                          color: AppColors.surfaceMuted(context),
                          child: const Center(
                            child: Icon(Icons.photo_album_outlined, size: 40),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpace.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.fromLocation} → ${item.toLocation}',
                          style: AppTypography.title.copyWith(
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        StatusChip(
                          label: '★ ${item.rating.toStringAsFixed(1)}',
                          kind: StatusChipKind.resolved,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.tripName} • ${item.vehicle} • ${item.distanceKm.toStringAsFixed(1)} km',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 8. CERTIFIED LOCAL TOUR GUIDES SCREEN
// ============================================================================
class GuidesScreen extends StatelessWidget {
  const GuidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyService>();

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Certified Local Tour Guides'),
      ),
      body: ListView(
        padding: AppSpace.pagePadding,
        children: [
          const SectionHeader(
            title: 'Verified Sri Lanka Regional Specialists',
            subtitle:
                'Multilingual cultural, wildlife, surfing, and trekking guides',
          ),
          const SizedBox(height: AppSpace.md),
          ...mockGuides.map((Guide g) {
            final convertedRate = currency
                .convertFromUsd(g.dailyRate)
                .toStringAsFixed(currency.currentCurrency == 'LKR' ? 0 : 2);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.md),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: AppRadius.mdBorder,
                          child: Image.asset(
                            g.imageAsset,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 72,
                              height: 72,
                              color: AppColors.surfaceMuted(context),
                              child: const Icon(Icons.person_outline),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      g.name,
                                      style: AppTypography.title.copyWith(
                                        color: AppColors.textPrimary(context),
                                      ),
                                    ),
                                  ),
                                  const StatusChip(
                                    label: 'Verified',
                                    kind: StatusChipKind.resolved,
                                    icon: Icons.verified_rounded,
                                  ),
                                ],
                              ),
                              Text(
                                '${g.expertise} • ${g.location} • ${g.yearsOfExperience} yrs exp',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary(context),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Languages: ${g.languages}',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.sm),
                    Text(
                      g.bio,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: AppSpace.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${currency.currentCurrencySymbol}$convertedRate / day • ★ ${g.rating} (${g.reviewCount} reviews)',
                          style: AppTypography.bodyStrong.copyWith(
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        AppButton(
                          label: 'Book Guide',
                          icon: Icons.event_available_rounded,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Booking request sent to ${g.name} (${g.location}).',
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================================
// 9. NOTIFICATIONS & SYSTEM INBOX SCREEN (CLEAN MINIMAL BLACK & WHITE)
// ============================================================================
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeService>().isDarkMode;
    final bg = isDark ? Colors.black : Colors.white;
    final fg = isDark ? Colors.white : Colors.black;
    final muted = isDark ? Colors.white70 : Colors.black54;
    final border = isDark ? Colors.white24 : Colors.black12;

    final notifService = context.watch<NotificationService>();
    final items = notifService.notifications;

    return _MinimalMonochromeScaffold(
      title: 'Notifications',
      actions: [
        if (items.isNotEmpty) ...[
          Center(
            child: _MinimalBlackButton(
              label: 'Mark all read',
              outlined: true,
              onPressed: notifService.markAllRead,
            ),
          ),
          const SizedBox(width: AppSpace.xs),
          Center(
            child: _MinimalBlackButton(
              label: 'Clear',
              onPressed: notifService.clearAll,
            ),
          ),
          const SizedBox(width: AppSpace.xs),
        ],
      ],
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: AppSpace.pagePadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: bg,
                        shape: BoxShape.circle,
                        border: Border.all(color: fg),
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 30,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: AppSpace.lg),
                    Text(
                      'No notifications yet',
                      style: AppTypography.title.copyWith(color: fg),
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      'Your civic alerts, work order updates, and travel reminders will appear here.',
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(color: muted),
                    ),
                    const SizedBox(height: AppSpace.lg),
                    _MinimalBlackButton(
                      label: 'Generate Sample Notification',
                      icon: Icons.add_alert_rounded,
                      onPressed: () {
                        notifService.add(
                          title: 'Nintavur Smart City Telemetry Active',
                          body:
                              'Route 22 Smart Bus arriving at Addappalam Junction in 4 minutes.',
                          type: NotificationType.info,
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: AppSpace.pagePadding,
              itemCount: items.length + 1,
              itemBuilder: (context, idx) {
                if (idx == 0) {
                  return const _MinimalPremiumStrip(
                    title: 'Priority Civic Alert Stream',
                    subtitle:
                        'Instant push alerts for emergency dispatches & Smart Bus ETA.',
                  );
                }
                final n = items[idx - 1];
                return InkWell(
                  onTap: () => notifService.markRead(n.id),
                  borderRadius: AppRadius.mdBorder,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppSpace.md),
                    padding: const EdgeInsets.all(AppSpace.lg),
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: AppRadius.mdBorder,
                      border: Border.all(
                        color: n.isRead ? border : fg,
                        width: n.isRead ? 1 : 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: n.isRead ? bg : fg,
                            borderRadius: AppRadius.smBorder,
                            border: Border.all(color: fg),
                          ),
                          child: Icon(
                            n.type == NotificationType.alert
                                ? Icons.warning_amber_rounded
                                : Icons.notifications_outlined,
                            size: 20,
                            color: n.isRead ? fg : bg,
                          ),
                        ),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                style: AppTypography.subtitle.copyWith(
                                  color: fg,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                n.body,
                                style: AppTypography.body.copyWith(
                                  color: muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!n.isRead)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.sm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: fg,
                              borderRadius: AppRadius.smBorder,
                            ),
                            child: Text(
                              'NEW',
                              style: AppTypography.caption.copyWith(
                                color: bg,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
