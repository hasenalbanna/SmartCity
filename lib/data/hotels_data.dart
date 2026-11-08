import 'package:latlong2/latlong.dart';

class Hotel {
  final String id;
  final String name;
  final String city;
  final double rating;
  final String ratingText;
  final int reviewCount;
  final String description;
  final String imageUrl;
  final String priceRange;
  final double distanceFromCenter;
  final LatLng location;
  final List<String> amenities;
  final List<String> highlights;

  const Hotel({
    required this.id,
    required this.name,
    required this.city,
    required this.rating,
    required this.ratingText,
    required this.reviewCount,
    required this.description,
    required this.imageUrl,
    required this.priceRange,
    required this.distanceFromCenter,
    required this.location,
    required this.amenities,
    required this.highlights,
  });
}

// Hotels organized by city
final Map<String, List<Hotel>> hotelsByCity = {
  'Colombo': colomboHotels,
  'Kandy': kandyHotels,
  'Nuwara Eliya': nuwaraEliyaHotels,
  'Negombo': negomboHotels,
  'Ella': ellaHotels,
  'Galle': galleHotels,
  'Sigiriya': sigiriyaHotels,
  'Mirissa': mirissaHotels,
  'Trincomalee': trincomaleeHotels,
  'Arugam Bay': arugamBayHotels,
};

// Colombo Hotels
final List<Hotel> colomboHotels = [
  Hotel(
    id: 'col_1',
    name: 'Granbell Hotel Colombo',
    city: 'Colombo',
    rating: 8.7,
    ratingText: 'Excellent',
    reviewCount: 1245,
    description:
        'A few steps from Kalutara beach, Granbell Hotel Colombo has accommodation with free private parking, a fitness center and a terrace.',
    imageUrl:
        'https://images.pexels.com/photos/258154/pexels-photo-258154.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 2.4,
    location: LatLng(6.9271, 79.8612),
    amenities: ['Free WiFi', 'Pool', 'Fitness Center', 'Restaurant', 'Parking'],
    highlights: ['Beachfront', 'Rooftop Bar', 'Spa Services'],
  ),
  Hotel(
    id: 'col_2',
    name: 'Cinnamon Life at City of Dreams',
    city: 'Colombo',
    rating: 9.0,
    ratingText: 'Wonderful',
    reviewCount: 3771,
    description:
        'Located in Colombo, a 8-minute walk from Galle Face Beach, Cinnamon Life at City of Dreams has accommodation with an outdoor swimming pool, free private parking and a bar.',
    imageUrl:
        'https://images.pexels.com/photos/261102/pexels-photo-261102.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$\$',
    distanceFromCenter: 1.1,
    location: LatLng(6.9344, 79.8428),
    amenities: [
      'Free WiFi',
      'Pool',
      'Spa',
      'Restaurant',
      'Bar',
      'Room Service',
    ],
    highlights: ['5-Star Luxury', 'Ocean View', 'Multiple Restaurants'],
  ),
  Hotel(
    id: 'col_3',
    name: 'Cinnamon Lakeside',
    city: 'Colombo',
    rating: 8.2,
    ratingText: 'Very Good',
    reviewCount: 1538,
    description:
        'Cinnamon Lakeside is located along the banks of Beira Lake in Colombo, 10 minutes drive from Crescat Boulevard shopping mall. It features 9 dining options and a full-service health club.',
    imageUrl:
        'https://images.pexels.com/photos/189296/pexels-photo-189296.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 0.7,
    location: LatLng(6.9320, 79.8476),
    amenities: ['Free WiFi', 'Pool', 'Spa', 'Restaurant', 'Fitness Center'],
    highlights: ['Lake View', 'Multiple Dining', 'Business Center'],
  ),
  Hotel(
    id: 'col_4',
    name: 'Marino Beach Colombo',
    city: 'Colombo',
    rating: 9.2,
    ratingText: 'Wonderful',
    reviewCount: 10005,
    description:
        'Located in Colombo, a few steps from Bambalapitiya Beach, Marino Beach Colombo has accommodation with an outdoor swimming pool, free private parking, a fitness center and a garden.',
    imageUrl:
        'https://images.pexels.com/photos/1134176/pexels-photo-1134176.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$\$',
    distanceFromCenter: 3.6,
    location: LatLng(6.8867, 79.8567),
    amenities: ['Free WiFi', 'Pool', 'Beach Access', 'Restaurant', 'Spa'],
    highlights: ['Beachfront', 'Infinity Pool', 'Sunset Views'],
  ),
  Hotel(
    id: 'col_5',
    name: 'Colombo Trizen Luxury Apartments',
    city: 'Colombo',
    rating: 8.8,
    ratingText: 'Excellent',
    reviewCount: 892,
    description:
        'Colombo Trizen Luxury Apartments, Sri Lanka offers air-conditioned accommodation in Colombo. Featuring lake and pool views, this apartment also comes with free WiFi.',
    imageUrl:
        'https://images.pexels.com/photos/164595/pexels-photo-164595.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 1.2,
    location: LatLng(6.9289, 79.8456),
    amenities: ['Free WiFi', 'Pool', 'Kitchen', 'Air Conditioning', 'Balcony'],
    highlights: ['Lake View', 'Self Catering', 'Modern Design'],
  ),
  Hotel(
    id: 'col_6',
    name: 'Tri-Zen Apartment Tower 02',
    city: 'Colombo',
    rating: 8.5,
    ratingText: 'Very Good',
    reviewCount: 654,
    description:
        'Just 1.2 miles from Galle Face Beach and a 7-minute walk from Colombo City Centre Shopping Mall, Tri-Zen Apartment features accommodation in Colombo with an outdoor swimming pool.',
    imageUrl:
        'https://images.pexels.com/photos/271624/pexels-photo-271624.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 2.1,
    location: LatLng(6.9256, 79.8489),
    amenities: ['Free WiFi', 'Pool', 'Gym', 'Security', 'Parking'],
    highlights: ['City View', 'Modern Amenities', 'Family Friendly'],
  ),
];

