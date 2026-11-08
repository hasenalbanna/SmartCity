class Hotel {
  final String id;
  final String name;
  final String location;
  final String nearbyPlace;
  final double pricePerNight;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<String> amenities;
  final String description;
  final double latitude;
  final double longitude;
  final String category; // 'budget', 'mid-range', 'luxury', 'boutique'

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.nearbyPlace,
    required this.pricePerNight,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.amenities,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.category,
  });
}

class HotelBooking {
  final String id;
  final String hotelId;
  final String userId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final int rooms;
  final double totalAmount;
  final String status; // 'pending', 'confirmed', 'cancelled'
  final DateTime createdAt;

  HotelBooking({
    required this.id,
    required this.hotelId,
    required this.userId,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.rooms,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });
}
