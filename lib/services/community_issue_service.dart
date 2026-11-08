import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/community_issue.dart';

class CommunityIssueService extends ChangeNotifier {
  static const String _storageKey = 'smartcity_community_issues_v1';
  final List<CommunityIssue> _issues = [];
  bool _initialized = false;

  List<CommunityIssue> get issues => List.unmodifiable(_issues);

  CommunityIssueService() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString(_storageKey);

      if (storedData != null && storedData.isNotEmpty) {
        final List decoded = jsonDecode(storedData);
        _issues.clear();
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            _issues.add(CommunityIssue.fromJson(item));
          }
        }
      } else {
        _seedInitialIssues();
        await _saveToStorage();
      }
    } catch (e) {
      debugPrint('Error loading community issues: $e');
      if (_issues.isEmpty) {
        _seedInitialIssues();
      }
    }
    _initialized = true;
    notifyListeners();
  }

  void _seedInitialIssues() {
    _issues.addAll([
      CommunityIssue(
        id: 'rep_1',
        category: 'ROAD/POTHOLE',
        categoryLocal: 'வீதி',
        title: 'the roads are not good',
        description: 'Deep potholes causing major traffic slowing and danger for motorcycle riders.',
        address: 'Nintavur, Ampara District, Eastern Province, 32340, Sri Lanka',
        location: const LatLng(7.3486, 81.8494),
        status: IssueStatus.pending,
        contactNumber: '+94 77 123 4567',
        createdAt: DateTime(2026, 4, 17),
      ),
      CommunityIssue(
        id: 'rep_2',
        category: 'ROAD/POTHOLE',
        categoryLocal: 'வீதி',
        title: 'the roads are not good',
        description: 'Road surface completely eroded after recent monsoon rains.',
        address: 'Addappalam, Ampara District, Eastern Province, 32340, Sri Lanka',
        location: const LatLng(7.3390, 81.8410),
        status: IssueStatus.pending,
        contactNumber: '+94 77 987 6543',
        createdAt: DateTime(2026, 4, 17),
      ),
      CommunityIssue(
        id: 'rep_3',
        category: 'GARBAGE DUMP',
        categoryLocal: 'குப்பை',
        title: 'Garbage dump accumulating near public ground',
        description: 'Waste has not been collected for three days, creating odors and health risks.',
        address: 'Hospital Road, Nintavur, Eastern Province, Sri Lanka',
        location: const LatLng(7.3450, 81.8540),
        status: IssueStatus.inProgress,
        contactNumber: '+94 71 222 3344',
        createdAt: DateTime(2026, 4, 16),
      ),
      CommunityIssue(
        id: 'rep_4',
        category: 'STREET LIGHTS',
        categoryLocal: 'வீதி விளக்கு',
        title: 'Multiple street lights broken on coastal road',
        description: 'Dark junction leading to safety concerns at night.',
        address: 'Beach Road, Nintavur, Eastern Province, Sri Lanka',
        location: const LatLng(7.3512, 81.8562),
        status: IssueStatus.resolved,
        contactNumber: '+94 76 555 4321',
        createdAt: DateTime(2026, 4, 14),
      ),
      CommunityIssue(
        id: 'rep_5',
        category: 'DRAINAGE/CANAL',
        categoryLocal: 'வடிகால்',
        title: 'Main stormwater canal blocked with debris',
        description: 'Water overflowing onto residential access lanes during downpours.',
        address: 'Pottuvil-Batticaloa Road, Nintavur, Sri Lanka',
        location: const LatLng(7.3420, 81.8450),
        status: IssueStatus.pending,
        contactNumber: '+94 77 333 8899',
        createdAt: DateTime(2026, 4, 13),
      ),
      CommunityIssue(
        id: 'rep_6',
        category: 'STREET LIGHTS',
        categoryLocal: 'வீதி விளக்கு',
        title: 'LED street lamp replacement completed',
        description: 'All 8 lamp posts on North Main Road repaired.',
        address: 'North Main Road, Nintavur, Sri Lanka',
        location: const LatLng(7.3550, 81.8510),
        status: IssueStatus.resolved,
        contactNumber: '+94 77 444 1122',
        createdAt: DateTime(2026, 4, 12),
      ),
      CommunityIssue(
        id: 'rep_7',
        category: 'ROAD/POTHOLE',
        categoryLocal: 'வீதி',
        title: 'Pothole patch work finished',
        description: 'Asphalt paving completed near market square.',
        address: 'Market Junction, Nintavur, Sri Lanka',
        location: const LatLng(7.3470, 81.8530),
        status: IssueStatus.resolved,
        contactNumber: '+94 71 888 9900',
        createdAt: DateTime(2026, 4, 11),
      ),
      CommunityIssue(
        id: 'rep_8',
        category: 'GARBAGE DUMP',
        categoryLocal: 'குப்பை',
        title: 'Overflowing roadside waste container',
        description: 'Needs urgent clearing before rain.',
        address: 'Beach Access Lane, Nintavur, Sri Lanka',
        location: const LatLng(7.3410, 81.8570),
        status: IssueStatus.pending,
        contactNumber: '+94 75 111 2233',
        createdAt: DateTime(2026, 4, 10),
      ),
      CommunityIssue(
        id: 'rep_9',
        category: 'COASTAL EROSION',
        categoryLocal: 'கடல் அரிப்பு',
        title: 'Wave barriers reinforced with stone boulders',
        description: 'Coastal embankment protected against erosion.',
        address: 'Sea View Road, Nintavur, Sri Lanka',
        location: const LatLng(7.3490, 81.8590),
        status: IssueStatus.resolved,
        contactNumber: '+94 78 999 0011',
        createdAt: DateTime(2026, 4, 9),
      ),
    ]);
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_issues.map((i) => i.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving community issues: $e');
    }
  }

  Future<void> addIssue({
    required String category,
    required String categoryLocal,
    required String title,
    required String description,
    required String address,
    required LatLng location,
    required String contactNumber,
    String? imagePath,
    bool hasAudio = false,
  }) async {
    final newIssue = CommunityIssue(
      id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      categoryLocal: categoryLocal,
      title: title.trim().isEmpty ? '$category reported' : title.trim(),
      description: description.trim(),
      address: address.trim(),
      location: location,
      status: IssueStatus.pending,
      contactNumber: contactNumber.trim(),
      imagePath: imagePath,
      hasAudio: hasAudio,
      createdAt: DateTime.now(),
    );

    _issues.insert(0, newIssue);
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> updateStatus(String id, IssueStatus newStatus) async {
    final index = _issues.indexWhere((i) => i.id == id);
    if (index != -1) {
      _issues[index] = _issues[index].copyWith(status: newStatus);
      notifyListeners();
      await _saveToStorage();
    }
  }

  List<CommunityIssue> get pendingIssues =>
      _issues.where((i) => i.status == IssueStatus.pending).toList();

  List<CommunityIssue> get inProgressIssues =>
      _issues.where((i) => i.status == IssueStatus.inProgress).toList();

  List<CommunityIssue> get resolvedIssues =>
      _issues.where((i) => i.status == IssueStatus.resolved).toList();
}