// Kandy Hotels
final List<Hotel> kandyHotels = [
  Hotel(
    id: 'kan_1',
    name: 'Kandy Myst by Cinnamon',
    city: 'Kandy',
    rating: 9.0,
    ratingText: 'Wonderful',
    reviewCount: 359,
    description:
        'Located in Kandy, 1.8 miles from Kandy City Centre Shopping Mall, Kandy Myst by Cinnamon provides accommodation with an outdoor swimming pool, free private parking, a garden and a terrace.',
    imageUrl:
        'https://images.pexels.com/photos/338504/pexels-photo-338504.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$\$',
    distanceFromCenter: 2.3,
    location: LatLng(7.2906, 80.6337),
    amenities: ['Free WiFi', 'Pool', 'Garden', 'Restaurant', 'Spa'],
    highlights: ['Mountain View', 'Luxury Retreat', 'Nature Surroundings'],
  ),
  Hotel(
    id: 'kan_2',
    name: 'Cinnamon Citadel Kandy',
    city: 'Kandy',
    rating: 8.5,
    ratingText: 'Very Good',
    reviewCount: 724,
    description:
        'Located 500 feet above sea level, Cinnamon Citadel Kandy offers a spectacular outdoor pool.',
    imageUrl:
        'https://images.pexels.com/photos/261395/pexels-photo-261395.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 1.9,
    location: LatLng(7.2875, 80.6456),
    amenities: ['Free WiFi', 'Pool', 'Restaurant', 'Bar', 'Room Service'],
    highlights: ['River View', 'Infinity Pool', 'Cultural Shows'],
  ),
  Hotel(
    id: 'kan_3',
    name: '360 Viewpoint by Queens Mount',
    city: 'Kandy',
    rating: 7.7,
    ratingText: 'Good',
    reviewCount: 523,
    description:
        'Well situated in the center of Kandy, 360 Viewpoint by Queens Mount has air-conditioned rooms with free WiFi, free private parking and room service.',
    imageUrl:
        'https://images.pexels.com/photos/2034335/pexels-photo-2034335.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 0.7,
    location: LatLng(7.2945, 80.6367),
    amenities: ['Free WiFi', 'Parking', 'Room Service', 'Air Conditioning'],
    highlights: ['360° View', 'Central Location', 'Budget Friendly'],
  ),
  Hotel(
    id: 'kan_4',
    name: 'Hotel Travellers Nest Kandy',
    city: 'Kandy',
    rating: 7.3,
    ratingText: 'Good',
    reviewCount: 412,
    description:
        'Attractively set in Kandy, Hotel Travellers Nest Kandy has air-conditioned rooms with free WiFi, free private parking and room service.',
    imageUrl:
        'https://images.pexels.com/photos/1579253/pexels-photo-1579253.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 1.4,
    location: LatLng(7.2923, 80.6312),
    amenities: ['Free WiFi', 'Parking', 'Air Conditioning', 'Restaurant'],
    highlights: ['Cozy Atmosphere', 'Local Food', 'Helpful Staff'],
  ),
  Hotel(
    id: 'kan_5',
    name: 'Hotel Suisse Kandy - Since 1890',
    city: 'Kandy',
    rating: 8.8,
    ratingText: 'Excellent',
    reviewCount: 856,
    description:
        'Suisse is housed in a colonial building, across Kandy Lake. Offering rooms with views of the tropical grounds or Kandy Lake, it has a spa, a restaurant and free parking.',
    imageUrl:
        'https://images.pexels.com/photos/2467285/pexels-photo-2467285.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 1.0,
    location: LatLng(7.2912, 80.6395),
    amenities: ['Free WiFi', 'Spa', 'Restaurant', 'Parking', 'Lake View'],
    highlights: ['Historic Building', 'Lake View', 'Colonial Charm'],
  ),
  Hotel(
    id: 'kan_6',
    name: 'Hotel Cassandra',
    city: 'Kandy',
    rating: 8.2,
    ratingText: 'Very Good',
    reviewCount: 1215,
    description:
        'Attractively located in the center of Kandy, Hotel Cassandra has air-conditioned rooms with free WiFi, free private parking and room service. This 4-star hotel offers a terrace.',
    imageUrl:
        'https://images.pexels.com/photos/1743231/pexels-photo-1743231.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 1.1,
    location: LatLng(7.2889, 80.6378),
    amenities: [
      'Free WiFi',
      'Parking',
      'Restaurant',
      'Room Service',
      'Terrace',
    ],
    highlights: ['Central Location', '4-Star Service', 'City Views'],
  ),
];

