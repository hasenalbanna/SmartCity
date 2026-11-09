import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/hotels_data.dart' as booking_data;
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/ui/ui.dart';
import 'hotel_detail_screen.dart';

class HotelBookingScreen extends StatelessWidget {
  final String? nearPlace;

  const HotelBookingScreen({super.key, this.nearPlace});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Find Your Perfect Stay')),
      body: SingleChildScrollView(
        padding: AppSpace.pagePadding,
        child: HotelBookingView(nearPlace: nearPlace),
      ),
    );
  }
}

/// Booking.com-style Hotel Explorer & Reservation View embedded inside
/// [ItineraryScreen] and [HotelListScreen].
class HotelBookingView extends StatefulWidget {
  final String? nearPlace;
  final LatLng? initialLocationCenter;

  const HotelBookingView({
    super.key,
    this.nearPlace,
    this.initialLocationCenter,
  });

  @override
  State<HotelBookingView> createState() => _HotelBookingViewState();
}

class _HotelBookingViewState extends State<HotelBookingView> {
  final MapController _mapController = MapController();

  String _selectedCity = 'All';
  String _selectedFilter = 'All';
  bool _showMap = true;
  RangeValues _priceRange = const RangeValues(0, 500);
  booking_data.Hotel? _selectedMapHotel;

  static const List<String> _cities = [
    'All',
    'Sigiriya',
    'Kandy',
    'Galle',
    'Ella',
    'Mirissa',
    'Colombo',
    'Nuwara Eliya',
    'Arugam Bay',
    'Trincomalee',
    'Negombo',
  ];

