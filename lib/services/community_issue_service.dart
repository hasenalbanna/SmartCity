import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/community_issue.dart';
import '../models/ai_hazard_analysis.dart';
import 'ai_hazard_aggregator_service.dart';

class CommunityIssueService extends ChangeNotifier {
  static const String _storageKey = 'smartcity_community_issues_v1';
  final List<CommunityIssue> _issues = [];
  bool _initialized = false;
  final AiHazardAggregatorService _aiAggregator = AiHazardAggregatorService();

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
        aiAnalysis: AiHazardAnalysis(
          confidenceScore: 0.95,
          urgencyScore: 7.8,
          routingChannel: AiRoutingChannel.councilTicket,
          councilTicketId: 'CW-2026-NIN-4821',
          locationMatch: true,
          weatherCorrelated: true,
          antiSpamPassed: true,
          reasoning: 'Road surface pothole verified. Municipal Council Work Order dispatched.',
          visionDetection: 'Asphalt structural fracture & depth ~14cm',
          peopleAtRisk: 42,
          estimatedResponseHours: 4,
          processedAt: DateTime(2026, 4, 17, 10, 30),
        ),
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
        aiAnalysis: AiHazardAnalysis(
          confidenceScore: 0.93,
          urgencyScore: 7.5,
          routingChannel: AiRoutingChannel.councilTicket,
          councilTicketId: 'CW-2026-ADD-4822',
          locationMatch: true,
          weatherCorrelated: true,
          antiSpamPassed: true,
          reasoning: 'Monsoon erosion confirmed via radar correlation. Public works scheduled.',
          visionDetection: 'Eroded road shoulder & loose gravel',
          peopleAtRisk: 30,
          estimatedResponseHours: 4,
          processedAt: DateTime(2026, 4, 17, 11, 15),
        ),
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
        aiAnalysis: AiHazardAnalysis(
          confidenceScore: 0.91,
          urgencyScore: 6.8,
          routingChannel: AiRoutingChannel.councilTicket,
          councilTicketId: 'CW-2026-NIN-4809',
          locationMatch: true,
          weatherCorrelated: false,
          antiSpamPassed: true,
          reasoning: 'Sanitation backlog verified. Compactor truck dispatched.',
          visionDetection: 'Solid waste accumulation >2m³',
          peopleAtRisk: 65,
          estimatedResponseHours: 8,
          processedAt: DateTime(2026, 4, 16, 9, 0),
        ),
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
        aiAnalysis: AiHazardAnalysis(
          confidenceScore: 0.96,
          urgencyScore: 6.4,
          routingChannel: AiRoutingChannel.councilTicket,
          councilTicketId: 'CW-2026-NIN-4792',
          locationMatch: true,
          weatherCorrelated: false,
          antiSpamPassed: true,
          reasoning: 'Utility repair completed. High-pressure sodium lamps replaced with LED.',
          visionDetection: 'Overhead circuit restored',
          peopleAtRisk: 50,
          estimatedResponseHours: 12,
          processedAt: DateTime(2026, 4, 14, 18, 0),
        ),
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
        aiAnalysis: AiHazardAnalysis(
          confidenceScore: 0.97,
          urgencyScore: 8.8,
          routingChannel: AiRoutingChannel.areaAlert,
          councilTicketId: 'CW-2026-NIN-4780',
          locationMatch: true,
          weatherCorrelated: true,
          antiSpamPassed: true,
          reasoning: 'Severe stormwater canal blockage. Area Alert broadcasted to downstream residents.',
          visionDetection: 'Canal capacity reduced by 85%',
          peopleAtRisk: 120,
          estimatedResponseHours: 2,
          processedAt: DateTime(2026, 4, 13, 14, 30),
        ),
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
        aiAnalysis: AiHazardAnalysis(
          confidenceScore: 0.95,
          urgencyScore: 6.2,
          routingChannel: AiRoutingChannel.published,
          councilTicketId: 'CW-2026-NIN-4775',
          locationMatch: true,
          weatherCorrelated: false,
          antiSpamPassed: true,
          reasoning: 'Maintenance verified by field inspector.',
          visionDetection: 'Luminaires operational',
          peopleAtRisk: 35,
          estimatedResponseHours: 24,
          processedAt: DateTime(2026, 4, 12, 16, 20),
        ),
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
        aiAnalysis: AiHazardAnalysis(
          confidenceScore: 0.94,
          urgencyScore: 7.0,
          routingChannel: AiRoutingChannel.councilTicket,
          councilTicketId: 'CW-2026-NIN-4768',
          locationMatch: true,
          weatherCorrelated: true,
          antiSpamPassed: true,
          reasoning: 'Road resurfacing certified by municipal engineering team.',
          visionDetection: 'Fresh asphalt surface layer',
          peopleAtRisk: 80,
          estimatedResponseHours: 6,
          processedAt: DateTime(2026, 4, 11, 12, 0),
        ),
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
        aiAnalysis: AiHazardAnalysis(
          confidenceScore: 0.89,
          urgencyScore: 6.5,
          routingChannel: AiRoutingChannel.councilTicket,
          councilTicketId: 'CW-2026-NIN-4752',
          locationMatch: true,
          weatherCorrelated: false,
          antiSpamPassed: true,
          reasoning: 'Sanitation request queued.',
          visionDetection: 'Container spillover verified',
          peopleAtRisk: 25,
          estimatedResponseHours: 12,
          processedAt: DateTime(2026, 4, 10, 8, 45),
        ),
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
        aiAnalysis: AiHazardAnalysis(
          confidenceScore: 0.98,
          urgencyScore: 8.6,
          routingChannel: AiRoutingChannel.areaAlert,
          councilTicketId: 'CW-2026-NIN-4740',
          locationMatch: true,
          weatherCorrelated: true,
          antiSpamPassed: true,
          reasoning: 'Shoreline revetment work completed and inspected.',
          visionDetection: 'Rip-rap boulder placement verified',
          peopleAtRisk: 90,
          estimatedResponseHours: 2,
          processedAt: DateTime(2026, 4, 9, 15, 0),
        ),
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

  Future<CommunityIssue> addIssue({
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
    // Run AI Hazard Aggregator Pipeline
    final aiAnalysis = await _aiAggregator.evaluateReport(
      category: category,
      description: description,
      contactNumber: contactNumber,
      coordinates: location,
      imagePath: imagePath,
      hasAudio: hasAudio,
    );

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
      aiAnalysis: aiAnalysis,
    );

    _issues.insert(0, newIssue);
    notifyListeners();
    await _saveToStorage();
    return newIssue;
  }

  Future<void> addDirectIssue(CommunityIssue issue) async {
    _issues.insert(0, issue);
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
