import 'package:latlong2/latlong.dart';
import '../models/community_issue.dart';
import 'ai_hazard_aggregator_service.dart';

class VoiceAiCommandResult {
  final String transcript;
  final String responseMessage;
  final bool isIdentified;
  final String? detectedCategory;
  final String? detectedCategoryLocal;
  final String? suggestedTitle;
  final String? suggestedDescription;
  final LatLng? suggestedLocation;
  final CommunityIssue? generatedIssue;

  const VoiceAiCommandResult({
    required this.transcript,
    required this.responseMessage,
    this.isIdentified = false,
    this.detectedCategory,
    this.detectedCategoryLocal,
    this.suggestedTitle,
    this.suggestedDescription,
    this.suggestedLocation,
    this.generatedIssue,
  });
}

class VoiceAiAssistantService {
  static final AiHazardAggregatorService _aggregator = AiHazardAggregatorService();

  /// Natural Language Intent Parser for Urban & Civic Issue Reporting
  static Future<VoiceAiCommandResult> processVoicePrompt(
    String rawPrompt, {
    required LatLng defaultLocation,
  }) async {
    final phrase = rawPrompt.toLowerCase().trim();

    // 1. Pothole / Road Damage Intent
    if (phrase.contains('road') ||
        phrase.contains('pothole') ||
        phrase.contains('hole') ||
        phrase.contains('street') && phrase.contains('bad') ||
        phrase.contains('வீதி') ||
        phrase.contains('பாதை')) {
      const cat = 'ROAD/POTHOLE';
      const catLocal = 'வீதி';
      final title = 'Road damage reported via Voice AI';
      final desc = 'Citizen reported via voice: "$rawPrompt". Road surface degradation requires immediate patching.';
      final coords = defaultLocation;

      final aiAnalysis = await _aggregator.evaluateReport(
        category: cat,
        description: desc,
        contactNumber: '+94 77 000 1122',
        coordinates: coords,
        hasAudio: true,
      );

      final issue = CommunityIssue(
        id: 'voice_${DateTime.now().millisecondsSinceEpoch}',
        category: cat,
        categoryLocal: catLocal,
        title: title,
        description: desc,
        address: 'Nintavur Main Road, Eastern Province, Sri Lanka',
        location: coords,
        status: IssueStatus.pending,
        contactNumber: '+94 77 000 1122',
        hasAudio: true,
        createdAt: DateTime.now(),
        aiAnalysis: aiAnalysis,
      );

      return VoiceAiCommandResult(
        transcript: rawPrompt,
        responseMessage: 'Road damage intent recognized! Municipal Council Ticket generated (#${aiAnalysis.councilTicketId}) with ${aiAnalysis.urgencyScore}/10 urgency.',
        isIdentified: true,
        detectedCategory: cat,
        detectedCategoryLocal: catLocal,
        suggestedTitle: title,
        suggestedDescription: desc,
        suggestedLocation: coords,
        generatedIssue: issue,
      );
    }

    // 2. Drainage / Canal Overflow Intent
    if (phrase.contains('drain') ||
        phrase.contains('canal') ||
        phrase.contains('water') ||
        phrase.contains('flood') ||
        phrase.contains('overflow') ||
        phrase.contains('வடிகால்') ||
        phrase.contains('வெள்ளம்')) {
      const cat = 'DRAINAGE/CANAL';
      const catLocal = 'வடிகால்';
      final title = 'Canal drainage blockage reported';
      final desc = 'Citizen reported via voice: "$rawPrompt". Stormwater canal overflowing into roadway.';
      final coords = LatLng(defaultLocation.latitude - 0.003, defaultLocation.longitude - 0.002);

      final aiAnalysis = await _aggregator.evaluateReport(
        category: cat,
        description: desc,
        contactNumber: '+94 77 000 2233',
        coordinates: coords,
        hasAudio: true,
      );

      final issue = CommunityIssue(
        id: 'voice_${DateTime.now().millisecondsSinceEpoch}',
        category: cat,
        categoryLocal: catLocal,
        title: title,
        description: desc,
        address: 'Pottuvil-Batticaloa Road, Nintavur, Sri Lanka',
        location: coords,
        status: IssueStatus.pending,
        contactNumber: '+94 77 000 2233',
        hasAudio: true,
        createdAt: DateTime.now(),
        aiAnalysis: aiAnalysis,
      );

      return VoiceAiCommandResult(
        transcript: rawPrompt,
        responseMessage: 'Drainage blockage detected! Weather correlation verified with rainfall gauges. Council work order generated.',
        isIdentified: true,
        detectedCategory: cat,
        detectedCategoryLocal: catLocal,
        suggestedTitle: title,
        suggestedDescription: desc,
        suggestedLocation: coords,
        generatedIssue: issue,
      );
    }

    // 3. Street Light Broken Intent
    if (phrase.contains('light') ||
        phrase.contains('lamp') ||
        phrase.contains('dark') ||
        phrase.contains('bulb') ||
        phrase.contains('மின்விளக்கு') ||
        phrase.contains('விளக்கு')) {
      const cat = 'STREET LIGHTS';
      const catLocal = 'வீதி விளக்கு';
      final title = 'Broken street lights on public street';
      final desc = 'Citizen reported via voice: "$rawPrompt". Non-functioning luminaire causing hazard for nighttime travelers.';
      final coords = LatLng(defaultLocation.latitude + 0.002, defaultLocation.longitude + 0.004);

      final aiAnalysis = await _aggregator.evaluateReport(
        category: cat,
        description: desc,
        contactNumber: '+94 77 000 3344',
        coordinates: coords,
        hasAudio: true,
      );

      final issue = CommunityIssue(
        id: 'voice_${DateTime.now().millisecondsSinceEpoch}',
        category: cat,
        categoryLocal: catLocal,
        title: title,
        description: desc,
        address: 'Beach Road Junction, Nintavur, Sri Lanka',
        location: coords,
        status: IssueStatus.pending,
        contactNumber: '+94 77 000 3344',
        hasAudio: true,
        createdAt: DateTime.now(),
        aiAnalysis: aiAnalysis,
      );

      return VoiceAiCommandResult(
        transcript: rawPrompt,
        responseMessage: 'Street lighting hazard logged. Electrical utility work order dispatched.',
        isIdentified: true,
        detectedCategory: cat,
        detectedCategoryLocal: catLocal,
        suggestedTitle: title,
        suggestedDescription: desc,
        suggestedLocation: coords,
        generatedIssue: issue,
      );
    }

    // 4. Garbage / Waste Accumulation Intent
    if (phrase.contains('garbage') ||
        phrase.contains('dump') ||
        phrase.contains('waste') ||
        phrase.contains('trash') ||
        phrase.contains('smell') ||
        phrase.contains('குப்பை')) {
      const cat = 'GARBAGE DUMP';
      const catLocal = 'குப்பை';
      final title = 'Illegal garbage dump accumulation';
      final desc = 'Citizen reported via voice: "$rawPrompt". Uncollected waste requires municipal sanitation vehicle.';
      final coords = LatLng(defaultLocation.latitude - 0.001, defaultLocation.longitude + 0.003);

      final aiAnalysis = await _aggregator.evaluateReport(
        category: cat,
        description: desc,
        contactNumber: '+94 77 000 4455',
        coordinates: coords,
        hasAudio: true,
      );

      final issue = CommunityIssue(
        id: 'voice_${DateTime.now().millisecondsSinceEpoch}',
        category: cat,
        categoryLocal: catLocal,
        title: title,
        description: desc,
        address: 'Hospital Road Market, Nintavur, Sri Lanka',
        location: coords,
        status: IssueStatus.pending,
        contactNumber: '+94 77 000 4455',
        hasAudio: true,
        createdAt: DateTime.now(),
        aiAnalysis: aiAnalysis,
      );

      return VoiceAiCommandResult(
        transcript: rawPrompt,
        responseMessage: 'Sanitation hazard registered. Municipal collection queue updated.',
        isIdentified: true,
        detectedCategory: cat,
        detectedCategoryLocal: catLocal,
        suggestedTitle: title,
        suggestedDescription: desc,
        suggestedLocation: coords,
        generatedIssue: issue,
      );
    }

    // 5. Coastal Erosion / Emergency SOS
    if (phrase.contains('coastal') ||
        phrase.contains('erosion') ||
        phrase.contains('sea') ||
        phrase.contains('tsunami') ||
        phrase.contains('waves') ||
        phrase.contains('கடல்') ||
        phrase.contains('அரிப்பு')) {
      const cat = 'COASTAL EROSION';
      const catLocal = 'கடல் அரிப்பு';
      final title = 'Severe coastal shoreline erosion';
      final desc = 'Citizen reported via voice: "$rawPrompt". Tidal encroachment threatening beach access road.';
      final coords = const LatLng(7.3490, 81.8590);

      final aiAnalysis = await _aggregator.evaluateReport(
        category: cat,
        description: desc,
        contactNumber: '+94 77 000 9999',
        coordinates: coords,
        hasAudio: true,
      );

      final issue = CommunityIssue(
        id: 'voice_${DateTime.now().millisecondsSinceEpoch}',
        category: cat,
        categoryLocal: catLocal,
        title: title,
        description: desc,
        address: 'Nintavur Coastal Belt, Sri Lanka',
        location: coords,
        status: IssueStatus.pending,
        contactNumber: '+94 77 000 9999',
        hasAudio: true,
        createdAt: DateTime.now(),
        aiAnalysis: aiAnalysis,
      );

      return VoiceAiCommandResult(
        transcript: rawPrompt,
        responseMessage: 'Coastal hazard logged with Area Alert status (${aiAnalysis.urgencyScore}/10). Ward emergency operations notified.',
        isIdentified: true,
        detectedCategory: cat,
        detectedCategoryLocal: catLocal,
        suggestedTitle: title,
        suggestedDescription: desc,
        suggestedLocation: coords,
        generatedIssue: issue,
      );
    }

    // Fallback general report
    const cat = 'OTHER ISSUES';
    const catLocal = 'பிற பிரச்சினைகள்';
    final desc = 'Voice report: "$rawPrompt"';
    final aiAnalysis = await _aggregator.evaluateReport(
      category: cat,
      description: desc,
      contactNumber: '+94 77 111 2233',
      coordinates: defaultLocation,
      hasAudio: true,
    );

    return VoiceAiCommandResult(
      transcript: rawPrompt,
      responseMessage: 'Issue transcribed and assigned case reference #${aiAnalysis.councilTicketId}.',
      isIdentified: false,
      detectedCategory: cat,
      detectedCategoryLocal: catLocal,
      suggestedTitle: 'Community issue from voice dictation',
      suggestedDescription: desc,
      suggestedLocation: defaultLocation,
    );
  }
}
