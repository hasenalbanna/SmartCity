import 'dart:async';
import 'package:flutter/material.dart';
import '../models/travel_package.dart';

class ClockEntry {
  final String city;
  final String country;
  final String flag;
  final double utcOffsetHours;

  const ClockEntry({
    required this.city,
    required this.country,
    required this.flag,
    required this.utcOffsetHours,
  });

  DateTime get currentTime {
    final totalMin = (utcOffsetHours * 60).round();
    return DateTime.now().toUtc().add(Duration(minutes: totalMin));
  }

  String get formattedOffset {
    final totalMin = (utcOffsetHours * 60).round();
    final sign = totalMin >= 0 ? '+' : '-';
    final abs = totalMin.abs();
    final h = abs ~/ 60;
    final m = abs % 60;
    return 'UTC$sign${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  static const List<ClockEntry> availableZones = [
    ClockEntry(
      city: 'London',
      country: 'United Kingdom',
      flag: '🇬🇧',
      utcOffsetHours: 0,
    ),
    ClockEntry(
      city: 'New York',
      country: 'USA (East)',
      flag: '🇺🇸',
      utcOffsetHours: -5,
    ),
    ClockEntry(
      city: 'Los Angeles',
      country: 'USA (West)',
      flag: '🇺🇸',
      utcOffsetHours: -8,
    ),
    ClockEntry(
      city: 'Chicago',
      country: 'USA (Central)',
      flag: '🇺🇸',
      utcOffsetHours: -6,
    ),
    ClockEntry(
      city: 'Toronto',
      country: 'Canada',
      flag: '🇨🇦',
      utcOffsetHours: -5,
    ),
    ClockEntry(
      city: 'Mexico City',
      country: 'Mexico',
      flag: '🇲🇽',
      utcOffsetHours: -6,
    ),
    ClockEntry(
      city: 'São Paulo',
      country: 'Brazil',
      flag: '🇧🇷',
      utcOffsetHours: -3,
    ),
    ClockEntry(
      city: 'Paris',
      country: 'France',
      flag: '🇫🇷',
      utcOffsetHours: 1,
    ),
    ClockEntry(
      city: 'Berlin',
      country: 'Germany',
      flag: '🇩🇪',
      utcOffsetHours: 1,
    ),
    ClockEntry(city: 'Rome', country: 'Italy', flag: '🇮🇹', utcOffsetHours: 1),
    ClockEntry(
      city: 'Moscow',
      country: 'Russia',
      flag: '🇷🇺',
      utcOffsetHours: 3,
    ),
    ClockEntry(city: 'Dubai', country: 'UAE', flag: '🇦🇪', utcOffsetHours: 4),
    ClockEntry(
      city: 'Karachi',
      country: 'Pakistan',
      flag: '🇵🇰',
      utcOffsetHours: 5,
    ),
    ClockEntry(
      city: 'Mumbai',
      country: 'India',
      flag: '🇮🇳',
      utcOffsetHours: 5.5,
    ),
    ClockEntry(
      city: 'Kathmandu',
      country: 'Nepal',
      flag: '🇳🇵',
      utcOffsetHours: 5.75,
    ),
    ClockEntry(
      city: 'Dhaka',
      country: 'Bangladesh',
      flag: '🇧🇩',
      utcOffsetHours: 6,
    ),
    ClockEntry(
      city: 'Yangon',
      country: 'Myanmar',
      flag: '🇲🇲',
      utcOffsetHours: 6.5,
    ),
    ClockEntry(
      city: 'Bangkok',
      country: 'Thailand',
      flag: '🇹🇭',
      utcOffsetHours: 7,
    ),
    ClockEntry(
      city: 'Jakarta',
      country: 'Indonesia',
      flag: '🇮🇩',
      utcOffsetHours: 7,
    ),
    ClockEntry(
      city: 'Beijing',
      country: 'China',
      flag: '🇨🇳',
      utcOffsetHours: 8,
    ),
    ClockEntry(
      city: 'Singapore',
      country: 'Singapore',
      flag: '🇸🇬',
      utcOffsetHours: 8,
    ),
    ClockEntry(
      city: 'Kuala Lumpur',
      country: 'Malaysia',
      flag: '🇲🇾',
      utcOffsetHours: 8,
    ),
    ClockEntry(
      city: 'Seoul',
      country: 'South Korea',
      flag: '🇰🇷',
      utcOffsetHours: 9,
    ),
    ClockEntry(
      city: 'Tokyo',
      country: 'Japan',
      flag: '🇯🇵',
      utcOffsetHours: 9,
    ),
    ClockEntry(
      city: 'Sydney',
      country: 'Australia',
      flag: '🇦🇺',
      utcOffsetHours: 10,
    ),
    ClockEntry(
      city: 'Auckland',
      country: 'New Zealand',
      flag: '🇳🇿',
      utcOffsetHours: 12,
    ),
    ClockEntry(
      city: 'Cairo',
      country: 'Egypt',
      flag: '🇪🇬',
      utcOffsetHours: 2,
    ),
    ClockEntry(
      city: 'Istanbul',
      country: 'Turkey',
      flag: '🇹🇷',
      utcOffsetHours: 3,
    ),
    ClockEntry(
      city: 'Riyadh',
      country: 'Saudi Arabia',
      flag: '🇸🇦',
      utcOffsetHours: 3,
    ),
    ClockEntry(
      city: 'Johannesburg',
      country: 'South Africa',
      flag: '🇿🇦',
      utcOffsetHours: 2,
    ),
    ClockEntry(
      city: 'Nairobi',
      country: 'Kenya',
      flag: '🇰🇪',
      utcOffsetHours: 3,
    ),
  ];
}