// Nuwara Eliya Hotels
final List<Hotel> nuwaraEliyaHotels = [
  Hotel(
    id: 'nuw_1',
    name: 'Serene Max Bungalow',
    city: 'Nuwara Eliya',
    rating: 9.4,
    ratingText: 'Wonderful',
    reviewCount: 287,
    description:
        'Featuring garden views, Serene Max Bungalow in Nuwara Eliya provides accommodation and a garden. This bed and breakfast features free private parking, a shared kitchen, and free WiFi.',
    imageUrl:
        'https://images.pexels.com/photos/803975/pexels-photo-803975.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 1.7,
    location: LatLng(6.9697, 80.7893),
    amenities: ['Free WiFi', 'Garden', 'Kitchen', 'Parking', 'Mountain View'],
    highlights: ['Peaceful Setting', 'Home Cooking', 'Nature Walks'],
  ),
  Hotel(
    id: 'nuw_2',
    name: 'The Montfort Nuwaraeliya',
    city: 'Nuwara Eliya',
    rating: 8.3,
    ratingText: 'Very Good',
    reviewCount: 562,
    description:
        'Offering mountain views, The Montfort Nuwaraeliya in Nuwara Eliya provides accommodation, a garden, and barbecue facilities.',
    imageUrl:
        'https://images.pexels.com/photos/2096983/pexels-photo-2096983.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 2.1,
    location: LatLng(6.9712, 80.7856),
    amenities: ['Free WiFi', 'Garden', 'BBQ', 'Mountain View', 'Fireplace'],
    highlights: ['Scenic Views', 'BBQ Facilities', 'Cozy Rooms'],
  ),
  Hotel(
    id: 'nuw_3',
    name: 'The Golden Ridge Hotel',
    city: 'Nuwara Eliya',
    rating: 9.2,
    ratingText: 'Wonderful',
    reviewCount: 423,
    description:
        'Set among the scenic landscape of the tea plantations, 1.2 mi from Nuwara Eliya city, and the property is equipped with a heated indoor swimming pool along with a picturesque view of Bambarakelle Mountain.',
    imageUrl:
        'https://images.pexels.com/photos/261043/pexels-photo-261043.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$\$',
    distanceFromCenter: 3.4,
    location: LatLng(6.9534, 80.7912),
    amenities: ['Pool', 'Restaurant', 'Spa', 'Free WiFi', 'Heating'],
    highlights: ['Tea Plantation Views', 'Heated Pool', 'Luxury Stay'],
  ),
  Hotel(
    id: 'nuw_4',
    name: 'Twin Villa Red - Luxury Villa',
    city: 'Nuwara Eliya',
    rating: 9.0,
    ratingText: 'Wonderful',
    reviewCount: 198,
    description:
        'Located in Nuwara Eliya, 2.8 miles from Gregory Lake, Twin Villa Red - Luxury Villa with Mountain View has accommodation with a garden, free private parking, a shared lounge and a terrace.',
    imageUrl:
        'https://images.pexels.com/photos/2373201/pexels-photo-2373201.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$\$',
    distanceFromCenter: 1.0,
    location: LatLng(6.9678, 80.7834),
    amenities: ['Free WiFi', 'Garden', 'Terrace', 'Mountain View', 'Lounge'],
    highlights: ['Mountain View', 'Private Villa', 'Luxury Experience'],
  ),
  Hotel(
    id: 'nuw_5',
    name: 'Winchester Little England',
    city: 'Nuwara Eliya',
    rating: 8.1,
    ratingText: 'Excellent',
    reviewCount: 312,
    description:
        'Located in Nuwara Eliya, 1.8 miles from Gregory Lake, Winchester Little England has accommodation with a garden, free private parking, a terrace and a restaurant.',
    imageUrl:
        'https://images.pexels.com/photos/1001965/pexels-photo-1001965.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 1.4,
    location: LatLng(6.9689, 80.7867),
    amenities: ['Free WiFi', 'Restaurant', 'Garden', 'Parking', 'Terrace'],
    highlights: ['Colonial Style', 'English Garden', 'Fine Dining'],
  ),
  Hotel(
    id: 'nuw_6',
    name: 'La Grande Villa',
    city: 'Nuwara Eliya',
    rating: 9.1,
    ratingText: 'Wonderful',
    reviewCount: 1065,
    description:
        '5.5 miles from Hakgala Botanical Garden in Nuwara Eliya, La Grande Villa provides accommodation with access to a hot tub.',
    imageUrl:
        'https://images.pexels.com/photos/2360673/pexels-photo-2360673.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$\$',
    distanceFromCenter: 3.2,
    location: LatLng(6.9523, 80.7878),
    amenities: ['Hot Tub', 'Free WiFi', 'Garden', 'Mountain View', 'Fireplace'],
    highlights: ['Hot Tub', 'Panoramic Views', 'Romantic Getaway'],
  ),
];

