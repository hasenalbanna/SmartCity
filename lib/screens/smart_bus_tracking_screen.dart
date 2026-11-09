import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/smart_bus.dart';
import '../services/smart_bus_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/premium_store_modal.dart';
import '../widgets/smart_city_drawer.dart';
import '../widgets/ui/ui.dart';

class SmartBusTrackingScreen extends StatefulWidget {
  const SmartBusTrackingScreen({super.key});

  @override
  State<SmartBusTrackingScreen> createState() => _SmartBusTrackingScreenState();
}

class _SmartBusTrackingScreenState extends State<SmartBusTrackingScreen> {
  final MapController _mapController = MapController();
  String? _selectedBusId;
  bool _followBus = false;

  StatusChip _occupancyChip(BusOccupancy occ) {
    switch (occ) {
      case BusOccupancy.low:
        return const StatusChip(
          label: 'Many Seats',
          kind: StatusChipKind.resolved,
          icon: Icons.event_seat_outlined,
        );
      case BusOccupancy.moderate:
        return const StatusChip(
          label: 'Seats Available',
          kind: StatusChipKind.inProgress,
          icon: Icons.people_outline_rounded,
        );
      case BusOccupancy.crowded:
        return const StatusChip(
          label: 'Crowded',
          kind: StatusChipKind.pending,
          icon: Icons.groups_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final busService = context.watch<SmartBusService>();
    final routes = busService.routes;
    final activeBuses = busService.getBusesForSelectedRoute();

    SmartBus? trackedBus;
    if (_selectedBusId != null) {
      for (final b in activeBuses) {
        if (b.id == _selectedBusId) {
          trackedBus = b;
          break;
        }
      }
    }
    trackedBus ??= activeBuses.isNotEmpty ? activeBuses.first : null;

    if (_followBus && trackedBus != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(
            trackedBus!.location,
            _mapController.camera.zoom,
          );
        }
      });
    }

