import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/hotels_data.dart';
import 'hotel_detail_screen.dart';

class HotelListScreen extends StatefulWidget {
  final String cityName;
  final LatLng? cityLocation;

  const HotelListScreen({super.key, required this.cityName, this.cityLocation});

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  late List<Hotel> hotels;
  String selectedFilter = 'All';
  bool showMap = true;
  final MapController _mapController = MapController();
  Hotel? selectedHotel;

  // Beach theme colors
  static const Color primaryColor = Color(0xFF87CEEB);
  static const Color secondaryColor = Color(0xFFFFD54F);
  static const Color backgroundColor = Color(0xFF0B111A);

  @override
  void initState() {
    super.initState();
    hotels = getHotelsForCity(widget.cityName);
    if (hotels.isEmpty) {
      // If no hotels found for specific city, show all hotels
      hotels = allHotels.take(10).toList();
    }
  }

  List<Hotel> get filteredHotels {
    if (selectedFilter == 'All') return hotels;
    if (selectedFilter == 'Top Rated') {
      return hotels.where((h) => h.rating >= 9.0).toList();
    }
    if (selectedFilter == 'Budget') {
      return hotels
          .where((h) => h.priceRange == '\$' || h.priceRange == '\$\$')
          .toList();
    }
    if (selectedFilter == 'Luxury') {
      return hotels.where((h) => h.priceRange.contains('\$\$\$')).toList();
    }
    return hotels;
  }

  LatLng get mapCenter {
    if (selectedHotel != null) return selectedHotel!.location;
    if (widget.cityLocation != null) return widget.cityLocation!;
    if (hotels.isNotEmpty) return hotels.first.location;
    return LatLng(7.8731, 80.7718); // Sri Lanka center
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          // App Bar with city name
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: primaryColor,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '${widget.cityName} Hotels',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    hotels.isNotEmpty
                        ? hotels.first.imageUrl
                        : 'https://images.pexels.com/photos/258154/pexels-photo-258154.jpeg?auto=compress&cs=tinysrgb&w=800',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: primaryColor,
                      child: const Icon(
                        Icons.hotel,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 60,
                    left: 16,
                    child: Row(
                      children: [
                        const Icon(Icons.hotel, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${hotels.length} properties found',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All'),
                        _buildFilterChip('Top Rated'),
                        _buildFilterChip('Budget'),
                        _buildFilterChip('Luxury'),
                        const SizedBox(width: 16),
                        // Map toggle
                        GestureDetector(
                          onTap: () => setState(() => showMap = !showMap),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: showMap
                                  ? primaryColor
                                  : const Color(0xFF121B2A),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: primaryColor),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.map,
                                  size: 18,
                                  color: showMap ? Colors.white : primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Map',
                                  style: TextStyle(
                                    color: showMap
                                        ? Colors.white
                                        : primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Map section
          if (showMap)
            SliverToBoxAdapter(
              child: Container(
                height: 250,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: mapCenter,
                        initialZoom: 13,
                        onTap: (_, __) => setState(() => selectedHotel = null),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.smartcity.app',
                        ),
                        MarkerLayer(
                          markers: filteredHotels.map((hotel) {
                            final isSelected = selectedHotel == hotel;
                            return Marker(
                              point: hotel.location,
                              width: isSelected ? 120 : 40,
                              height: isSelected ? 60 : 40,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => selectedHotel = hotel);
                                  _mapController.move(hotel.location, 15);
                                },
                                child: isSelected
                                    ? _buildSelectedMarker(hotel)
                                    : _buildHotelMarker(hotel),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    // Map legend
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121B2A),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Hotels',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFFEAF1FF),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Selected hotel info
                    if (selectedHotel != null)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    HotelDetailScreen(hotel: selectedHotel!),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF121B2A),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    selectedHotel!.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              width: 60,
                                              height: 60,
                                              color: Colors.grey[200],
                                              child: const Icon(Icons.hotel),
                                            ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedHotel!.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getRatingColor(
                                                selectedHotel!.rating,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              selectedHotel!.rating.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            selectedHotel!.ratingText,
                                            style: TextStyle(
                                              color: const Color(0xFFB8C1D1),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // Results count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '${filteredHotels.length} hotels available',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEAF1FF),
                ),
              ),
            ),
          ),

          // Hotel list
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final hotel = filteredHotels[index];
              return _buildHotelCard(hotel);
            }, childCount: filteredHotels.length),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => selectedFilter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? secondaryColor : const Color(0xFF121B2A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? secondaryColor : Colors.grey[300]!,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: secondaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFFB8C1D1),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHotelMarker(Hotel hotel) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: primaryColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(Icons.hotel, color: Colors.white, size: 16),
    );
  }

  Widget _buildSelectedMarker(Hotel hotel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.hotel, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              hotel.rating.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHotelCard(Hotel hotel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF18253B),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HotelDetailScreen(hotel: hotel)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Hotel image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Image.network(
                hotel.imageUrl,
                width: 130,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 130,
                  height: 150,
                  color: Colors.grey[200],
                  child: const Icon(Icons.hotel, size: 40, color: Colors.grey),
                ),
              ),
            ),
            // Hotel info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      hotel.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFFEAF1FF),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${hotel.distanceFromCenter} km from center',
                          style: TextStyle(
                            color: const Color(0xFFA4B2C7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Rating
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getRatingColor(hotel.rating),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            hotel.rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          hotel.ratingText,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFFD4DDF0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${hotel.reviewCount} reviews',
                      style: const TextStyle(
                        color: Color(0xFF9AA8BF),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Price and button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          hotel.priceRange,
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Show prices',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
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
      ),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 9.0) return const Color(0xFF003B95);
    if (rating >= 8.0) return const Color(0xFF003B95).withValues(alpha: 0.85);
    if (rating >= 7.0) return const Color(0xFF003B95).withValues(alpha: 0.7);
    return const Color(0xFF003B95).withValues(alpha: 0.55);
  }
}