// Negombo Hotels
final List<Hotel> negomboHotels = [
  Hotel(
    id: 'neg_1',
    name: 'Negombo Ocean Breeze - Bliss on the Beach',
    city: 'Negombo',
    rating: 8.7,
    ratingText: 'Excellent',
    reviewCount: 743,
    description:
        'A few steps from Negombo Beach in Negombo, Negombo Ocean Breeze - Bliss on the Beach Luxury Apartments by Serendib Vacation provides accommodation with access to a fitness center.',
    imageUrl:
        'https://images.pexels.com/photos/1450363/pexels-photo-1450363.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 0.8,
    location: LatLng(7.2094, 79.8358),
    amenities: [
      'Beach Access',
      'Fitness Center',
      'Free WiFi',
      'Pool',
      'Restaurant',
    ],
    highlights: ['Beachfront', 'Ocean Views', 'Luxury Apartments'],
  ),
  Hotel(
    id: 'neg_2',
    name: 'The Galaxy Airport Hotel',
    city: 'Negombo',
    rating: 9.0,
    ratingText: 'Wonderful',
    reviewCount: 456,
    description:
        "Located in Negombo, 3.5 miles from St. Anthony's Church, The Galaxy Airport Hotel provides accommodation with free WiFi and free private parking.",
    imageUrl:
        'https://images.pexels.com/photos/2096983/pexels-photo-2096983.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 1.7,
    location: LatLng(7.1756, 79.8745),
    amenities: ['Free WiFi', 'Airport Shuttle', 'Parking', 'Restaurant', 'Bar'],
    highlights: ['Near Airport', 'Free Shuttle', 'Convenient Location'],
  ),
  Hotel(
    id: 'neg_3',
    name: 'The Lighthouse Negombo',
    city: 'Negombo',
    rating: 8.1,
    ratingText: 'Very Good',
    reviewCount: 234,
    description:
        "The Lighthouse Negombo offers a hot tub and a fitness room, as well as air-conditioned accommodation in Negombo, 0.1 miles from St. Anthony's Church.",
    imageUrl:
        'https://images.pexels.com/photos/261394/pexels-photo-261394.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 0.5,
    location: LatLng(7.2123, 79.8312),
    amenities: ['Hot Tub', 'Fitness Room', 'Free WiFi', 'Beachfront', 'Bar'],
    highlights: ['Hot Tub', 'Beach Location', 'Relaxing Atmosphere'],
  ),
  Hotel(
    id: 'neg_4',
    name: 'West Nest Bohemian',
    city: 'Negombo',
    rating: 8.8,
    ratingText: 'Excellent',
    reviewCount: 521,
    description:
        "Located in Negombo, 2.8 miles from St. Anthony's Church, West Nest Bohemian provides accommodation with a garden, free private parking and a restaurant.",
    imageUrl:
        'https://images.pexels.com/photos/1268871/pexels-photo-1268871.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 4.9,
    location: LatLng(7.2234, 79.8234),
    amenities: ['Garden', 'Restaurant', 'Parking', 'Free WiFi', 'Pool'],
    highlights: ['Bohemian Style', 'Art Decor', 'Unique Experience'],
  ),
  Hotel(
    id: 'neg_5',
    name: 'Golden Star Beach Hotel',
    city: 'Negombo',
    rating: 6.8,
    ratingText: 'Pleasant',
    reviewCount: 312,
    description:
        'Golden Star Beach Hotel faces just the charm of Dutch Canal and Negombo Lagoon, and is a 5-minute drive from Bandaranaike International Airport. It offers an outdoor pool and free Wi-Fi.',
    imageUrl:
        'https://images.pexels.com/photos/261096/pexels-photo-261096.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 1.0,
    location: LatLng(7.2056, 79.8398),
    amenities: ['Pool', 'Free WiFi', 'Restaurant', 'Bar', 'Beach Access'],
    highlights: ['Budget Friendly', 'Beach Access', 'Near Airport'],
  ),
  Hotel(
    id: 'neg_6',
    name: 'Hive 68 Hotel and Resorts - Negombo',
    city: 'Negombo',
    rating: 8.4,
    ratingText: 'Very Good',
    reviewCount: 1458,
    description:
        'A 30-minute walk from Wellaweediya Beach, Hive 68 Hotel and Resorts - Negombo has accommodation with a garden, free private parking, a terrace and a restaurant.',
    imageUrl:
        'https://images.pexels.com/photos/2507010/pexels-photo-2507010.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 3.0,
    location: LatLng(7.1989, 79.8467),
    amenities: ['Garden', 'Restaurant', 'Parking', 'Terrace', 'Free WiFi'],
    highlights: ['Modern Design', 'Great Value', 'Family Friendly'],
  ),
];

// Ella Hotels
final List<Hotel> ellaHotels = [
  Hotel(
    id: 'ell_1',
    name: 'The Chillout Ella',
    city: 'Ella',
    rating: 9.2,
    ratingText: 'Wonderful',
    reviewCount: 678,
    description:
        'Overlooking lush green mountains, The Chillout Ella offers tranquil and comfortable accommodation with an outdoor terrace for relaxation.',
    imageUrl:
        'https://images.pexels.com/photos/2373201/pexels-photo-2373201.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 0.6,
    location: LatLng(6.8667, 81.0467),
    amenities: [
      'Free WiFi',
      'Terrace',
      'Mountain View',
      'Restaurant',
      'Garden',
    ],
    highlights: ['Mountain Views', 'Peaceful', 'Great Location'],
  ),
  Hotel(
    id: 'ell_2',
    name: '90 Degrees Ella',
    city: 'Ella',
    rating: 8.8,
    ratingText: 'Excellent',
    reviewCount: 543,
    description:
        'Located in Ella, 2.7 miles from Demodara Nine Arch Bridge, 90 Degrees Ella provides accommodation with a garden, free private parking and a terrace.',
    imageUrl:
        'https://images.pexels.com/photos/2034335/pexels-photo-2034335.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 0.9,
    location: LatLng(6.8689, 81.0512),
    amenities: ['Garden', 'Parking', 'Terrace', 'Free WiFi', 'Restaurant'],
    highlights: ['Panoramic Views', 'Sunrise Spot', 'Friendly Staff'],
  ),
  Hotel(
    id: 'ell_3',
    name: 'Namara Green Ella',
    city: 'Ella',
    rating: 8.5,
    ratingText: 'Very Good',
    reviewCount: 489,
    description:
        'Namara Green Ella enjoys a location in Ella, 10 miles from Hakgala Botanical Garden and 30 miles from Horton Plains National Park.',
    imageUrl:
        'https://images.pexels.com/photos/261043/pexels-photo-261043.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 1.1,
    location: LatLng(6.8712, 81.0489),
    amenities: [
      'Free WiFi',
      'Garden',
      'Parking',
      'Restaurant',
      'Mountain View',
    ],
    highlights: ['Eco-Friendly', 'Nature Setting', 'Trekking Base'],
  ),
  Hotel(
    id: 'ell_4',
    name: 'Ella Heritage',
    city: 'Ella',
    rating: 8.1,
    ratingText: 'Very Good',
    reviewCount: 367,
    description:
        'Just 1.3 miles from Demodara Nine Arch Bridge and a 10-minute walk from Ella Spice Garden Cooking Class, Ella Heritage features accommodation in Ella, with a garden and a shared lounge.',
    imageUrl:
        'https://images.pexels.com/photos/803975/pexels-photo-803975.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 0.4,
    location: LatLng(6.8656, 81.0445),
    amenities: [
      'Garden',
      'Shared Lounge',
      'Free WiFi',
      'Parking',
      'Restaurant',
    ],
    highlights: ['Heritage Style', 'Central Location', 'Cooking Classes'],
  ),
  Hotel(
    id: 'ell_5',
    name: 'Heart of Ella',
    city: 'Ella',
    rating: 7.9,
    ratingText: 'Good',
    reviewCount: 234,
    description:
        'Located in Ella, 0.5 miles from Demodara Nine Arch Bridge, Heart of Ella has accommodation with a garden, free private parking, a terrace and a restaurant.',
    imageUrl:
        'https://images.pexels.com/photos/1001965/pexels-photo-1001965.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$',
    distanceFromCenter: 0.3,
    location: LatLng(6.8645, 81.0434),
    amenities: ['Garden', 'Parking', 'Terrace', 'Restaurant', 'Free WiFi'],
    highlights: ['Budget Friendly', 'Town Center', 'Great Food'],
  ),
  Hotel(
    id: 'ell_6',
    name: 'Tea Cabins Ella',
    city: 'Ella',
    rating: 9.5,
    ratingText: 'Exceptional',
    reviewCount: 645,
    description:
        'Providing garden views, Tea Cabins in Ella offers accommodation and a garden. The property offers access to a balcony, free private parking, and free WiFi.',
    imageUrl:
        'https://images.pexels.com/photos/2360673/pexels-photo-2360673.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 1.9,
    location: LatLng(6.8734, 81.0534),
    amenities: [
      'Garden',
      'Balcony',
      'Parking',
      'Free WiFi',
      'Tea Plantation Views',
    ],
    highlights: ['Unique Cabins', 'Tea Estate', 'Instagram Worthy'],
  ),
];

