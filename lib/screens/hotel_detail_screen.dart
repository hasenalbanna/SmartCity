import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/hotels_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/ui/ui.dart';

class HotelDetailScreen extends StatelessWidget {
  final Hotel hotel;

  const HotelDetailScreen({super.key, required this.hotel});

  String _fallbackAssetForCity(String city) {
    final c = city.toLowerCase();
    if (c.contains('sigiriya')) return 'assets/images/sigiriya.jpg';
    if (c.contains('kandy')) {
      return 'assets/central province/temple of tooth.jpg';
    }
    if (c.contains('galle')) return 'assets/southern province/galle fort.jpg';
    if (c.contains('ella')) return 'assets/images/nine_arch_bridge.jpg';
    if (c.contains('mirissa')) {
      return 'assets/southern province/mirissa beach.jpg';
    }
    if (c.contains('arugam') || c.contains('trinco')) {
      return 'assets/eastern province/arugam bay.jpg';
    }
    if (c.contains('nuwara')) {
      return 'assets/central province/nuwara eliya tea country.jpg';
    }
    return 'assets/western province/galle-face.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final fallbackAsset = _fallbackAssetForCity(hotel.city);

    return AppScaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 290,
            pinned: true,
            backgroundColor: AppColors.surface(context),
            leading: Padding(
              padding: const EdgeInsets.all(AppSpace.xs),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.55),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Share Hotel',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Booking.com hotel link copied!')),
                  );
                },
                icon: const Icon(Icons.share_outlined),
              ),
              IconButton(
                tooltip: 'Save Property',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saved ${hotel.name} to favorites!')),
                  );
                },
                icon: Icon(
                  Icons.favorite_border_rounded,
                  color: AppColors.danger(context),
                ),
              ),
              const SizedBox(width: AppSpace.sm),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    hotel.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      fallbackAsset,
                      fit: BoxFit.cover,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.78),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 86,
                    right: AppSpace.lg,
                    child: StatusChip(
                      label: hotel.priceRange,
                      kind: StatusChipKind.info,
                    ),
                  ),
                  Positioned(
                    bottom: AppSpace.lg,
                    left: AppSpace.lg,
                    right: AppSpace.lg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hotel.name,
                          style: AppTypography.display.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpace.sm),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpace.sm,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary(context),
                                borderRadius: AppRadius.smBorder,
                              ),
                              child: Text(
                                hotel.rating.toStringAsFixed(1),
                                style: AppTypography.subtitle.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpace.sm),
                            Text(
                              hotel.ratingText,
                              style: AppTypography.subtitle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: AppSpace.sm),
                            Text(
                              '(${hotel.reviewCount} verified reviews)',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppSpace.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location Card
                  AppCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpace.md),
                          decoration: BoxDecoration(
                            color: AppColors.primary(context)
                                .withValues(alpha: 0.12),
                            borderRadius: AppRadius.mdBorder,
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primary(context),
                          ),
                        ),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hotel.city,
                                style: AppTypography.title.copyWith(
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${hotel.distanceFromCenter} km from city center',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _openInMaps,
                          icon: const Icon(Icons.directions_rounded),
                          label: const Text('Directions'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.xl),

                  // Interactive Property Map
                  const SectionHeader(
                    title: 'Property Location Map',
                    subtitle: 'Pinpoint coordinates & surrounding transit',
                  ),
                  const SizedBox(height: AppSpace.sm),
                  ClipRRect(
                    borderRadius: AppRadius.lgBorder,
                    child: SizedBox(
                      height: 200,
                      child: Stack(
                        children: [
                          FlutterMap(
                            options: MapOptions(
                              initialCenter: hotel.location,
                              initialZoom: 14.5,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.smartcity.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: hotel.location,
                                    width: 52,
                                    height: 52,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primary(context),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2.5,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.hotel_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            bottom: AppSpace.md,
                            right: AppSpace.md,
                            child: AppButton(
                              label: 'Open in Maps',
                              icon: Icons.open_in_new_rounded,
                              variant: AppButtonVariant.secondary,
                              onPressed: _openInMaps,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.xl),

                  // About
                  const SectionHeader(
                    title: 'About This Property',
                    subtitle: 'Booking.com verified property description',
                  ),
                  const SizedBox(height: AppSpace.sm),
                  AppCard(
                    child: Text(
                      hotel.description,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.xl),

                  // Popular Amenities
                  const SectionHeader(
                    title: 'Most Popular Facilities',
                    subtitle: 'Included with your reservation',
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Wrap(
                    spacing: AppSpace.sm,
                    runSpacing: AppSpace.sm,
                    children: hotel.amenities.map((amenity) {
                      return StatusChip(
                        label: amenity,
                        kind: StatusChipKind.info,
                        icon: _getAmenityIcon(amenity),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpace.xl),

                  // Property Highlights
                  if (hotel.highlights.isNotEmpty) ...[
                    const SectionHeader(
                      title: 'Property Highlights',
                      subtitle: 'Why guests love staying here',
                    ),
                    const SizedBox(height: AppSpace.sm),
                    AppCard(
                      child: Column(
                        children: hotel.highlights.map((highlight) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpace.xs,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: AppColors.warning(context),
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpace.sm),
                                Expanded(
                                  child: Text(
                                    highlight,
                                    style: AppTypography.body.copyWith(
                                      color: AppColors.textPrimary(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpace.xl),
                  ],

                  // Primary CTA: Book Now on Booking.com
                  AppButton(
                    label: 'Book Now on Booking.com',
                    icon: Icons.calendar_today_rounded,
                    fullWidth: true,
                    onPressed: _openBooking,
                  ),
                  const SizedBox(height: AppSpace.md),

                  // Secondary Contact Actions
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Call Hotel',
                          icon: Icons.phone_outlined,
                          variant: AppButtonVariant.secondary,
                          fullWidth: true,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Dialing ${hotel.name} front desk...'),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpace.md),
                      Expanded(
                        child: AppButton(
                          label: 'Email Property',
                          icon: Icons.email_outlined,
                          variant: AppButtonVariant.secondary,
                          fullWidth: true,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Sending inquiry to ${hotel.name}...'),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAmenityIcon(String amenity) {
    final amenityLower = amenity.toLowerCase();
    if (amenityLower.contains('wifi')) return Icons.wifi_rounded;
    if (amenityLower.contains('pool')) return Icons.pool_rounded;
    if (amenityLower.contains('spa')) return Icons.spa_rounded;
    if (amenityLower.contains('restaurant')) return Icons.restaurant_rounded;
    if (amenityLower.contains('bar')) return Icons.local_bar_rounded;
    if (amenityLower.contains('fitness') || amenityLower.contains('gym')) {
      return Icons.fitness_center_rounded;
    }
    if (amenityLower.contains('parking')) return Icons.local_parking_rounded;
    if (amenityLower.contains('beach')) return Icons.beach_access_rounded;
    if (amenityLower.contains('garden')) return Icons.yard_rounded;
    if (amenityLower.contains('air') || amenityLower.contains('ac')) {
      return Icons.ac_unit_rounded;
    }
    if (amenityLower.contains('room service')) {
      return Icons.room_service_rounded;
    }
    if (amenityLower.contains('airport') || amenityLower.contains('shuttle')) {
      return Icons.airport_shuttle_rounded;
    }
    return Icons.check_circle_outline_rounded;
  }

  Future<void> _openInMaps() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${hotel.location.latitude},${hotel.location.longitude}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openBooking() async {
    final uri = Uri.https(
      'www.booking.com',
      '/searchresults.html',
      {'ss': '${hotel.name} ${hotel.city} Sri Lanka'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