class ClockService extends ChangeNotifier {
  Timer? _masterTick;

  // Current time notifier (fires every second)
  DateTime get tick => DateTime.now();

  // ------ World Clocks ------
  final List<ClockEntry> _clocks = [
    const ClockEntry(
      city: 'Colombo',
      country: 'Sri Lanka',
      flag: '🇱🇰',
      utcOffsetHours: 5.5,
    ),
    const ClockEntry(
      city: 'London',
      country: 'United Kingdom',
      flag: '🇬🇧',
      utcOffsetHours: 0,
    ),
  ];
  List<ClockEntry> get clocks => List.unmodifiable(_clocks);

  // ------ Countdown Timer ------
  Duration _timerDuration = const Duration(minutes: 5);
  Duration _timerRemaining = const Duration(minutes: 5);
  bool _timerRunning = false;
  bool _timerFinished = false;
  DateTime? _lastTimerCompletedAt;

  Duration get timerDuration => _timerDuration;
  Duration get timerRemaining => _timerRemaining;
  bool get timerRunning => _timerRunning;
  bool get timerFinished => _timerFinished;
  DateTime? get lastTimerCompletedAt => _lastTimerCompletedAt;

  // ------ Plan Reminder ------
  TravelPackage? _activePlan;
  DateTime? _planStartDate;

  TravelPackage? get activePlan => _activePlan;
  DateTime? get planStartDate => _planStartDate;

  int get currentPlanDay {
    if (_activePlan == null || _planStartDate == null) return -1;
    final now = DateTime.now();
    final start = DateTime(
      _planStartDate!.year,
      _planStartDate!.month,
      _planStartDate!.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    return today.difference(start).inDays;
  }

  String? get todaysPlanActivity {
    if (_activePlan == null) return null;
    final day = currentPlanDay;
    if (day < 0 || day >= _activePlan!.itinerary.length) return null;
    return _activePlan!.itinerary[day];
  }

  ClockService() {
    _masterTick = Timer.periodic(const Duration(seconds: 1), (_) {
      // Tick the countdown timer if running
      if (_timerRunning) {
        if (_timerRemaining.inSeconds <= 1) {
          _timerRemaining = Duration.zero;
          _timerRunning = false;
          _timerFinished = true;
          _lastTimerCompletedAt = DateTime.now();
        } else {
          _timerRemaining -= const Duration(seconds: 1);
        }
      }
      notifyListeners();
    });
  }

  // ---- Clock management ----
  void addClock(ClockEntry entry) {
    if (!_clocks.any((c) => c.city == entry.city)) {
      _clocks.add(entry);
      notifyListeners();
    }
  }

  void removeClock(int index) {
    if (index > 0 && index < _clocks.length) {
      _clocks.removeAt(index);
      notifyListeners();
    }
  }

  // ---- Timer controls ----
  void setTimerDuration(Duration d) {
    _timerDuration = d;
    _timerRemaining = d;
    _timerRunning = false;
    _timerFinished = false;
    notifyListeners();
  }

  void startTimer() {
    if (_timerRemaining.inSeconds <= 0) return;
    _timerRunning = true;
    _timerFinished = false;
    notifyListeners();
  }

  void pauseTimer() {
    _timerRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    _timerRunning = false;
    _timerFinished = false;
    _timerRemaining = _timerDuration;
    notifyListeners();
  }

  // ---- Plan reminder ----
  void setActivePlan(TravelPackage pkg, DateTime startDate) {
    _activePlan = pkg;
    _planStartDate = startDate;
    notifyListeners();
  }

  void clearActivePlan() {
    _activePlan = null;
    _planStartDate = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _masterTick?.cancel();
    super.dispose();
  }
}
