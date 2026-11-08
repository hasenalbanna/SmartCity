import 'package:flutter/material.dart';
import '../models/hotel.dart';

class HotelBookingService extends ChangeNotifier {
  final List<HotelBooking> _bookings = [];

  List<HotelBooking> get bookings => _bookings;

  // Hotels near famous Sri Lanka destinations
  static final List<Hotel> hotels = [
    // Sigiriya Hotels
    Hotel(
      id: 'h1',
      name: 'Jetwing Vil Uyana',
      location: 'Sigiriya',
      nearbyPlace: 'Sigiriya Rock Fortress',
      pricePerNight: 250,
      rating: 4.8,
      reviewCount: 1250,
      imageUrl:
          'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400',
      amenities: ['Pool', 'Spa', 'Restaurant', 'WiFi', 'AC', 'Safari'],
      description: 'Luxury eco-resort with wetland villas surrounded by nature',
      latitude: 7.9570,
      longitude: 80.7603,
      category: 'luxury',
    ),
    Hotel(
      id: 'h2',
      name: 'Sigiriya Village Hotel',
      location: 'Sigiriya',
      nearbyPlace: 'Sigiriya Rock Fortress',
      pricePerNight: 85,
      rating: 4.3,
      reviewCount: 890,
      imageUrl:
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400',
      amenities: ['Pool', 'Restaurant', 'WiFi', 'AC', 'Garden'],
      description: 'Charming village-style accommodation with rock views',
      latitude: 7.9510,
      longitude: 80.7550,
      category: 'mid-range',
    ),

    // Kandy Hotels
    Hotel(
      id: 'h3',
      name: 'Earl\'s Regency Hotel',
      location: 'Kandy',
      nearbyPlace: 'Temple of the Tooth',
      pricePerNight: 120,
      rating: 4.5,
      reviewCount: 2100,
      imageUrl:
          'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400',
      amenities: ['Pool', 'Spa', 'Restaurant', 'WiFi', 'AC', 'Gym'],
      description: 'Hillside luxury with panoramic views of Kandy',
      latitude: 7.2906,
      longitude: 80.6337,
      category: 'luxury',
    ),
    Hotel(
      id: 'h4',
      name: 'Queens Hotel Kandy',
      location: 'Kandy',
      nearbyPlace: 'Temple of the Tooth',
      pricePerNight: 65,
      rating: 4.0,
      reviewCount: 1560,
      imageUrl:
          'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=400',
      amenities: ['Restaurant', 'WiFi', 'AC', 'Heritage'],
      description: 'Colonial heritage hotel next to the lake',
      latitude: 7.2934,
      longitude: 80.6350,
      category: 'mid-range',
    ),

    // Galle Hotels
    Hotel(
      id: 'h5',
      name: 'Amangalla',
      location: 'Galle Fort',
      nearbyPlace: 'Galle Fort',
      pricePerNight: 450,
      rating: 4.9,
      reviewCount: 780,
      imageUrl:
          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400',
      amenities: [
        'Pool',
        'Spa',
        'Restaurant',
        'WiFi',
        'AC',
        'Heritage',
        'Butler',
      ],
      description: 'Ultra-luxury within the historic Galle Fort walls',
      latitude: 6.0269,
      longitude: 80.2170,
      category: 'luxury',
    ),
    Hotel(
      id: 'h6',
      name: 'Fort Bazaar',
      location: 'Galle Fort',
      nearbyPlace: 'Galle Fort',
      pricePerNight: 180,
      rating: 4.6,
      reviewCount: 650,
      imageUrl:
          'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400',
      amenities: ['Restaurant', 'WiFi', 'AC', 'Heritage', 'Rooftop'],
      description: 'Boutique hotel in a restored merchant\'s house',
      latitude: 6.0275,
      longitude: 80.2165,
      category: 'boutique',
    ),

    // Ella Hotels
    Hotel(
      id: 'h7',
      name: '98 Acres Resort',
      location: 'Ella',
      nearbyPlace: 'Nine Arch Bridge',
      pricePerNight: 200,
      rating: 4.7,
      reviewCount: 1890,
      imageUrl:
          'https://images.unsplash.com/photo-1596394516093-501ba68a0ba6?w=400',
      amenities: ['Pool', 'Spa', 'Restaurant', 'WiFi', 'Views', 'Hiking'],
      description: 'Stunning tea estate views with infinity pool',
      latitude: 6.8667,
      longitude: 81.0466,
      category: 'luxury',
    ),
    Hotel(
      id: 'h8',
      name: 'Ella Flower Garden Resort',
      location: 'Ella',
      nearbyPlace: 'Nine Arch Bridge',
      pricePerNight: 45,
      rating: 4.4,
      reviewCount: 920,
      imageUrl:
          'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=400',
      amenities: ['Restaurant', 'WiFi', 'Garden', 'Views'],
      description: 'Budget-friendly with beautiful mountain views',
      latitude: 6.8700,
      longitude: 81.0500,
      category: 'budget',
    ),

    // Mirissa Hotels
    Hotel(
      id: 'h9',
      name: 'Mandara Resort',
      location: 'Mirissa',
      nearbyPlace: 'Mirissa Beach',
      pricePerNight: 150,
      rating: 4.5,
      reviewCount: 1100,
      imageUrl:
          'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400',
      amenities: ['Pool', 'Beach', 'Restaurant', 'WiFi', 'AC', 'Spa'],
      description: 'Beachfront luxury with whale watching tours',
      latitude: 5.9485,
      longitude: 80.4718,
      category: 'luxury',
    ),
    Hotel(
      id: 'h10',
      name: 'Paradise Beach Club',
      location: 'Mirissa',
      nearbyPlace: 'Mirissa Beach',
      pricePerNight: 55,
      rating: 4.2,
      reviewCount: 780,
      imageUrl:
          'https://images.unsplash.com/photo-1549294413-26f195200c16?w=400',
      amenities: ['Beach', 'Restaurant', 'WiFi', 'Surfing'],
      description: 'Right on the beach with surf lessons available',
      latitude: 5.9470,
      longitude: 80.4690,
      category: 'mid-range',
    ),

    // Yala Hotels
    Hotel(
      id: 'h11',
      name: 'Wild Coast Tented Lodge',
      location: 'Yala',
      nearbyPlace: 'Yala National Park',
      pricePerNight: 380,
      rating: 4.9,
      reviewCount: 450,
      imageUrl:
          'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400',
      amenities: ['Pool', 'Safari', 'Restaurant', 'WiFi', 'Luxury Tents'],
      description: 'Luxury glamping at the edge of Yala wilderness',
      latitude: 6.3698,
      longitude: 81.5046,
      category: 'luxury',
    ),
    Hotel(
      id: 'h12',
      name: 'Cinnamon Wild Yala',
      location: 'Yala',
      nearbyPlace: 'Yala National Park',
      pricePerNight: 180,
      rating: 4.4,
      reviewCount: 1200,
      imageUrl:
          'https://images.unsplash.com/photo-1568495248636-6432b97bd949?w=400',
      amenities: ['Pool', 'Safari', 'Restaurant', 'WiFi', 'AC'],
      description: 'Eco-lodge with regular leopard and elephant sightings',
      latitude: 6.3650,
      longitude: 81.4980,
      category: 'mid-range',
    ),
  ];