// Galle Hotels
final List<Hotel> galleHotels = [
  Hotel(
    id: 'gal_1',
    name: 'Jetwing Lighthouse',
    city: 'Galle',
    rating: 9.1,
    ratingText: 'Wonderful',
    reviewCount: 1234,
    description:
        'Perched on a rocky outcrop overlooking the Indian Ocean, Jetwing Lighthouse is a 5-star luxury hotel designed by renowned architect Geoffrey Bawa.',
    imageUrl:
        'https://images.pexels.com/photos/258154/pexels-photo-258154.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$\$',
    distanceFromCenter: 2.5,
    location: LatLng(6.0243, 80.2119),
    amenities: ['Pool', 'Spa', 'Restaurant', 'Beach Access', 'Free WiFi'],
    highlights: ['Geoffrey Bawa Design', 'Ocean Views', '5-Star Luxury'],
  ),
  Hotel(
    id: 'gal_2',
    name: 'Fort Bazaar',
    city: 'Galle',
    rating: 9.3,
    ratingText: 'Wonderful',
    reviewCount: 876,
    description:
        'Located within the historic Galle Fort, Fort Bazaar is a boutique hotel offering luxurious accommodation in a restored 17th-century merchant house.',
    imageUrl:
        'https://images.pexels.com/photos/261102/pexels-photo-261102.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$\$',
    distanceFromCenter: 0.3,
    location: LatLng(6.0268, 80.2167),
    amenities: ['Restaurant', 'Bar', 'Spa', 'Free WiFi', 'Concierge'],
    highlights: ['Inside Fort', 'Historic Building', 'Boutique Style'],
  ),
  Hotel(
    id: 'gal_3',
    name: 'The Fortress Resort & Spa',
    city: 'Galle',
    rating: 9.0,
    ratingText: 'Wonderful',
    reviewCount: 1567,
    description:
        'An all-suite beachfront resort with stunning ocean views, multiple dining options, and a world-class spa.',
    imageUrl:
        'https://images.pexels.com/photos/189296/pexels-photo-189296.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$\$',
    distanceFromCenter: 4.2,
    location: LatLng(6.0112, 80.2234),
    amenities: ['Beach', 'Pool', 'Spa', 'Restaurant', 'Gym'],
    highlights: ['Beachfront', 'All-Suite', 'Luxury Spa'],
  ),
  Hotel(
    id: 'gal_4',
    name: 'Amangalla',
    city: 'Galle',
    rating: 9.5,
    ratingText: 'Exceptional',
    reviewCount: 543,
    description:
        'Housed in the former Oriental Hotel from 1684, Amangalla combines colonial heritage with modern luxury inside the Galle Fort.',
    imageUrl:
        'https://images.pexels.com/photos/1134176/pexels-photo-1134176.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$\$\$',
    distanceFromCenter: 0.2,
    location: LatLng(6.0278, 80.2178),
    amenities: ['Pool', 'Spa', 'Restaurant', 'Library', 'Garden'],
    highlights: ['Historic Landmark', 'Ultra Luxury', 'Aman Brand'],
  ),
  Hotel(
    id: 'gal_5',
    name: 'Galle Fort Hotel',
    city: 'Galle',
    rating: 8.8,
    ratingText: 'Excellent',
    reviewCount: 678,
    description:
        'A beautifully restored 18th-century Dutch warehouse, now a stylish boutique hotel with rooftop dining.',
    imageUrl:
        'https://images.pexels.com/photos/164595/pexels-photo-164595.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 0.4,
    location: LatLng(6.0256, 80.2156),
    amenities: ['Restaurant', 'Rooftop Bar', 'Pool', 'Free WiFi', 'Spa'],
    highlights: ['Dutch Heritage', 'Rooftop Dining', 'Central Fort Location'],
  ),
  Hotel(
    id: 'gal_6',
    name: 'Unawatuna Beach Bungalow',
    city: 'Galle',
    rating: 8.5,
    ratingText: 'Very Good',
    reviewCount: 456,
    description:
        'Steps away from Unawatuna Beach, this cozy bungalow offers direct beach access and stunning sunset views.',
    imageUrl:
        'https://images.pexels.com/photos/271624/pexels-photo-271624.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 5.8,
    location: LatLng(6.0098, 80.2489),
    amenities: ['Beach Access', 'Restaurant', 'Free WiFi', 'Garden'],
    highlights: ['Beach Steps Away', 'Sunset Views', 'Relaxed Vibe'],
  ),
];