  static const List<String> _tierFilters = [
    'All',
    'Top Rated',
    'Budget',
    'Luxury',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.nearPlace != null) {
      final matched = _cities.firstWhere(
        (c) =>
            c.toLowerCase() == widget.nearPlace!.toLowerCase() ||
            widget.nearPlace!.toLowerCase().contains(c.toLowerCase()),
        orElse: () => 'All',
      );
      _selectedCity = matched;
    }
  }

  int _estimatedPriceUsd(booking_data.Hotel hotel) {
    final dollarCount =
        hotel.priceRange.runes.where((r) => r == 36).length; // '$'
    final ratingBonus = ((hotel.rating - 8.0) * 35).round().clamp(0, 120);
    switch (dollarCount) {
      case 1:
        return 45 + (ratingBonus ~/ 2);
      case 2:
        return 95 + ratingBonus;
      case 3:
        return 185 + ratingBonus;
      default:
        return 250 + ratingBonus;
    }
  }

  String _tierBadgeLabel(booking_data.Hotel hotel) {
    final dollarCount = hotel.priceRange.runes.where((r) => r == 36).length;
    if (dollarCount >= 3) return 'luxury';
    if (dollarCount == 2) return 'mid-range';
    return 'budget';
  }

  List<booking_data.Hotel> get _filteredHotels {
    List<booking_data.Hotel> list;
    if (_selectedCity == 'All') {
      list = booking_data.allHotels;
    } else {
      list = booking_data.getHotelsForCity(_selectedCity);
      if (list.isEmpty) {
        list = booking_data.allHotels;
      }
    }

    if (_selectedFilter == 'Top Rated') {
      list = list.where((h) => h.rating >= 9.0).toList();
    } else if (_selectedFilter == 'Budget') {
      list = list
          .where((h) => h.priceRange == '\$' || h.priceRange == '\$\$')
          .toList();
    } else if (_selectedFilter == 'Luxury') {
      list = list.where((h) => h.priceRange.contains('\$\$\$')).toList();
    }

    list = list.where((h) {
      final price = _estimatedPriceUsd(h);
      return price >= _priceRange.start && price <= _priceRange.end;
    }).toList();

    return list;
  }

  LatLng get _mapCenter {
    if (_selectedMapHotel != null) return _selectedMapHotel!.location;
    if (widget.initialLocationCenter != null) {
      return widget.initialLocationCenter!;
    }
    final list = _filteredHotels;
    if (list.isNotEmpty) return list.first.location;
    return const LatLng(7.8731, 80.7718);
  }

  String _localFallbackAsset(String city) {
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
    final hotels = _filteredHotels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Hero Header Banner ("Find Your Perfect Stay" + Booking.com Verified Badge)
        ClipRRect(
          borderRadius: AppRadius.lgBorder,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 128),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/southern province/mirissa beach.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.78),
                          Colors.black.withValues(alpha: 0.45),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpace.lg),
                  child: SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpace.md,
                      runSpacing: AppSpace.sm,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const StatusChip(
                              label: 'BOOKING.COM PARTNER',
                              kind: StatusChipKind.info,
                              icon: Icons.verified_rounded,
                            ),
                            const SizedBox(height: AppSpace.xs),
                            Text(
                              'Find Your Perfect Stay',
                              style: AppTypography.title.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${hotels.length} hotels & resorts available across Sri Lanka',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        AppButton(
                          label: _showMap ? 'Hide Map' : 'Show Map',
                          icon: Icons.map_outlined,
                          variant: AppButtonVariant.secondary,
                          onPressed: () => setState(() => _showMap = !_showMap),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpace.md),

        // 2. City Pills Row (All, Sigiriya, Kandy, Galle, Ella, Mirissa, etc.)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _cities.map((city) {
              final isSelected = _selectedCity == city;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpace.sm),
                child: ChoiceChip(
                  selected: isSelected,
                  label: Text(city),
                  onSelected: (_) {
                    setState(() {
                      _selectedCity = city;
                      _selectedMapHotel = null;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpace.sm),

        // 3. Booking.com Style Filter Row (All, Top Rated, Budget, Luxury)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _tierFilters.map((filter) {
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpace.sm),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(filter),
                  onSelected: (_) => setState(() => _selectedFilter = filter),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpace.md),

        // 4. Price Range Slider Card ($0 - $500)
        AppCard(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Price Range',
                    style: AppTypography.subtitle.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '\$${_priceRange.start.round()} - \$${_priceRange.end.round()}',
                    style: AppTypography.subtitle.copyWith(
                      color: AppColors.primary(context),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 500,
                divisions: 50,
                activeColor: AppColors.primary(context),
                onChanged: (values) => setState(() => _priceRange = values),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.md),

        // 5. Booking.com Interactive Map with Live Hotel Pins
        if (_showMap && hotels.isNotEmpty) ...[
          ClipRRect(
            borderRadius: AppRadius.lgBorder,
            child: SizedBox(
              height: 220,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _mapCenter,
                      initialZoom: _selectedCity == 'All' ? 7.4 : 12.5,
                      onTap: (_, __) =>
                          setState(() => _selectedMapHotel = null),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.smartcity.app',
                      ),
                      MarkerLayer(
                        markers: hotels.map((hotel) {
                          final isSelected = _selectedMapHotel?.id == hotel.id;
                          return Marker(
                            point: hotel.location,
                            width: isSelected ? 92 : 56,
                            height: 36,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedMapHotel = hotel);
                                _mapController.move(hotel.location, 13.5);
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpace.xs,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.warning(context)
                                      : AppColors.primary(context),
                                  borderRadius: AppRadius.pillBorder,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  '★ ${hotel.rating}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.onPrimary(context),
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  if (_selectedMapHotel != null)
                    Positioned(
                      left: AppSpace.md,
                      right: AppSpace.md,
                      bottom: AppSpace.md,
                      child: AppCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  HotelDetailScreen(hotel: _selectedMapHotel!),
                            ),
                          );
                        },
                        padding: const EdgeInsets.all(AppSpace.sm),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: AppRadius.smBorder,
                              child: _buildHotelPhoto(
                                _selectedMapHotel!,
                                width: 56,
                                height: 56,
                              ),
                            ),
                            const SizedBox(width: AppSpace.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _selectedMapHotel!.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.subtitle.copyWith(
                                      color: AppColors.textPrimary(context),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '${_selectedMapHotel!.rating} ${_selectedMapHotel!.ratingText} • ${_selectedMapHotel!.city}',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.primary(context),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpace.lg),
        ],

        // 6. Hotel Cards List (Booking.com Rating Score + Amenities + Show Prices / Book Now)
        if (hotels.isEmpty)
          const EmptyState(
            icon: Icons.hotel_outlined,
            title: 'No properties match your filter',
            subtitle: 'Try widening the price range or selecting All cities.',
          )
        else
          ...hotels.map(
            (hotel) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.lg),
              child: _buildBookingComHotelCard(context, hotel),
            ),
          ),
      ],
    );
  }

  Widget _buildHotelPhoto(
    booking_data.Hotel hotel, {
    double width = double.infinity,
    double height = 175,
  }) {
    final fallbackAsset = _localFallbackAsset(hotel.city);
    return Image.network(
      hotel.imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        fallbackAsset,
        width: width,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildBookingComHotelCard(
    BuildContext context,
    booking_data.Hotel hotel,
  ) {
    final priceUsd = _estimatedPriceUsd(hotel);
    final tierBadge = _tierBadgeLabel(hotel);

    return AppCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HotelDetailScreen(hotel: hotel),
          ),
        );
      },
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Hero Photo with Category Pill & Booking.com Score Badge
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
                child: _buildHotelPhoto(hotel, height: 175),
              ),
              Positioned(
                top: AppSpace.md,
                left: AppSpace.md,
                child: StatusChip(
                  label: tierBadge,
                  kind: StatusChipKind.info,
                ),
              ),
              Positioned(
                top: AppSpace.md,
                right: AppSpace.md,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.78),
                    borderRadius: AppRadius.smBorder,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: AppColors.warning(context),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${hotel.rating.toStringAsFixed(1)} • ${hotel.ratingText}',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Card Body: Name, Distance from center, Review Count, Amenities, Price & CTAs
          Padding(
            padding: const EdgeInsets.all(AppSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hotel.name,
                  style: AppTypography.title.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${hotel.city} • ${hotel.distanceFromCenter} km from center • ${hotel.reviewCount} reviews',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.sm),
                Wrap(
                  spacing: AppSpace.xs,
                  runSpacing: AppSpace.xs,
                  children: hotel.amenities.take(4).map((amenity) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted(context),
                        borderRadius: AppRadius.smBorder,
                      ),
                      child: Text(
                        amenity,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpace.md),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpace.sm,
                    runSpacing: AppSpace.sm,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '\$$priceUsd',
                            style: AppTypography.display.copyWith(
                              color: AppColors.primary(context),
                            ),
                          ),
                          Text(
                            'per night • ${hotel.priceRange}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: AppSpace.xs,
                        runSpacing: AppSpace.xs,
                        children: [
                          AppButton(
                            label: 'Show Prices',
                            variant: AppButtonVariant.secondary,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      HotelDetailScreen(hotel: hotel),
                                ),
                              );
                            },
                          ),
                          AppButton(
                            label: 'Book Now',
                            icon: Icons.bolt_rounded,
                            onPressed: () =>
                                _showBookingSheet(context, hotel, priceUsd),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingSheet(
    BuildContext context,
    booking_data.Hotel hotel,
    int priceUsd,
  ) {
    DateTime checkIn = DateTime.now().add(const Duration(days: 1));
    DateTime checkOut = DateTime.now().add(const Duration(days: 3));
    int guests = 2;
    int rooms = 1;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final nights = checkOut.difference(checkIn).inDays.clamp(1, 30);
            final total = priceUsd * nights * rooms;

            return Padding(
              padding: EdgeInsets.only(
                top: AppSpace.xl,
                left: AppSpace.xl,
                right: AppSpace.xl,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpace.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Book ${hotel.name}',
                    style: AppTypography.title.copyWith(
                      color: AppColors.textPrimary(ctx),
                    ),
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(
                    '${hotel.city} • ${hotel.rating} ${hotel.ratingText} • \$$priceUsd per night',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary(ctx),
                    ),
                  ),
                  const SizedBox(height: AppSpace.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppCard(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Guests: $guests',
                                style: AppTypography.subtitle.copyWith(
                                  color: AppColors.textPrimary(ctx),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: guests > 1
                                        ? () => setModalState(() => guests--)
                                        : null,
                                    icon: const Icon(
                                      Icons.remove_circle_outline_rounded,
                                      size: 20,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        setModalState(() => guests++),
                                    icon: const Icon(
                                      Icons.add_circle_outline_rounded,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpace.sm),
                      Expanded(
                        child: AppCard(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rooms: $rooms',
                                style: AppTypography.subtitle.copyWith(
                                  color: AppColors.textPrimary(ctx),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: rooms > 1
                                        ? () => setModalState(() => rooms--)
                                        : null,
                                    icon: const Icon(
                                      Icons.remove_circle_outline_rounded,
                                      size: 20,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        setModalState(() => rooms++),
                                    icon: const Icon(
                                      Icons.add_circle_outline_rounded,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.md),
                  AppCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$nights Nights • $rooms Room(s)',
                          style: AppTypography.subtitle.copyWith(
                            color: AppColors.textSecondary(ctx),
                          ),
                        ),
                        Text(
                          'Total: \$$total',
                          style: AppTypography.title.copyWith(
                            color: AppColors.primary(ctx),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.lg),
                  AppButton(
                    label: 'Confirm Booking (\$$total)',
                    icon: Icons.check_circle_outline_rounded,
                    fullWidth: true,
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmBooking(
                        context,
                        hotel,
                        checkIn,
                        checkOut,
                        guests,
                        rooms,
                        total,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmBooking(
    BuildContext context,
    booking_data.Hotel hotel,
    DateTime checkIn,
    DateTime checkOut,
    int guests,
    int rooms,
    int total,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Booking Confirmed!'),
        content: Text(
          '${hotel.name} (${hotel.city})\n'
          '${checkIn.day}/${checkIn.month}/${checkIn.year} – ${checkOut.day}/${checkOut.month}/${checkOut.year}\n'
          '$guests Guests • $rooms Room(s)\n'
          'Total Paid: \$$total',
        ),
        actions: [
          AppButton(
            label: 'Done',
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }
}
