import 'package:flutter/material.dart';
import '../models/sim_provider.dart';

class SIMRecommendationService extends ChangeNotifier {
  // Sri Lanka SIM Providers with real data
  static final List<SIMProvider> providers = [
    SIMProvider(
      id: 'dialog',
      name: 'Dialog Axiata',
      logo: '🔴',
      packages: [
        SIMPackage(
          id: 'd1',
          name: 'Tourist SIM Basic',
          dataGB: 5,
          validityDays: 7,
          priceUSD: 5,
          hasUnlimitedCalls: false,
          hasUnlimitedSMS: false,
          description: 'Perfect for short trips with light usage',
        ),
        SIMPackage(
          id: 'd2',
          name: 'Tourist SIM Plus',
          dataGB: 15,
          validityDays: 14,
          priceUSD: 12,
          hasUnlimitedCalls: true,
          hasUnlimitedSMS: true,
          description: 'Great for 2-week vacations with moderate usage',
        ),
        SIMPackage(
          id: 'd3',
          name: 'Tourist SIM Max',
          dataGB: 30,
          validityDays: 30,
          priceUSD: 25,
          hasUnlimitedCalls: true,
          hasUnlimitedSMS: true,
          description: 'Best for long stays with heavy data needs',
        ),
        SIMPackage(
          id: 'd4',
          name: 'Unlimited Tourist',
          dataGB: 100,
          validityDays: 30,
          priceUSD: 40,
          hasUnlimitedCalls: true,
          hasUnlimitedSMS: true,
          description: 'Unlimited experience for power users',
        ),
      ],
      coverageByRegion: {
        'Western': 98,
        'Central': 95,
        'Southern': 92,
        'Northern': 85,
        'Eastern': 88,
        'North Western': 90,
        'North Central': 87,
        'Uva': 85,
        'Sabaragamuwa': 88,
      },
    ),
    SIMProvider(
      id: 'mobitel',
      name: 'Mobitel',
      logo: '🟢',
      packages: [
        SIMPackage(
          id: 'm1',
          name: 'Welcome Pack',
          dataGB: 4,
          validityDays: 7,
          priceUSD: 4,
          hasUnlimitedCalls: false,
          hasUnlimitedSMS: false,
          description: 'Budget-friendly option for short visits',
        ),
        SIMPackage(
          id: 'm2',
          name: 'Explorer Pack',
          dataGB: 12,
          validityDays: 14,
          priceUSD: 10,
          hasUnlimitedCalls: false,
          hasUnlimitedSMS: true,
          description: 'Good value for 2-week trips',
        ),
        SIMPackage(
          id: 'm3',
          name: 'Traveler Pro',
          dataGB: 25,
          validityDays: 30,
          priceUSD: 20,
          hasUnlimitedCalls: true,
          hasUnlimitedSMS: true,
          description: 'Comprehensive package for month-long stays',
        ),
      ],
      coverageByRegion: {
        'Western': 96,
        'Central': 94,
        'Southern': 93,
        'Northern': 90,
        'Eastern': 91,
        'North Western': 89,
        'North Central': 92,
        'Uva': 86,
        'Sabaragamuwa': 87,
      },
    ),
    SIMProvider(
      id: 'airtel',
      name: 'Airtel Lanka',
      logo: '🔵',
      packages: [
        SIMPackage(
          id: 'a1',
          name: 'Quick Start',
          dataGB: 3,
          validityDays: 5,
          priceUSD: 3,
          hasUnlimitedCalls: false,
          hasUnlimitedSMS: false,
          description: 'Cheapest option for very short trips',
        ),
        SIMPackage(
          id: 'a2',
          name: 'Value Pack',
          dataGB: 10,
          validityDays: 14,
          priceUSD: 8,
          hasUnlimitedCalls: false,
          hasUnlimitedSMS: true,
          description: 'Best budget option for 2 weeks',
        ),
        SIMPackage(
          id: 'a3',
          name: 'Super Saver',
          dataGB: 20,
          validityDays: 30,
          priceUSD: 15,
          hasUnlimitedCalls: true,
          hasUnlimitedSMS: true,
          description: 'Most affordable monthly package',
        ),
      ],
      coverageByRegion: {
        'Western': 92,
        'Central': 88,
        'Southern': 85,
        'Northern': 80,
        'Eastern': 82,
        'North Western': 84,
        'North Central': 81,
        'Uva': 78,
        'Sabaragamuwa': 80,
      },
    ),
    SIMProvider(
      id: 'hutch',
      name: 'Hutch',
      logo: '🟠',
      packages: [
        SIMPackage(
          id: 'h1',
          name: 'Tourist Lite',
          dataGB: 6,
          validityDays: 7,
          priceUSD: 5,
          hasUnlimitedCalls: false,
          hasUnlimitedSMS: false,
          description: 'Good balance of data and price',
        ),
        SIMPackage(
          id: 'h2',
          name: 'Tourist Standard',
          dataGB: 14,
          validityDays: 14,
          priceUSD: 11,
          hasUnlimitedCalls: true,
          hasUnlimitedSMS: true,
          description: 'Popular choice for tourists',
        ),
        SIMPackage(
          id: 'h3',
          name: 'Tourist Premium',
          dataGB: 28,
          validityDays: 30,
          priceUSD: 22,
          hasUnlimitedCalls: true,
          hasUnlimitedSMS: true,
          description: 'Full featured long-term package',
        ),
      ],
      coverageByRegion: {
        'Western': 90,
        'Central': 85,
        'Southern': 87,
        'Northern': 75,
        'Eastern': 78,
        'North Western': 82,
        'North Central': 79,
        'Uva': 76,
        'Sabaragamuwa': 78,
      },
    ),
  ];