    return AppScaffold(
      drawer: const SmartCityDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Smart Transit'),
            const SizedBox(width: AppSpace.sm),
            const StatusChip(
              label: 'LIVE GPS',
              kind: StatusChipKind.resolved,
              icon: Icons.sensors_rounded,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpace.md),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Follow Bus',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                Switch(
                  value: _followBus,
                  onChanged: (val) => setState(() => _followBus = val),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Next Stop Banner
          if (trackedBus != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.lg,
                vertical: AppSpace.sm,
              ),
              color: AppColors.infoBg(context),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_bus_filled_rounded,
                    size: 18,
                    color: AppColors.primary(context),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  Expanded(
                    child: Text(
                      '${trackedBus.busNumber} • Next stop: ${trackedBus.nextStop} in ${trackedBus.etaMinutes} min (${trackedBus.speedKmH.toInt()} km/h)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 2. Route Filter Chips
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.lg,
              vertical: AppSpace.sm,
            ),
            color: AppColors.surface(context),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpace.sm),
                    child: ChoiceChip(
                      label: const Text('All Routes'),
                      selected: busService.selectedRouteId == null,
                      onSelected: (_) => busService.selectRoute(null),
                    ),
                  ),
                  ...routes.map((route) {
                    final selected = busService.selectedRouteId == route.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpace.sm),
                      child: ChoiceChip(
                        label: Text(
                          '${route.routeNumber} (${route.destination})',
                        ),
                        selected: selected,
                        onSelected: (_) {
                          busService.selectRoute(route.id);
                          if (route.pathPoints.isNotEmpty) {
                            _mapController.move(route.pathPoints.first, 13.0);
                          }
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // 3. Full-bleed Map Section
          Expanded(
            flex: 5,
            child: _buildMapSection(context, busService, routes, activeBuses),
          ),

          // 4. Bottom Sheet List of Active Buses
          Expanded(
            flex: 5,
            child: _buildUpcomingBusesList(context, busService, activeBuses),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection(
    BuildContext context,
    SmartBusService busService,
    List<BusRoute> routes,
    List<SmartBus> activeBuses,
  ) {
    final visibleRoutes = busService.selectedRouteId == null
        ? routes
        : routes.where((r) => r.id == busService.selectedRouteId).toList();

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: LatLng(7.3590, 81.8420),
            initialZoom: 12.6,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.smartcity.app',
            ),
            PolylineLayer(
              polylines: visibleRoutes.map((route) {
                return Polyline(
                  points: route.pathPoints,
                  strokeWidth: 4.5,
                  color: Color(route.colorHex),
                );
              }).toList(),
            ),
            MarkerLayer(
              markers: visibleRoutes.expand((route) {
                return route.stops.map((stop) {
                  return Marker(
                    point: stop.location,
                    width: 24,
                    height: 24,
                    child: Tooltip(
                      message: 'Stop: ${stop.name}',
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(route.colorHex),
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  );
                });
              }).toList(),
            ),
            MarkerLayer(
              markers: activeBuses.map((bus) {
                final route = busService.getRouteById(bus.routeId);
                final routeColor = route != null
                    ? Color(route.colorHex)
                    : AppColors.primary(context);
                final isSelected = _selectedBusId == bus.id;

                return Marker(
                  point: bus.location,
                  width: 68,
                  height: 68,
                  child: Semantics(
                    label:
                        'Bus ${bus.busNumber} heading to ${bus.nextStop}, ETA ${bus.etaMinutes} minutes',
                    button: true,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedBusId = bus.id);
                        _mapController.move(bus.location, 14.2);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textPrimaryLight,
                              borderRadius: AppRadius.smBorder,
                            ),
                            child: Text(
                              '${bus.etaMinutes}m',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            width: isSelected ? 36 : 32,
                            height: isSelected ? 36 : 32,
                            decoration: BoxDecoration(
                              color: routeColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                            ),
                            child: const Icon(
                              Icons.directions_bus_filled_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        Positioned(
          right: AppSpace.md,
          bottom: AppSpace.md,
          child: AppButton(
            label: 'Central Hub',
            icon: Icons.my_location_rounded,
            variant: AppButtonVariant.secondary,
            onPressed: () {
              _mapController.move(const LatLng(7.3486, 81.8475), 13.5);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingBusesList(
    BuildContext context,
    SmartBusService busService,
    List<SmartBus> activeBuses,
  ) {
    return Container(
      padding: AppSpace.pagePadding,
      color: AppColors.background(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Active Smart Buses (${activeBuses.length})',
            subtitle: 'Tap a bus to track its live GPS route and ETA',
            actionLabel: 'VIP Pass (LKR 650)',
            onAction: () => PremiumStoreModal.show(context),
          ),
          const SizedBox(height: AppSpace.sm),
          const PremiumUpsellBanner(
            title: 'Smart Bus 7-Day Unlimited VIP Pass & Sponsored Bus Stop Pins',
            subtitle:
                'Reserve A/C seats + get 15% top-up cashback, or promote your local shop at Nintavur bus stops.',
            priceBadge: 'LKR 650 / WK',
            ctaLabel: 'Get VIP Pass',
            icon: Icons.confirmation_num_outlined,
          ),
          const SizedBox(height: AppSpace.md),
          Expanded(
            child: activeBuses.isEmpty
                ? const EmptyState(
                    icon: Icons.directions_bus_outlined,
                    title: 'No buses on this route right now',
                    subtitle: 'Switch back to All Routes to view active buses.',
                  )
                : ListView.separated(
                    itemCount: activeBuses.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpace.md),
                    itemBuilder: (context, index) {
                      final bus = activeBuses[index];
                      final route = busService.getRouteById(bus.routeId);
                      final routeColor = route != null
                          ? Color(route.colorHex)
                          : AppColors.primary(context);

                      return AppCard(
                        accentBorderColor:
                            _selectedBusId == bus.id ? routeColor : null,
                        onTap: () {
                          setState(() => _selectedBusId = bus.id);
                          _mapController.move(bus.location, 14.5);
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: routeColor.withValues(alpha: 0.14),
                                borderRadius: AppRadius.smBorder,
                              ),
                              child: Center(
                                child: Text(
                                  route?.routeNumber.replaceAll('Route ', '') ??
                                      'BUS',
                                  style: AppTypography.subtitle.copyWith(
                                    color: routeColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpace.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          route?.displayName ?? bus.busNumber,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style:
                                              AppTypography.subtitle.copyWith(
                                            color: AppColors.textPrimary(
                                              context,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpace.sm),
                                      Text(
                                        '${bus.etaMinutes} min',
                                        style: AppTypography.subtitle.copyWith(
                                          color: AppColors.success(context),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpace.xs),
                                  Text(
                                    'Next stop: ${bus.nextStop} • ${bus.speedKmH.toStringAsFixed(0)} km/h',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textSecondary(context),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpace.sm),
                                  Wrap(
                                    spacing: AppSpace.sm,
                                    runSpacing: AppSpace.xs,
                                    children: [
                                      _occupancyChip(bus.occupancy),
                                      if (bus.isAirConditioned)
                                        const StatusChip(
                                          label: 'A/C',
                                          kind: StatusChipKind.info,
                                          icon: Icons.ac_unit_rounded,
                                        ),
                                      if (bus.isWheelchairAccessible)
                                        const StatusChip(
                                          label: 'Accessible',
                                          kind: StatusChipKind.neutral,
                                          icon: Icons.accessible_rounded,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