// Sigiriya Hotels
final List<Hotel> sigiriyaHotels = [
  Hotel(
    id: 'sig_1',
    name: 'Jetwing Vil Uyana',
    city: 'Sigiriya',
    rating: 9.4,
    ratingText: 'Wonderful',
    reviewCount: 892,
    description:
        'A luxury eco resort set within a reconstructed wetland featuring dwellings on stilts, surrounded by paddy fields and forests with Sigiriya Rock views.',
    imageUrl:
        'https://images.pexels.com/photos/338504/pexels-photo-338504.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$\$',
    distanceFromCenter: 3.5,
    location: LatLng(7.9523, 80.7534),
    amenities: ['Pool', 'Spa', 'Restaurant', 'Bird Watching', 'Cycling'],
    highlights: ['Eco Resort', 'Wetland Setting', 'Sigiriya Views'],
  ),
  Hotel(
    id: 'sig_2',
    name: 'Aliya Resort & Spa',
    city: 'Sigiriya',
    rating: 9.0,
    ratingText: 'Wonderful',
    reviewCount: 1234,
    description:
        'Designed in the shape of an elephant, this unique resort offers stunning views of Sigiriya Rock and surrounding wilderness.',
    imageUrl:
        'https://images.pexels.com/photos/261395/pexels-photo-261395.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 2.8,
    location: LatLng(7.9456, 80.7612),
    amenities: ['Pool', 'Spa', 'Restaurant', 'Bar', 'Gym'],
    highlights: ['Elephant Shaped', 'Rock Views', 'Infinity Pool'],
  ),
  Hotel(
    id: 'sig_3',
    name: 'Water Garden Sigiriya',
    city: 'Sigiriya',
    rating: 9.2,
    ratingText: 'Wonderful',
    reviewCount: 756,
    description:
        'A boutique hotel inspired by ancient water gardens of Sigiriya, featuring villas with private plunge pools.',
    imageUrl:
        'https://images.pexels.com/photos/2034335/pexels-photo-2034335.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$\$',
    distanceFromCenter: 4.2,
    location: LatLng(7.9378, 80.7489),
    amenities: ['Private Pool', 'Spa', 'Restaurant', 'Garden', 'Cycling'],
    highlights: ['Private Villas', 'Ancient Inspiration', 'Serene Setting'],
  ),
  Hotel(
    id: 'sig_4',
    name: 'Sigiriya Village Hotel',
    city: 'Sigiriya',
    rating: 8.6,
    ratingText: 'Excellent',
    reviewCount: 567,
    description:
        'Set in lush gardens with views of Sigiriya Rock, this hotel offers traditional Sri Lankan hospitality and Ayurveda treatments.',
    imageUrl:
        'https://images.pexels.com/photos/1579253/pexels-photo-1579253.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 1.5,
    location: LatLng(7.9567, 80.7523),
    amenities: ['Pool', 'Ayurveda', 'Restaurant', 'Garden', 'Free WiFi'],
    highlights: ['Traditional Style', 'Ayurveda', 'Garden Setting'],
  ),
  Hotel(
    id: 'sig_5',
    name: 'Rock Villa Sigiriya',
    city: 'Sigiriya',
    rating: 8.9,
    ratingText: 'Excellent',
    reviewCount: 345,
    description:
        'Boutique villa accommodation with spectacular views of Sigiriya Rock, perfect for couples and small groups.',
    imageUrl:
        'https://images.pexels.com/photos/2467285/pexels-photo-2467285.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 2.1,
    location: LatLng(7.9489, 80.7578),
    amenities: ['Pool', 'Restaurant', 'Garden', 'Rock Views', 'Free WiFi'],
    highlights: ['Boutique Villa', 'Rock Views', 'Romantic'],
  ),
  Hotel(
    id: 'sig_6',
    name: 'Fresco Water Villa',
    city: 'Sigiriya',
    rating: 9.1,
    ratingText: 'Wonderful',
    reviewCount: 423,
    description:
        'Unique villa over water with glass floor sections, offering views of Sigiriya Rock and surrounding paddy fields.',
    imageUrl:
        'https://images.pexels.com/photos/1743231/pexels-photo-1743231.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$\$',
    distanceFromCenter: 3.8,
    location: LatLng(7.9412, 80.7456),
    amenities: ['Pool', 'Restaurant', 'Spa', 'Glass Floor', 'Garden'],
    highlights: ['Water Villa', 'Glass Floor', 'Unique Experience'],
  ),
];