  // AI Recommendation Engine
  List<SIMRecommendation> getRecommendations({
    required int stayDays,
    required double expectedDataGB,
    required double budgetUSD,
    required List<String> visitingRegions,
    required String usageType, // 'light', 'moderate', 'heavy'
  }) {
    List<SIMRecommendation> recommendations = [];

    for (final provider in providers) {
      // Calculate average coverage for visiting regions
      double avgCoverage = 0;
      if (visitingRegions.isNotEmpty) {
        for (final region in visitingRegions) {
          avgCoverage += provider.coverageByRegion[region] ?? 80;
        }
        avgCoverage /= visitingRegions.length;
      } else {
        avgCoverage = 85; // Default
      }

      for (final package in provider.packages) {
        // Check if package meets requirements
        if (package.validityDays < stayDays) continue;
        if (package.priceUSD > budgetUSD) continue;
        if (package.dataGB < expectedDataGB * 0.8) continue;

        // Calculate match score
        double score = 0;

        // Coverage score (30%)
        score += (avgCoverage / 100) * 30;

        // Data adequacy score (25%)
        double dataRatio = package.dataGB / expectedDataGB;
        if (dataRatio >= 1) {
          score += 25;
        } else {
          score += (dataRatio * 25);
        }

        // Price efficiency score (25%)
        double priceEfficiency = (budgetUSD - package.priceUSD) / budgetUSD;
        score += (0.5 + priceEfficiency * 0.5) * 25;

        // Validity match score (20%)
        double validityRatio = stayDays / package.validityDays;
        if (validityRatio >= 0.7) {
          score += 20;
        } else {
          score += (validityRatio / 0.7) * 20;
        }

        // Generate reason
        String reason = _generateReason(
          provider: provider,
          package: package,
          avgCoverage: avgCoverage,
          stayDays: stayDays,
          expectedDataGB: expectedDataGB,
        );

        recommendations.add(
          SIMRecommendation(
            provider: provider,
            package: package,
            matchScore: score.clamp(0, 100),
            reason: reason,
          ),
        );
      }
    }

    // Sort by match score
    recommendations.sort((a, b) => b.matchScore.compareTo(a.matchScore));

    return recommendations.take(5).toList();
  }

  String _generateReason({
    required SIMProvider provider,
    required SIMPackage package,
    required double avgCoverage,
    required int stayDays,
    required double expectedDataGB,
  }) {
    List<String> reasons = [];

    if (avgCoverage >= 90) {
      reasons.add('Excellent coverage in your travel areas');
    } else if (avgCoverage >= 80) {
      reasons.add('Good coverage in most regions');
    }

    if (package.dataGB >= expectedDataGB * 1.5) {
      reasons.add('More than enough data for your needs');
    } else if (package.dataGB >= expectedDataGB) {
      reasons.add('Sufficient data for your usage');
    }

    if (package.hasUnlimitedCalls && package.hasUnlimitedSMS) {
      reasons.add('Unlimited calls and SMS included');
    }

    if (package.validityDays >= stayDays * 1.2) {
      reasons.add('Validity covers your entire trip with buffer');
    }

    return reasons.isNotEmpty
        ? reasons.join('. ')
        : 'Good overall match for your requirements';
  }

  // Get regions list
  static List<String> get regions => [
    'Western',
    'Central',
    'Southern',
    'Northern',
    'Eastern',
    'North Western',
    'North Central',
    'Uva',
    'Sabaragamuwa',
  ];
}
