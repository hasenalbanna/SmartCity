import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/smart_bus.dart';
import '../services/smart_bus_service.dart';

class SmartBusTrackingScreen extends StatefulWidget {
  const SmartBusTrackingScreen({super.key});

  @override
  State<SmartBusTrackingScreen> createState() => _SmartBusTrackingScreenState();
}

class _SmartBusTrackingScreenState extends State<SmartBusTrackingScreen> {
  final MapController _mapController = MapController();
  SmartBus? _selectedBus;

  Color _getOccupancyColor(BusOccupancy occ) {
    switch (occ) {
      case BusOccupancy.low:
        return const Color(0xFF10B981); // Green
      case BusOccupancy.moderate:
        return const Color(0xFFF59E0B); // Amber
      case BusOccupancy.crowded:
        return const Color(0xFFEF4444); // Red
    }
  }

  String _getOccupancyText(BusOccupancy occ) {
    switch (occ) {
      case BusOccupancy.low:
        return 'Many Seats Available';
      case BusOccupancy.moderate:
        return 'Seats Available';
      case BusOccupancy.crowded:
        return 'Crowded / Standing Only';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final busService = context.watch<SmartBusService>();
    final routes = busService.routes;
    final activeBuses = busService.getBusesForSelectedRoute();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101318) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Bus Tracking',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'LIVE GPS TRANSIT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF10B981),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Route Selector Filter Chips
            _buildRouteSelector(busService, isDark),

            // Interactive Live Map Section
            Expanded(
              flex: 5,
              child: _buildMapSection(busService, routes, activeBuses, isDark),
            ),

            // Live Upcoming Buses Cards Section
            Expanded(
              flex: 5,
              child: _buildUpcomingBusesList(busService, activeBuses, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteSelector(SmartBusService busService, bool isDark) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _filterChip(
            label: 'All Routes',
            isSelected: busService.selectedRouteId == null,
            onTap: () => busService.selectRoute(null),
            isDark: isDark,
          ),
          ...busService.routes.map((route) {
            final isSelected = busService.selectedRouteId == route.id;
            return _filterChip(
              label: '${route.routeNumber} (${route.destination})',
              isSelected: isSelected,
              onTap: () {
                busService.selectRoute(route.id);
                if (route.pathPoints.isNotEmpty) {
                  _mapController.move(route.pathPoints.first, 13.0);
                }
              },
              isDark: isDark,
              color: Color(route.colorHex),
            );
          }),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? (isDark ? Colors.white : Colors.black))
              : (isDark ? Colors.white10 : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? Colors.white12 : const Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null && !isSelected) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(
    SmartBusService service,
    List<BusRoute> routes,
    List<SmartBus> buses,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white24 : const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(7.3620, 81.8460), // Midpoint Nintavur-Kalmunai
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.smartcity.app',
                ),

                // Route Polylines
                PolylineLayer(
                  polylines: routes.map((r) {
                    final isHighlighted =
                        service.selectedRouteId == null || service.selectedRouteId == r.id;
                    return Polyline(
                      points: r.pathPoints,
                      color: Color(r.colorHex).withValues(alpha: isHighlighted ? 0.85 : 0.25),
                      strokeWidth: isHighlighted ? 5.0 : 2.5,
                    );
                  }).toList(),
                ),

                // Bus Stops Markers
                MarkerLayer(
                  markers: routes.expand((r) => r.stops).map((stop) {
                    return Marker(
                      point: stop.location,
                      width: 24,
                      height: 24,
                      child: Tooltip(
                        message: stop.name,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF2563EB), width: 2),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: const Icon(Icons.circle, size: 8, color: Color(0xFF2563EB)),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Live Moving Bus Markers
                MarkerLayer(
                  markers: buses.map((bus) {
                    return Marker(
                      point: bus.location,
                      width: 54,
                      height: 54,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedBus = bus);
                          _mapController.move(bus.location, 14.5);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.4),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.directions_bus, size: 20, color: Colors.white),
                                Text(
                                  bus.busNumber.split('-').last,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            // Zoom In / Out controls
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add, size: 18, color: Colors.black87),
                      onPressed: () => _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom + 1,
                      ),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                    ),
                    const Divider(height: 1, thickness: 1),
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18, color: Colors.black87),
                      onPressed: () => _mapController.move(
                        _mapController.camera.center,
                        _mapController.camera.zoom - 1,
                      ),
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingBusesList(
    SmartBusService service,
    List<SmartBus> buses,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Smart Buses (${buses.length})',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const Text(
                'Auto-updating 3s',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: buses.length,
            itemBuilder: (context, index) {
              final bus = buses[index];
              final route = service.routes.firstWhere(
                (r) => r.id == bus.routeId,
                orElse: () => service.routes.first,
              );
              final isSelected = _selectedBus?.id == bus.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : (isDark ? Colors.white12 : const Color(0xFFF1F3F5)),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(route.colorHex),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                route.routeNumber,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              bus.busNumber,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF15803D)),
                              const SizedBox(width: 4),
                              Text(
                                '${bus.etaMinutes} min away',
                                style: const TextStyle(
                                  color: Color(0xFF15803D),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Next Stop: ${bus.nextStop}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getOccupancyColor(bus.occupancy).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getOccupancyText(bus.occupancy),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _getOccupancyColor(bus.occupancy),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '⚡ ${bus.speedKmH.toStringAsFixed(0)} km/h',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            setState(() => _selectedBus = bus);
                            _mapController.move(bus.location, 15.0);
                          },
                          child: const Text(
                            'Track on Map ↗',
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
