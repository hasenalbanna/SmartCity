enum AiRoutingChannel {
  councilTicket, // Municipal Work Order (Roads, drainage, streetlights, sanitation)
  areaAlert,     // High Urgency (>= 8.0) emergency broadcast to ward
  published,     // Verified community feed
  needMoreInfo,  // Under verification threshold
}

class AiHazardAnalysis {
  final double confidenceScore; // e.g. 0.94 (94%)
  final double urgencyScore;    // 1.0 to 10.0
  final AiRoutingChannel routingChannel;
  final String councilTicketId; // e.g. "CW-2026-NIN-4821"
  final bool locationMatch;
  final bool weatherCorrelated;
  final bool antiSpamPassed;
  final String reasoning;
  final String visionDetection;
  final int peopleAtRisk;
  final int estimatedResponseHours;
  final DateTime processedAt;

  const AiHazardAnalysis({
    required this.confidenceScore,
    required this.urgencyScore,
    required this.routingChannel,
    required this.councilTicketId,
    this.locationMatch = true,
    this.weatherCorrelated = true,
    this.antiSpamPassed = true,
    required this.reasoning,
    required this.visionDetection,
    this.peopleAtRisk = 25,
    this.estimatedResponseHours = 4,
    required this.processedAt,
  });

  String get channelLabel {
    switch (routingChannel) {
      case AiRoutingChannel.councilTicket:
        return 'Council Work Order';
      case AiRoutingChannel.areaAlert:
        return 'Area Alert';
      case AiRoutingChannel.published:
        return 'Verified Issue';
      case AiRoutingChannel.needMoreInfo:
        return 'Verification Needed';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'confidenceScore': confidenceScore,
      'urgencyScore': urgencyScore,
      'routingChannel': routingChannel.name,
      'councilTicketId': councilTicketId,
      'locationMatch': locationMatch,
      'weatherCorrelated': weatherCorrelated,
      'antiSpamPassed': antiSpamPassed,
      'reasoning': reasoning,
      'visionDetection': visionDetection,
      'peopleAtRisk': peopleAtRisk,
      'estimatedResponseHours': estimatedResponseHours,
      'processedAt': processedAt.toIso8601String(),
    };
  }

  factory AiHazardAnalysis.fromJson(Map<String, dynamic> json) {
    return AiHazardAnalysis(
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.90,
      urgencyScore: (json['urgencyScore'] as num?)?.toDouble() ?? 7.5,
      routingChannel: AiRoutingChannel.values.firstWhere(
        (e) => e.name == json['routingChannel'],
        orElse: () => AiRoutingChannel.councilTicket,
      ),
      councilTicketId: json['councilTicketId'] as String? ?? 'CW-2026-NIN-1001',
      locationMatch: json['locationMatch'] as bool? ?? true,
      weatherCorrelated: json['weatherCorrelated'] as bool? ?? true,
      antiSpamPassed: json['antiSpamPassed'] as bool? ?? true,
      reasoning: json['reasoning'] as String? ?? 'Verified by Smart City AI Engine.',
      visionDetection: json['visionDetection'] as String? ?? 'Structural hazard detected',
      peopleAtRisk: json['peopleAtRisk'] as int? ?? 20,
      estimatedResponseHours: json['estimatedResponseHours'] as int? ?? 4,
      processedAt: DateTime.tryParse(json['processedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

