import 'package:flutter/material.dart';
import '../services/trip_history_service.dart';

class TripSummaryScreen extends StatelessWidget {
  final TripHistoryItem? trip; // Accept optional trip for dynamic rendering

  const TripSummaryScreen({super.key, this.trip});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Fallback data if trip is null (e.g. accessed before implementation)
    final fromLoc = trip?.fromLocation ?? 'Unknown';
    final toLoc = trip?.toLocation ?? 'Unknown';
    final vehicle = trip?.vehicle ?? 'Car';
    final dist = trip?.distanceKm.toStringAsFixed(1) ?? '0.0';
    final timeHours = trip?.timeTaken.inHours ?? 0;
    final timeMins = (trip?.timeTaken.inMinutes ?? 0) % 60;
    final maxSpeed = trip?.maxSpeedKmH.toStringAsFixed(1) ?? '0.0';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Summary'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Preview
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: trip != null && trip!.mapPreviewUrl.isNotEmpty
                    ? DecorationImage(
                        image: AssetImage(trip!.mapPreviewUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
              ),
              child: trip == null || trip!.mapPreviewUrl.isEmpty
                  ? Center(child: Icon(Icons.map, size: 64, color: isDark ? Colors.white24 : Colors.black12))
                  : null,
            ),
            const SizedBox(height: 24),
            
            // Route Title
            Text(
              trip?.tripName ?? 'My Trip',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red.shade400, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$fromLoc to $toLoc',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                Text(
                  trip?.rating.toString() ?? '5.0',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Text(
                  trip?.date.toString().substring(0, 16) ?? 'Just now',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(context, Icons.directions_car, 'Vehicle', vehicle),
                _buildStatCard(context, Icons.straighten, 'Distance', '$dist km'),
                _buildStatCard(context, Icons.timer, 'Duration', '${timeHours}h ${timeMins}m'),
                _buildStatCard(context, Icons.speed, 'Max Speed', '$maxSpeed km/h'),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Finish Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Back to Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatCard(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
