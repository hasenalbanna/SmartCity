import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:smart_city/models/ai_hazard_analysis.dart';
import 'package:smart_city/models/community_issue.dart';
import 'package:smart_city/services/ai_hazard_aggregator_service.dart';
import 'package:smart_city/services/falcon_ai_service.dart';
import 'package:smart_city/services/subscription_service.dart';
import 'package:smart_city/services/voice_ai_assistant_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DisasterShield AI Hazard Aggregator Tests', () {
    late AiHazardAggregatorService aggregator;

    setUp(() {
      aggregator = AiHazardAggregatorService();
    });

    test('Pothole report generates Council Work Order with correct bounds', () async {
      final analysis = await aggregator.evaluateReport(
        category: 'ROAD/POTHOLE',
        description:
            'Deep road potholes causing traffic hazards near central junction',
        contactNumber: '+94 77 123 4567',
        coordinates: const LatLng(7.3486, 81.8494),
        imagePath: '/path/to/pothole.jpg',
      );

      expect(analysis.routingChannel, equals(AiRoutingChannel.councilTicket));
      expect(analysis.councilTicketId.startsWith('CW-2026-NIN-'), isTrue);
      expect(analysis.urgencyScore, greaterThanOrEqualTo(7.0));
      expect(analysis.confidenceScore, greaterThanOrEqualTo(0.90));
      expect(analysis.locationMatch, isTrue);
    });

    test('Severe coastal erosion generates Area Alert when urgency is high', () async {
      final analysis = await aggregator.evaluateReport(
        category: 'COASTAL EROSION',
        description:
            'Massive wave erosion destroying beachfront access barrier during high tide',
        contactNumber: '+94 77 999 8888',
        coordinates: const LatLng(7.3490, 81.8590),
        imagePath: '/path/to/coastal.jpg',
        hasAudio: true,
      );

      expect(analysis.routingChannel, equals(AiRoutingChannel.areaAlert));
      expect(analysis.urgencyScore, greaterThanOrEqualTo(8.5));
      expect(analysis.weatherCorrelated, isTrue);
    });

    test('Anti-spam check penalizes bogus/spam reports', () async {
      final analysis = await aggregator.evaluateReport(
        category: 'ROAD/POTHOLE',
        description: 'test',
        contactNumber: '12',
        coordinates: const LatLng(7.3486, 81.8494),
      );

      expect(analysis.antiSpamPassed, isFalse);
      expect(analysis.routingChannel, equals(AiRoutingChannel.needMoreInfo));
    });
  });

  group('Voice AI Natural Language Intent Parser Tests', () {
    test('Identifies road damage from natural speech', () async {
      final result = await VoiceAiAssistantService.processVoicePrompt(
        'There is a big dangerous pothole on Main Road',
        defaultLocation: const LatLng(7.3486, 81.8494),
      );

      expect(result.isIdentified, isTrue);
      expect(result.detectedCategory, equals('ROAD/POTHOLE'));
      expect(result.generatedIssue?.aiAnalysis?.councilTicketId, isNotNull);
    });

    test('Identifies drainage overflow from Tamil/English mixed phrase', () async {
      final result = await VoiceAiAssistantService.processVoicePrompt(
        'Stormwater canal overflowing with water into houses',
        defaultLocation: const LatLng(7.3486, 81.8494),
      );

      expect(result.isIdentified, isTrue);
      expect(result.detectedCategory, equals('DRAINAGE/CANAL'));
      expect(result.generatedIssue?.aiAnalysis?.weatherCorrelated, isTrue);
    });
  });

  group('Falcon AI Wake-Word & Emergency Danger Dispatch Tests', () {
    test(
      'Saying "Hey Falcon, wake up" wakes Falcon AI and asks "What happened, Master?"',
      () async {
        final falcon = FalconAiService();
        CommunityIssue? dispatched;

        await falcon.processVoiceInput(
          'Hey Falcon, wake up',
          onEmergencyDispatched: (issue) => dispatched = issue,
        );

        expect(falcon.state, equals(FalconAiState.awake));
        expect(falcon.statusHeadline.contains('What happened, Master?'), isTrue);
        expect(dispatched, isNull);

        await falcon.processVoiceInput(
          "I'm in a danger, report this",
          onEmergencyDispatched: (issue) => dispatched = issue,
        );

        expect(falcon.state, equals(FalconAiState.dispatched));
        expect(falcon.isSirenActive, isTrue);
        expect(dispatched, isNotNull);
        expect(
          dispatched!.aiAnalysis?.councilTicketId.startsWith('FALCON-SOS-'),
          isTrue,
        );
        expect(dispatched!.aiAnalysis?.urgencyScore, equals(9.9));

        falcon.stopSiren();
        expect(falcon.isSirenActive, isFalse);
        falcon.dispose();
      },
    );
  });

  group('Subscription & Monetization Marketplace Tests', () {
    test('Upgrades plans and tracks pay-per-use add-on purchases', () {
      final sub = SubscriptionService();
      expect(sub.currentPlan, equals(SubscriptionPlan.free));
      expect(sub.isProOrHigher, isFalse);

      sub.upgradePlan(SubscriptionPlan.falconPro);
      expect(sub.isProOrHigher, isTrue);
      expect(sub.insuranceDossiersRemaining, equals(3));

      final addOn = SubscriptionService.marketplaceAddOns.first;
      sub.purchaseAddOn(addOn);
      expect(sub.purchasedAddOnIds.contains(addOn.id), isTrue);
      expect(sub.insuranceDossiersRemaining, equals(4));
    });
  });
}