// Mirissa Hotels
final List<Hotel> mirissaHotels = [
  Hotel(
    id: 'mir_1',
    name: 'Mandara Resort',
    city: 'Mirissa',
    rating: 9.0,
    ratingText: 'Wonderful',
    reviewCount: 678,
    description:
        'Perched on a clifftop with panoramic ocean views, Mandara Resort offers luxury accommodation with infinity pool overlooking Mirissa Bay.',
    imageUrl:
        'https://images.pexels.com/photos/1450363/pexels-photo-1450363.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 1.2,
    location: LatLng(5.9456, 80.4567),
    amenities: ['Infinity Pool', 'Spa', 'Restaurant', 'Ocean View', 'Bar'],
    highlights: ['Clifftop Location', 'Ocean Views', 'Whale Watching'],
  ),
  Hotel(
    id: 'mir_2',
    name: 'Paradise Beach Club',
    city: 'Mirissa',
    rating: 8.5,
    ratingText: 'Very Good',
    reviewCount: 543,
    description:
        'Steps from Mirissa Beach, this resort offers beachfront accommodation with pool, restaurant, and direct ocean access.',
    imageUrl:
        'https://images.pexels.com/photos/261394/pexels-photo-261394.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 0.5,
    location: LatLng(5.9478, 80.4523),
    amenities: ['Beach Access', 'Pool', 'Restaurant', 'Bar', 'Free WiFi'],
    highlights: ['Beachfront', 'Budget Friendly', 'Party Vibe'],
  ),
  Hotel(
    id: 'mir_3',
    name: 'The Owl and the Pussycat Hotel',
    city: 'Mirissa',
    rating: 9.2,
    ratingText: 'Wonderful',
    reviewCount: 456,
    description:
        'A boutique hotel with stunning ocean views, named after the famous poem, offering romantic accommodation.',
    imageUrl:
        'https://images.pexels.com/photos/1268871/pexels-photo-1268871.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 0.8,
    location: LatLng(5.9445, 80.4589),
    amenities: ['Pool', 'Restaurant', 'Bar', 'Ocean View', 'Spa'],
    highlights: ['Boutique', 'Romantic', 'Sunset Views'],
  ),
  Hotel(
    id: 'mir_4',
    name: 'Mirissa Beach Inn',
    city: 'Mirissa',
    rating: 8.1,
    ratingText: 'Very Good',
    reviewCount: 389,
    description:
        'Located right on Mirissa Beach with comfortable rooms, beach restaurant, and water sports facilities.',
    imageUrl:
        'https://images.pexels.com/photos/261096/pexels-photo-261096.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 0.3,
    location: LatLng(5.9489, 80.4512),
    amenities: ['Beach Access', 'Restaurant', 'Water Sports', 'Free WiFi'],
    highlights: ['On Beach', 'Water Sports', 'Great Value'],
  ),
  Hotel(
    id: 'mir_5',
    name: 'Secret Bay Mirissa',
    city: 'Mirissa',
    rating: 8.8,
    ratingText: 'Excellent',
    reviewCount: 234,
    description:
        'Hidden gem offering secluded cabanas surrounded by tropical gardens with private beach access.',
    imageUrl:
        'https://images.pexels.com/photos/2507010/pexels-photo-2507010.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 1.5,
    location: LatLng(5.9423, 80.4612),
    amenities: ['Private Beach', 'Garden', 'Restaurant', 'Pool', 'Spa'],
    highlights: ['Secluded', 'Private Beach', 'Tropical Garden'],
  ),
  Hotel(
    id: 'mir_6',
    name: 'Lantern Boutique Hotel',
    city: 'Mirissa',
    rating: 9.0,
    ratingText: 'Wonderful',
    reviewCount: 512,
    description:
        'Stylish boutique hotel with rooftop terrace offering stunning views of Mirissa Bay and surrounding coastline.',
    imageUrl:
        'https://images.pexels.com/photos/2373201/pexels-photo-2373201.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 0.6,
    location: LatLng(5.9467, 80.4534),
    amenities: ['Rooftop Terrace', 'Pool', 'Restaurant', 'Bar', 'Free WiFi'],
    highlights: ['Rooftop Views', 'Stylish Design', 'Central Location'],
  ),
];

// Trincomalee Hotels
final List<Hotel> trincomaleeHotels = [
  Hotel(
    id: 'tri_1',
    name: 'Trinco Blu by Cinnamon',
    city: 'Trincomalee',
    rating: 8.8,
    ratingText: 'Excellent',
    reviewCount: 987,
    description:
        'Beachfront resort on Uppuveli Beach with stunning bay views, multiple pools, and water sports facilities.',
    imageUrl:
        'https://images.pexels.com/photos/338504/pexels-photo-338504.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 6.5,
    location: LatLng(8.6123, 81.2234),
    amenities: ['Beach', 'Pool', 'Spa', 'Water Sports', 'Restaurant'],
    highlights: ['Beachfront', 'Water Sports', 'Family Friendly'],
  ),
  Hotel(
    id: 'tri_2',
    name: 'Jungle Beach by Uga Escapes',
    city: 'Trincomalee',
    rating: 9.3,
    ratingText: 'Wonderful',
    reviewCount: 654,
    description:
        'Luxury beach resort where jungle meets the sea, offering exclusive cabins and world-class diving experiences.',
    imageUrl:
        'https://images.pexels.com/photos/261395/pexels-photo-261395.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$\$',
    distanceFromCenter: 15.2,
    location: LatLng(8.5678, 81.2567),
    amenities: ['Private Beach', 'Pool', 'Diving', 'Spa', 'Restaurant'],
    highlights: ['Jungle Beach', 'Diving', 'Exclusive'],
  ),
  Hotel(
    id: 'tri_3',
    name: 'Anantamaa Hotel',
    city: 'Trincomalee',
    rating: 8.5,
    ratingText: 'Very Good',
    reviewCount: 456,
    description:
        'Charming boutique hotel near Nilaveli Beach with traditional architecture and warm hospitality.',
    imageUrl:
        'https://images.pexels.com/photos/2034335/pexels-photo-2034335.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 8.3,
    location: LatLng(8.7012, 81.1789),
    amenities: ['Pool', 'Restaurant', 'Garden', 'Beach Access', 'Free WiFi'],
    highlights: ['Near Nilaveli', 'Boutique', 'Traditional'],
  ),
  Hotel(
    id: 'tri_4',
    name: 'Pigeon Island Beach Resort',
    city: 'Trincomalee',
    rating: 8.2,
    ratingText: 'Very Good',
    reviewCount: 378,
    description:
        'Located near Pigeon Island National Park, perfect base for snorkeling and beach activities.',
    imageUrl:
        'https://images.pexels.com/photos/1579253/pexels-photo-1579253.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 12.4,
    location: LatLng(8.7234, 81.1567),
    amenities: ['Beach', 'Snorkeling', 'Restaurant', 'Pool', 'Free WiFi'],
    highlights: ['Near Pigeon Island', 'Snorkeling', 'Beach Access'],
  ),
  Hotel(
    id: 'tri_5',
    name: 'Amaranthe Bay Resort',
    city: 'Trincomalee',
    rating: 8.7,
    ratingText: 'Excellent',
    reviewCount: 534,
    description:
        'Modern beachfront resort with infinity pool overlooking the Indian Ocean and excellent seafood dining.',
    imageUrl:
        'https://images.pexels.com/photos/2467285/pexels-photo-2467285.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 5.8,
    location: LatLng(8.6234, 81.2123),
    amenities: ['Infinity Pool', 'Restaurant', 'Beach', 'Spa', 'Bar'],
    highlights: ['Infinity Pool', 'Ocean Views', 'Seafood'],
  ),
  Hotel(
    id: 'tri_6',
    name: 'Nilaveli Beach Hotel',
    city: 'Trincomalee',
    rating: 7.9,
    ratingText: 'Good',
    reviewCount: 312,
    description:
        'Classic beach hotel on famous Nilaveli Beach with comfortable accommodation and friendly service.',
    imageUrl:
        'https://images.pexels.com/photos/1743231/pexels-photo-1743231.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 9.2,
    location: LatLng(8.6789, 81.1678),
    amenities: ['Beach', 'Pool', 'Restaurant', 'Bar', 'Free WiFi'],
    highlights: ['Nilaveli Beach', 'Budget Friendly', 'Classic Style'],
  ),
];