  // Get hotels near a specific place
  List<Hotel> getHotelsNearPlace(String placeName) {
    return hotels
        .where(
          (h) =>
              h.nearbyPlace.toLowerCase().contains(placeName.toLowerCase()) ||
              h.location.toLowerCase().contains(placeName.toLowerCase()),
        )
        .toList();
  }

  // Get all hotels
  List<Hotel> getAllHotels() {
    return hotels;
  }

  // Get hotels by category
  List<Hotel> getHotelsByCategory(String category) {
    return hotels.where((h) => h.category == category).toList();
  }

  // Get hotels by price range
  List<Hotel> getHotelsByPriceRange(double minPrice, double maxPrice) {
    return hotels
        .where(
          (h) => h.pricePerNight >= minPrice && h.pricePerNight <= maxPrice,
        )
        .toList();
  }

  // Create booking
  Future<HotelBooking> createBooking({
    required String hotelId,
    required String userId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required int rooms,
  }) async {
    final hotel = hotels.firstWhere((h) => h.id == hotelId);
    final nights = checkOut.difference(checkIn).inDays;
    final totalAmount = hotel.pricePerNight * rooms * nights;

    final booking = HotelBooking(
      id: 'hb_${DateTime.now().millisecondsSinceEpoch}',
      hotelId: hotelId,
      userId: userId,
      checkIn: checkIn,
      checkOut: checkOut,
      guests: guests,
      rooms: rooms,
      totalAmount: totalAmount,
      status: 'confirmed',
      createdAt: DateTime.now(),
    );

    _bookings.add(booking);
    notifyListeners();
    return booking;
  }

  // Get user bookings
  List<HotelBooking> getUserBookings(String userId) {
    return _bookings.where((b) => b.userId == userId).toList();
  }

  // Get hotel by ID
  Hotel? getHotelById(String hotelId) {
    try {
      return hotels.firstWhere((h) => h.id == hotelId);
    } catch (e) {
      return null;
    }
  }

  // Calculate commission (for monetization)
  double calculateCommission(double amount) {
    return amount * 0.12; // 12% commission
  }
}
