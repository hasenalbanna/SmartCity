import 'package:flutter/material.dart';
import 'itinerary_screen.dart';

/// Delegates directly to [ItineraryScreen] (the Ceylon Explorer AI Trip Planner
/// & Live Route Engine previously in the footer).
class AiTravelPlannerScreen extends StatelessWidget {
  const AiTravelPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ItineraryScreen();
  }
}
