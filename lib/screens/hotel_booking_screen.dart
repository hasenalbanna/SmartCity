import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../services/hotel_booking_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/ui/ui.dart';

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

/// Reusable Hotel Finder & Booking view that can be displayed standalone or
/// embedded directly inside [ItineraryScreen].
class HotelBookingView extends StatefulWidget {
  final String? nearPlace;

  const HotelBookingView({super.key, this.nearPlace});

  @override
  State<HotelBookingView> createState() => _HotelBookingViewState();
}

class _HotelBookingViewState extends State<HotelBookingView> {
  final HotelBookingService _service = HotelBookingService();

  String _selectedLocation = 'All';
  RangeValues _priceRange = const RangeValues(0, 500);
  List<Hotel> _hotels = [];

  static const List<String> _locations = [
    'All',
    'Sigiriya',
    'Kandy',
    'Galle',
    'Ella',
    'Mirissa',
    'Yala',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.nearPlace != null) {
      _selectedLocation = widget.nearPlace!;
    }
    _filterHotels();
  }

  void _filterHotels() {
    List<Hotel> results;
    if (_selectedLocation != 'All') {
      results = _service.getHotelsNearPlace(_selectedLocation);
    } else {
      results = _service.getAllHotels();
    }

    results = results
        .where(
          (h) =>
              h.pricePerNight >= _priceRange.start &&
              h.pricePerNight <= _priceRange.end,
        )
        .toList();

    setState(() => _hotels = results);
  }

  String _localFallbackAsset(String location) {
    final loc = location.toLowerCase();
    if (loc.contains('sigiriya')) return 'assets/images/sigiriya.jpg';
    if (loc.contains('kandy')) {
      return 'assets/central province/temple of tooth.jpg';
    }
    if (loc.contains('galle')) return 'assets/southern province/galle fort.jpg';
    if (loc.contains('ella')) return 'assets/images/nine_arch_bridge.jpg';
    if (loc.contains('mirissa')) {
      return 'assets/southern province/mirissa beach.jpg';
    }
    if (loc.contains('yala')) return 'assets/images/yala_leopard.jpg';
    return 'assets/western province/galle-face.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero Header
        ClipRRect(
          borderRadius: AppRadius.lgBorder,
          child: SizedBox(
            height: 118,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/southern province/mirissa beach.jpg',
                  fit: BoxFit.cover,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.72),
                        Colors.black.withValues(alpha: 0.45),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpace.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Find Your Perfect Stay',
                        style: AppTypography.display.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_hotels.length} curated hotels & eco-resorts available',
                        style: AppTypography.body.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpace.lg),

        // Location Filter Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _locations.map((location) {
              final isSelected = _selectedLocation == location;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpace.sm),
                child: ChoiceChip(
                  selected: isSelected,
                  label: Text(location),
                  onSelected: (_) {
                    setState(() => _selectedLocation = location);
                    _filterHotels();
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpace.md),

        // Price Range Slider Card
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
                onChangeEnd: (_) => _filterHotels(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.lg),

        if (_hotels.isEmpty)
          const EmptyState(
            icon: Icons.hotel_outlined,
            title: 'No hotels match your filter',
            subtitle: 'Try widening the price range or selecting All cities.',
          )
        else
          ..._hotels.map(
            (hotel) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.lg),
              child: _buildHotelCard(context, hotel),
            ),
          ),
      ],
    );
  }

  Widget _buildHotelImage(Hotel hotel, {double height = 175}) {
    final fallbackAsset = _localFallbackAsset(hotel.location);
    return Image.network(
      hotel.imageUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        fallbackAsset,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildHotelCard(BuildContext context, Hotel hotel) {
    return AppCard(
      onTap: () => _showHotelDetails(context, hotel),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
                child: _buildHotelImage(hotel, height: 175),
              ),
              Positioned(
                top: AppSpace.md,
                left: AppSpace.md,
                child: StatusChip(
                  label: hotel.category,
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
                    color: Colors.black.withValues(alpha: 0.72),
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
                        hotel.rating.toStringAsFixed(1),
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
                    Text(
                      hotel.location,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary(context),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${hotel.pricePerNight.round()}',
                          style: AppTypography.display.copyWith(
                            color: AppColors.primary(context),
                          ),
                        ),
                        Text(
                          'per night',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                    AppButton(
                      label: 'Book Now',
                      icon: Icons.bolt_rounded,
                      onPressed: () => _showBookingSheet(context, hotel),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHotelDetails(BuildContext context, Hotel hotel) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        maxChildSize: 0.94,
        minChildSize: 0.5,
        builder: (_, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppSpace.xl),
          children: [
            ClipRRect(
              borderRadius: AppRadius.lgBorder,
              child: _buildHotelImage(hotel, height: 210),
            ),
            const SizedBox(height: AppSpace.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                    hotel.name,
                    style: AppTypography.display.copyWith(
                      color: AppColors.textPrimary(ctx),
                    ),
                  ),
                ),
                StatusChip(
                  label: '${hotel.rating} ★',
                  kind: StatusChipKind.resolved,
                ),
              ],
            ),
            const SizedBox(height: AppSpace.xs),
            Text(
              '${hotel.location} • Near ${hotel.nearbyPlace}',
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary(ctx),
              ),
            ),
            const SizedBox(height: AppSpace.md),
            Text(
              hotel.description,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary(ctx),
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            Text(
              'Amenities',
              style: AppTypography.title.copyWith(
                color: AppColors.textPrimary(ctx),
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            Wrap(
              spacing: AppSpace.sm,
              runSpacing: AppSpace.sm,
              children: hotel.amenities
                  .map(
                    (a) => StatusChip(
                      label: a,
                      kind: StatusChipKind.info,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: AppSpace.xl),
            AppButton(
              label: 'Book Stay (\$${hotel.pricePerNight.round()}/night)',
              icon: Icons.hotel_rounded,
              fullWidth: true,
              onPressed: () {
                Navigator.pop(ctx);
                _showBookingSheet(context, hotel);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingSheet(BuildContext context, Hotel hotel) {
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
            final total = hotel.pricePerNight * nights * rooms;

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
                    '${hotel.location} • \$${hotel.pricePerNight.round()} per night',
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
                          'Total: \$${total.round()}',
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
                    label: 'Confirm Booking (\$${total.round()})',
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
    Hotel hotel,
    DateTime checkIn,
    DateTime checkOut,
    int guests,
    int rooms,
    double total,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Booking Confirmed!'),
        content: Text(
          '${hotel.name} (${hotel.location})\n'
          '${checkIn.day}/${checkIn.month}/${checkIn.year} – ${checkOut.day}/${checkOut.month}/${checkOut.year}\n'
          '$guests Guests • $rooms Room(s)\n'
          'Total Paid: \$${total.round()}',
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
