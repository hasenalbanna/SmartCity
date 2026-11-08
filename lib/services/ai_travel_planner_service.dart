import 'package:flutter/material.dart';

class TravelInterest {
  final String id;
  final String name;
  final IconData icon;

  const TravelInterest({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class DayPlan {
  final int dayNumber;
  final String destination;
  final List<String> activities;
  final String accommodation;
  final double estimatedCost;
  final String travelTime;

  DayPlan({
    required this.dayNumber,
    required this.destination,
    required this.activities,
    required this.accommodation,
    required this.estimatedCost,
    required this.travelTime,
  });
}

class AITravelPlan {
  final String id;
  final int totalDays;
  final double totalBudget;
  final List<String> interests;
  final List<DayPlan> dailyPlans;
  final String summary;
  final DateTime createdAt;

  AITravelPlan({
    required this.id,
    required this.totalDays,
    required this.totalBudget,
    required this.interests,
    required this.dailyPlans,
    required this.summary,
    required this.createdAt,
  });
}

class AITravelPlannerService extends ChangeNotifier {
  final List<AITravelPlan> _savedPlans = [];

  List<AITravelPlan> get savedPlans => _savedPlans;

  static const List<TravelInterest> availableInterests = [
    TravelInterest(id: 'beach', name: 'Beach & Coast', icon: Icons.beach_access_rounded),
    TravelInterest(id: 'cultural', name: 'Cultural & Heritage', icon: Icons.account_balance_rounded),
    TravelInterest(id: 'wildlife', name: 'Wildlife & Safari', icon: Icons.forest_rounded),
    TravelInterest(id: 'adventure', name: 'Adventure Sports', icon: Icons.surfing_rounded),
    TravelInterest(id: 'nature', name: 'Nature & Hiking', icon: Icons.landscape_rounded),
    TravelInterest(id: 'wellness', name: 'Wellness & Spa', icon: Icons.self_improvement_rounded),
    TravelInterest(id: 'food', name: 'Food & Culinary', icon: Icons.restaurant_rounded),
    TravelInterest(id: 'photography', name: 'Photography', icon: Icons.camera_alt_rounded),
  ];

  // Destination database with activities
  static const Map<String, Map<String, dynamic>> _destinations = {
    'sigiriya': {
      'name': 'Sigiriya',
      'interests': ['cultural', 'photography', 'nature'],
      'activities': [
        'Climb Sigiriya Rock Fortress',
        'Visit Pidurangala Rock',
        'Explore Sigiriya Museum',
        'Village safari by tuk-tuk',
        'Traditional cooking class',
      ],
      'estimatedCost': 80,
      'travelFromColombo': '4 hours',
    },
    'kandy': {
      'name': 'Kandy',
      'interests': ['cultural', 'nature', 'wellness'],
      'activities': [
        'Visit Temple of the Tooth',
        'Royal Botanical Gardens',
        'Kandy Lake walk',
        'Traditional dance show',
        'Tea factory tour',
      ],
      'estimatedCost': 60,
      'travelFromColombo': '3 hours',
    },
    'ella': {
      'name': 'Ella',
      'interests': ['nature', 'adventure', 'photography'],
      'activities': [
        'Nine Arch Bridge visit',
        'Little Adams Peak hike',
        'Ella Rock trek',
        'Scenic train ride',
        'Ravana Falls',
      ],
      'estimatedCost': 50,
      'travelFromColombo': '6 hours',
    },
    'galle': {
      'name': 'Galle',
      'interests': ['cultural', 'beach', 'photography', 'food'],
      'activities': [
        'Galle Fort walking tour',
        'Dutch Reformed Church',
        'Lighthouse visit',
        'Unawatuna Beach',
        'Seafood dinner',
      ],
      'estimatedCost': 70,
      'travelFromColombo': '2.5 hours',
    },
    'mirissa': {
      'name': 'Mirissa',
      'interests': ['beach', 'wildlife', 'adventure'],
      'activities': [
        'Whale watching tour',
        'Mirissa Beach relaxation',
        'Secret Beach visit',
        'Coconut Tree Hill',
        'Snorkeling trip',
      ],
      'estimatedCost': 90,
      'travelFromColombo': '3 hours',
    },
    'yala': {
      'name': 'Yala National Park',
      'interests': ['wildlife', 'photography', 'adventure'],
      'activities': [
        'Morning safari drive',
        'Leopard spotting',
        'Bird watching',
        'Afternoon game drive',
        'Nature photography',
      ],
      'estimatedCost': 150,
      'travelFromColombo': '5 hours',
    },
    'nuwara_eliya': {
      'name': 'Nuwara Eliya',
      'interests': ['nature', 'cultural', 'photography'],
      'activities': [
        'Horton Plains hike',
        'World\'s End viewpoint',
        'Tea plantation tour',
        'Gregory Lake boating',
        'Hakgala Gardens',
      ],
      'estimatedCost': 65,
      'travelFromColombo': '5 hours',
    },
    'arugam_bay': {
      'name': 'Arugam Bay',
      'interests': ['beach', 'adventure', 'wildlife'],
      'activities': [
        'Surfing lessons',
        'Pottuvil Lagoon safari',
        'Beach yoga',
        'Kumana Bird Sanctuary',
        'Beach party',
      ],
      'estimatedCost': 55,
      'travelFromColombo': '7 hours',
    },
    'trincomalee': {
      'name': 'Trincomalee',
      'interests': ['beach', 'wildlife', 'cultural'],
      'activities': [
        'Pigeon Island snorkeling',
        'Koneswaram Temple',
        'Whale watching',
        'Hot springs visit',
        'Marble Beach',
      ],
      'estimatedCost': 60,
      'travelFromColombo': '6 hours',
    },
    'anuradhapura': {
      'name': 'Anuradhapura',
      'interests': ['cultural', 'photography'],
      'activities': [
        'Sacred Bo Tree visit',
        'Ancient ruins exploration',
        'Ruwanwelisaya Stupa',
        'Isurumuniya Temple',
        'Cycling tour',
      ],
      'estimatedCost': 45,
      'travelFromColombo': '4 hours',
    },
  };

  // Generate AI Travel Plan
  AITravelPlan generatePlan({
    required int days,
    required double budget,
    required List<String> interests,
  }) {
    List<DayPlan> dailyPlans = [];

    // Filter destinations based on interests
    List<String> matchingDestinations = [];
    _destinations.forEach((key, value) {
      List<String> destInterests = List<String>.from(value['interests']);
      if (interests.any((i) => destInterests.contains(i))) {
        matchingDestinations.add(key);
      }
    });

    // Sort by relevance score
    matchingDestinations.sort((a, b) {
      int scoreA = _calculateRelevanceScore(
        _destinations[a]!['interests'],
        interests,
      );
      int scoreB = _calculateRelevanceScore(
        _destinations[b]!['interests'],
        interests,
      );
      return scoreB.compareTo(scoreA);
    });

    // Budget calculation
    double dailyBudget = budget / days;
    double remainingBudget = budget;

    // Generate day plans
    int destIndex = 0;
    String? previousDest;

    for (int day = 1; day <= days; day++) {
      if (destIndex >= matchingDestinations.length) {
        destIndex = 0; // Cycle through destinations
      }

      String destKey = matchingDestinations[destIndex];
      Map<String, dynamic> dest = _destinations[destKey]!;

      double estimatedCost = (dest['estimatedCost'] as num).toDouble();

      // Adjust for budget
      if (estimatedCost > remainingBudget / (days - day + 1)) {
        // Find cheaper destination
        for (var cheaperDest in matchingDestinations) {
          if ((_destinations[cheaperDest]!['estimatedCost'] as num) <=
              remainingBudget / (days - day + 1)) {
            destKey = cheaperDest;
            dest = _destinations[destKey]!;
            estimatedCost = (dest['estimatedCost'] as num).toDouble();
            break;
          }
        }
      }

      List<String> activities = List<String>.from(dest['activities']);
      // Select 3-4 activities for the day
      activities.shuffle();
      activities = activities.take(day % 2 == 0 ? 4 : 3).toList();

      String travelTime = previousDest == destKey
          ? 'Same location'
          : dest['travelFromColombo'] as String;

      dailyPlans.add(
        DayPlan(
          dayNumber: day,
          destination: dest['name'] as String,
          activities: activities,
          accommodation: _selectAccommodation(
            dest['name'] as String,
            dailyBudget,
          ),
          estimatedCost: estimatedCost,
          travelTime: travelTime,
        ),
      );

      remainingBudget -= estimatedCost;
      previousDest = destKey;

      // Change destination every 1-2 days
      if (day % 2 == 0) {
        destIndex++;
      }
    }

    String summary = _generateSummary(dailyPlans, interests, days, budget);

    final plan = AITravelPlan(
      id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
      totalDays: days,
      totalBudget: budget,
      interests: interests,
      dailyPlans: dailyPlans,
      summary: summary,
      createdAt: DateTime.now(),
    );

    return plan;
  }

  int _calculateRelevanceScore(
    List<dynamic> destInterests,
    List<String> userInterests,
  ) {
    int score = 0;
    for (var interest in userInterests) {
      if (destInterests.contains(interest)) {
        score += 10;
      }
    }
    return score;
  }

  String _selectAccommodation(String destination, double budget) {
    if (budget > 200) {
      return 'Luxury Resort in $destination';
    } else if (budget > 100) {
      return 'Boutique Hotel in $destination';
    } else if (budget > 50) {
      return 'Mid-range Hotel in $destination';
    } else {
      return 'Budget Guesthouse in $destination';
    }
  }

  String _generateSummary(
    List<DayPlan> plans,
    List<String> interests,
    int days,
    double budget,
  ) {
    Set<String> destinations = plans.map((p) => p.destination).toSet();
    String interestText = interests
        .map((i) {
          return availableInterests.firstWhere((ai) => ai.id == i).name;
        })
        .join(', ');

    return 'Your $days-day Sri Lanka adventure includes ${destinations.length} amazing destinations: '
        '${destinations.join(", ")}. Based on your interests in $interestText, '
        'we\'ve crafted an unforgettable journey within your \$${budget.toStringAsFixed(0)} budget.';
  }

  void savePlan(AITravelPlan plan) {
    _savedPlans.add(plan);
    notifyListeners();
  }

  void deletePlan(String planId) {
    _savedPlans.removeWhere((p) => p.id == planId);
    notifyListeners();
  }
}
