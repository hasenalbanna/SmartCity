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
import '../services/trip_history_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/instagram_feed_section.dart';
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
// 2. TRAVEL & CIVIC SCHEDULE CALENDAR SCREEN
// ============================================================================
class ScheduleCalendarScreen extends StatefulWidget {
  const ScheduleCalendarScreen({super.key});

  @override
  State<ScheduleCalendarScreen> createState() => _ScheduleCalendarScreenState();
}

class _ScheduleCalendarScreenState extends State<ScheduleCalendarScreen> {
  int _selectedDayOffset = 0;
  final List<Map<String, String>> _events = [
    {
      'time': '06:30 AM',
      'title': 'Sigiriya Lion Rock Sunrise Ascent',
      'location': 'Central Province • UNESCO Heritage',
      'type': 'Travel Itinerary',
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
      'type': 'Travel Itinerary',
    },
  ];

  void _addScheduleItem() {
    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController(text: '09:00 AM');
    final locCtrl = TextEditingController(text: 'Colombo / Nintavur');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Calendar Schedule'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: titleCtrl,
              label: 'Event or Activity Title',
              hint: 'e.g. Yala Safari Morning Drive',
              isRequired: true,
            ),
            const SizedBox(height: AppSpace.md),
            AppTextField(
              controller: timeCtrl,
              label: 'Time',
              hint: '09:00 AM',
            ),
            const SizedBox(height: AppSpace.md),
            AppTextField(
              controller: locCtrl,
              label: 'Location',
              hint: 'Destination or Ward',
            ),
          ],
        ),
        actions: [
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.pop(ctx),
          ),
          AppButton(
            label: 'Save Event',
            onPressed: () {
              if (titleCtrl.text.trim().isNotEmpty) {
                setState(() {
                  _events.add({
                    'time': timeCtrl.text.trim(),
                    'title': titleCtrl.text.trim(),
                    'location': locCtrl.text.trim(),
                    'type': 'Custom Plan',
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
    final now = DateTime.now();

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Travel & Civic Schedule Calendar'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addScheduleItem,
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Event'),
      ),
      body: ListView(
        padding: AppSpace.pagePadding,
        children: [
          const SectionHeader(
            title: 'Upcoming 7-Day Schedule',
            subtitle: 'Synchronized travel itineraries and municipal events',
          ),
          const SizedBox(height: AppSpace.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (idx) {
                final date = now.add(Duration(days: idx));
                final selected = _selectedDayOffset == idx;
                const weekdays = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun',
                ];
                final dayLabel = weekdays[date.weekday - 1];

                return Padding(
                  padding: const EdgeInsets.only(right: AppSpace.sm),
                  child: InkWell(
                    onTap: () => setState(() => _selectedDayOffset = idx),
                    borderRadius: AppRadius.mdBorder,
                    child: Container(
                      width: 68,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpace.md,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary(context)
                            : AppColors.surface(context),
                        borderRadius: AppRadius.mdBorder,
                        border: Border.all(
                          color: selected
                              ? AppColors.primary(context)
                              : AppColors.outline(context),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            dayLabel,
                            style: AppTypography.caption.copyWith(
                              color: selected
                                  ? Colors.white
                                  : AppColors.textSecondary(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: AppTypography.title.copyWith(
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: AppSpace.xl),
          ..._events.map(
            (ev) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.md),
              child: AppCard(
                accentBorderColor: AppColors.primary(context),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.md,
                        vertical: AppSpace.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary(
                          context,
                        ).withValues(alpha: 0.12),
                        borderRadius: AppRadius.smBorder,
                      ),
                      child: Text(
                        ev['time']!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary(context),
                          fontWeight: FontWeight.w800,
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
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ev['location']!,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusChip(
                      label: ev['type']!,
                      kind: StatusChipKind.info,
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
// 3. WORLD CLOCK & TRAVEL TIMER SCREEN
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

    return AppScaffold(
      appBar: AppBar(
        title: const Text('World Clock & Travel Timer'),
      ),
      body: ListView(
        padding: AppSpace.pagePadding,
        children: [
          SectionHeader(
            title: 'Global Time Zones',
            subtitle: 'Compare Sri Lanka (UTC+05:30) with international hubs',
            actionLabel: '+ Add City',
            onAction: () {
              showModalBottomSheet(
                context: context,
                builder: (ctx) => ListView(
                  padding: AppSpace.pagePadding,
                  children: ClockEntry.availableZones.map((zone) {
                    return ListTile(
                      leading: Text(zone.flag, style: AppTypography.title),
                      title: Text('${zone.city}, ${zone.country}'),
                      subtitle: Text(zone.formattedOffset),
                      onTap: () {
                        clockService.addClock(zone);
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpace.md),
          ...clockService.clocks.asMap().entries.map((entry) {
            final idx = entry.key;
            final clock = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.md),
              child: AppCard(
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
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          Text(
                            '${clock.country} • ${clock.formattedOffset}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatClockTime(clock.currentTime),
                      style: AppTypography.title.copyWith(
                        fontFamily: 'monospace',
                        color: AppColors.primary(context),
                      ),
                    ),
                    if (idx > 0)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => clockService.removeClock(idx),
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpace.xl),
          const SectionHeader(
            title: 'Transit & Excursion Countdown Timer',
            subtitle: 'Track parking, bus transfers, or safari excursion time',
          ),
          const SizedBox(height: AppSpace.md),
          AppCard(
            child: Column(
              children: [
                Text(
                  _formatDuration(clockService.timerRemaining),
                  style: AppTypography.display.copyWith(
                    fontFamily: 'monospace',
                    color: AppColors.primary(context),
                  ),
                ),
                const SizedBox(height: AppSpace.md),
                Wrap(
                  spacing: AppSpace.sm,
                  runSpacing: AppSpace.sm,
                  alignment: WrapAlignment.center,
                  children: [
                    AppButton(
                      label: clockService.timerRunning ? 'Pause' : 'Start',
                      icon: clockService.timerRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      onPressed: clockService.timerRunning
                          ? clockService.pauseTimer
                          : clockService.startTimer,
                    ),
                    AppButton(
                      label: 'Reset',
                      icon: Icons.refresh_rounded,
                      variant: AppButtonVariant.secondary,
                      onPressed: clockService.resetTimer,
                    ),
                    ...[5, 15, 30, 60].map(
                      (mins) => ActionChip(
                        label: Text('$mins min'),
                        onPressed: () => clockService.setTimerDuration(
                          Duration(minutes: mins),
                        ),
                      ),
                    ),
                  ],
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
// 5. REALTIME CITIZEN & GUIDE CHAT SCREEN
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
      'name': 'Nintavur Municipal Dispatch Desk',
      'role': 'Civic Engineering & Flood Ops',
      'online': true,
      'messages': <Map<String, dynamic>>[
        {
          'sender': 'Dispatch Desk',
          'text':
              'Welcome to Nintavur Smart City Live Chat. How can our engineering crew assist you today?',
          'isMe': false,
        },
      ],
    },
    {
      'name': 'Nimal Perera (Verified Guide)',
      'role': 'Cultural Triangle & Sigiriya Specialist',
      'online': true,
      'messages': <Map<String, dynamic>>[
        {
          'sender': 'Nimal Perera',
          'text':
              'Ayubowan! I recommend starting the Sigiriya climb at 6:15 AM tomorrow to beat the heat.',
          'isMe': false,
        },
      ],
    },
    {
      'name': 'Sara Fernando (Wildlife Safari)',
      'role': 'Yala & Wilpattu Leopard Tracker',
      'online': true,
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

    return AppScaffold(
      appBar: AppBar(
        title: const Text('Realtime Citizen & Guide Chat'),
      ),
      body: Padding(
        padding: AppSpace.pagePadding,
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_threads.length, (idx) {
                  final t = _threads[idx];
                  final selected = _selectedThread == idx;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpace.sm),
                    child: ChoiceChip(
                      label: Text(t['name'] as String),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedThread = idx),
                      selectedColor: AppColors.primary(context),
                      labelStyle: AppTypography.caption.copyWith(
                        color: selected
                            ? Colors.white
                            : AppColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppSpace.md),
            Expanded(
              child: AppCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary(context),
                          child: Text(
                            (activeThread['name'] as String)[0],
                            style: AppTypography.bodyStrong.copyWith(
                              color: Colors.white,
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
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                              Text(
                                activeThread['role'] as String,
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const StatusChip(
                          label: 'ONLINE',
                          kind: StatusChipKind.resolved,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.md),
                    Divider(height: 1, color: AppColors.outline(context)),
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
                                color: isMe
                                    ? AppColors.primary(context)
                                    : AppColors.surfaceMuted(context),
                                borderRadius: AppRadius.mdBorder,
                              ),
                              child: Text(
                                m['text'] as String,
                                style: AppTypography.body.copyWith(
                                  color: isMe
                                      ? Colors.white
                                      : AppColors.textPrimary(context),
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
                            decoration: const InputDecoration(
                              hintText: 'Write a message...',
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpace.sm),
                        AppButton(
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
// 9. NOTIFICATIONS & SYSTEM INBOX SCREEN
// ============================================================================
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifService = context.watch<NotificationService>();
    final items = notifService.notifications;

    return AppScaffold(
      appBar: AppBar(
        title: const Text('System Notifications & Inbox'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: notifService.markAllRead,
              child: const Text('Mark all read'),
            ),
          const SizedBox(width: AppSpace.sm),
        ],
      ),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'All Caught Up',
              subtitle:
                  'Your civic alerts, work order updates, and travel reminders will appear here.',
              actionLabel: 'Generate Test Alert',
              onAction: () {
                notifService.add(
                  title: 'Nintavur Smart City Telemetry Active',
                  body:
                      'Route 22 Smart Bus arriving at Addappalam Junction in 4 minutes.',
                  type: NotificationType.info,
                );
              },
            )
          : ListView.builder(
              padding: AppSpace.pagePadding,
              itemCount: items.length,
              itemBuilder: (context, idx) {
                final n = items[idx];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.md),
                  child: AppCard(
                    onTap: () => notifService.markRead(n.id),
                    accentBorderColor: n.isRead
                        ? null
                        : AppColors.primary(context),
                    child: Row(
                      children: [
                        Icon(
                          n.type == NotificationType.alert
                              ? Icons.warning_amber_rounded
                              : Icons.notifications_active_outlined,
                          color: n.type == NotificationType.alert
                              ? AppColors.danger(context)
                              : AppColors.primary(context),
                        ),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.title,
                                style: AppTypography.subtitle.copyWith(
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                n.body,
                                style: AppTypography.body.copyWith(
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!n.isRead)
                          const StatusChip(
                            label: 'NEW',
                            kind: StatusChipKind.info,
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
