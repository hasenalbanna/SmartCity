import 'package:flutter/material.dart';

enum NotificationType { planReminder, info, alert }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime time;
  bool isRead;
  final NotificationType type;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
    required this.type,
  });
}

class NotificationService extends ChangeNotifier {
  final List<AppNotification> _list = [];
  final Set<String> _seenKeys = {};
  final Set<String> _dedupeKeys = {};

  List<AppNotification> get notifications => _list.reversed.toList();
  int get unreadCount => _list.where((n) => !n.isRead).length;

  void add({
    required String title,
    required String body,
    NotificationType type = NotificationType.info,
  }) {
    _list.add(
      AppNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        time: DateTime.now(),
        type: type,
      ),
    );
    notifyListeners();
  }

  void addUnique({
    required String dedupeKey,
    required String title,
    required String body,
    NotificationType type = NotificationType.info,
  }) {
    if (_dedupeKeys.contains(dedupeKey)) return;
    _dedupeKeys.add(dedupeKey);
    add(title: title, body: body, type: type);
  }

  /// Called once per plan-day combination. Safe to call on every build.
  void checkPlanReminder({
    required String packageId,
    required String packageTitle,
    required int dayIndex,
    required String activity,
  }) {
    final key = '${packageId}_$dayIndex';
    if (_seenKeys.contains(key)) return;
    _seenKeys.add(key);
    add(
      title: '📅 Day ${dayIndex + 1} — $packageTitle',
      body: 'Today\'s activity: $activity',
      type: NotificationType.planReminder,
    );
  }

  void markRead(String id) {
    final idx = _list.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    _list[idx].isRead = true;
    notifyListeners();
  }

  void markAllRead() {
    for (final n in _list) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void clearAll() {
    _list.clear();
    _dedupeKeys.clear();
    notifyListeners();
  }
}