// Arugam Bay Hotels
final List<Hotel> arugamBayHotels = [
  Hotel(
    id: 'aru_1',
    name: 'Kottukal Beach House',
    city: 'Arugam Bay',
    rating: 9.1,
    ratingText: 'Wonderful',
    reviewCount: 567,
    description:
        'Beachfront guesthouse popular with surfers, offering stunning ocean views and surf lessons.',
    imageUrl:
        'https://images.pexels.com/photos/1450363/pexels-photo-1450363.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 0.5,
    location: LatLng(6.8401, 81.8356),
    amenities: ['Beach Access', 'Surf Lessons', 'Restaurant', 'Free WiFi'],
    highlights: ['Surf Spot', 'Beach Views', 'Surfer Vibe'],
  ),
  Hotel(
    id: 'aru_2',
    name: 'Hideaway Resort',
    city: 'Arugam Bay',
    rating: 8.8,
    ratingText: 'Excellent',
    reviewCount: 423,
    description:
        'Secluded cabanas in tropical gardens, perfect for relaxation after a day of surfing.',
    imageUrl:
        'https://images.pexels.com/photos/261394/pexels-photo-261394.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 1.2,
    location: LatLng(6.8445, 81.8312),
    amenities: ['Garden', 'Pool', 'Restaurant', 'Bar', 'Yoga'],
    highlights: ['Secluded', 'Yoga Classes', 'Peaceful'],
  ),
  Hotel(
    id: 'aru_3',
    name: 'Danish Villa',
    city: 'Arugam Bay',
    rating: 8.5,
    ratingText: 'Very Good',
    reviewCount: 345,
    description:
        'Comfortable villa accommodation with pool, popular with families and groups visiting the surf coast.',
    imageUrl:
        'https://images.pexels.com/photos/1268871/pexels-photo-1268871.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 0.8,
    location: LatLng(6.8423, 81.8378),
    amenities: ['Pool', 'Restaurant', 'Family Rooms', 'Free WiFi', 'Garden'],
    highlights: ['Family Friendly', 'Pool', 'Central Location'],
  ),
  Hotel(
    id: 'aru_4',
    name: 'Arugam Bay Surf Resort',
    city: 'Arugam Bay',
    rating: 8.2,
    ratingText: 'Very Good',
    reviewCount: 289,
    description:
        'Purpose-built surf resort with board storage, surf shop, and experienced instructors.',
    imageUrl:
        'https://images.pexels.com/photos/261096/pexels-photo-261096.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$',
    distanceFromCenter: 0.3,
    location: LatLng(6.8389, 81.8389),
    amenities: [
      'Surf Shop',
      'Board Storage',
      'Restaurant',
      'Lessons',
      'Free WiFi',
    ],
    highlights: ['Surf Focus', 'Pro Instructors', 'Beach Access'],
  ),
  Hotel(
    id: 'aru_5',
    name: 'Stardust Beach Hotel',
    city: 'Arugam Bay',
    rating: 8.9,
    ratingText: 'Excellent',
    reviewCount: 412,
    description:
        'Stylish beach hotel with rooftop bar, perfect for watching the sunset over the bay.',
    imageUrl:
        'https://images.pexels.com/photos/2507010/pexels-photo-2507010.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$\$\$',
    distanceFromCenter: 0.6,
    location: LatLng(6.8412, 81.8367),
    amenities: ['Rooftop Bar', 'Restaurant', 'Beach Access', 'Pool', 'Spa'],
    highlights: ['Rooftop Bar', 'Sunset Views', 'Stylish'],
  ),
  Hotel(
    id: 'aru_6',
    name: 'Blue Wave Cabanas',
    city: 'Arugam Bay',
    rating: 7.8,
    ratingText: 'Good',
    reviewCount: 234,
    description:
        'Simple but comfortable cabanas steps from the beach, ideal for budget-conscious surfers.',
    imageUrl:
        'https://images.pexels.com/photos/2373201/pexels-photo-2373201.jpeg?auto=compress&cs=tinysrgb&w=800',
    priceRange: '\$',
    distanceFromCenter: 0.4,
    location: LatLng(6.8398, 81.8401),
    amenities: ['Beach Access', 'Restaurant', 'Free WiFi', 'Hammocks'],
    highlights: ['Budget Friendly', 'Steps to Beach', 'Laid Back'],
  ),
];

// Get all hotels across all cities
List<Hotel> get allHotels {
  List<Hotel> hotels = [];
  hotelsByCity.forEach((city, cityHotels) {
    hotels.addAll(cityHotels);
  });
  return hotels;
}

// Get hotels for a specific place/city
List<Hotel> getHotelsForCity(String cityName) {
  // Try exact match first
  if (hotelsByCity.containsKey(cityName)) {
    return hotelsByCity[cityName]!;
  }

  // Try partial match
  for (var city in hotelsByCity.keys) {
    if (cityName.toLowerCase().contains(city.toLowerCase()) ||
        city.toLowerCase().contains(cityName.toLowerCase())) {
      return hotelsByCity[city]!;
    }
  }

  // Return closest city's hotels or empty list
  return [];
}
