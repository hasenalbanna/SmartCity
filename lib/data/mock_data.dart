import '../models/guide.dart';
import '../models/travel_package.dart';
import '../models/place.dart';

// Enhanced Guide Profiles with full details
final List<Guide> mockGuides = [
  Guide(
    id: 'g1',
    name: 'Nimal Perera',
    expertise: 'History & Culture',
    rating: 4.8,
    imageAsset: 'assets/images/sigiriya.jpg',
    bio:
        'Passionate about Sri Lanka\'s ancient history, I have been guiding tourists through the cultural triangle for two decades. My specialty is making history come alive with stories and local insights.',
    languages: 'English, Sinhala, Tamil',
    yearsOfExperience: 20,
    dailyRate: 75.0,
    reviewCount: 342,
    availability: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    specializations: ['Sigiriya', 'Polonnaruwa', 'Anuradhapura', 'Dambulla'],
    isVerified: true,
    location: 'Sigiriya',
  ),
  Guide(
    id: 'g2',
    name: 'Sara Fernando',
    expertise: 'Wildlife Photography',
    rating: 4.9,
    imageAsset: 'assets/images/yala_leopard.jpg',
    bio:
        'Award-winning wildlife photographer specializing in leopard tracking. I guarantee the best photo opportunities in Yala and Wilpattu national parks.',
    languages: 'English, Spanish, Sinhala',
    yearsOfExperience: 12,
    dailyRate: 120.0,
    reviewCount: 218,
    availability: ['Mon', 'Tue', 'Wed', 'Fri', 'Sat', 'Sun'],
    specializations: [
      'Yala Safari',
      'Wilpattu',
      'Bird Watching',
      'Photography Tours',
    ],
    isVerified: true,
    location: 'Yala',
  ),
  Guide(
    id: 'g3',
    name: 'Kasun Jayasuriya',
    expertise: 'Hiking & Trekking',
    rating: 4.7,
    imageAsset: 'assets/images/nine_arch_bridge.jpg',
    bio:
        'Mountain enthusiast and certified trekking guide. From Adams Peak to Knuckles Range, I ensure safe and memorable hiking experiences.',
    languages: 'English, German, Sinhala',
    yearsOfExperience: 8,
    dailyRate: 65.0,
    reviewCount: 156,
    availability: ['Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    specializations: [
      'Adams Peak',
      'Knuckles Range',
      'Ella Rock',
      'Horton Plains',
    ],
    isVerified: true,
    location: 'Ella',
  ),
  Guide(
    id: 'g4',
    name: 'Ayesha Khan',
    expertise: 'Culinary Tours',
    rating: 4.9,
    imageAsset: 'assets/western province/galle-face.jpg',
    bio:
        'Food is the best way to understand a culture. Join me for authentic Sri Lankan cooking classes and street food tours in Colombo.',
    languages: 'English, Tamil, Hindi, Sinhala',
    yearsOfExperience: 10,
    dailyRate: 55.0,
    reviewCount: 289,
    availability: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    specializations: [
      'Cooking Classes',
      'Street Food',
      'Spice Gardens',
      'Tea Tasting',
    ],
    isVerified: true,
    location: 'Colombo',
  ),
  Guide(
    id: 'g5',
    name: 'Ruwan Silva',
    expertise: 'Surfing & Beach',
    rating: 4.6,
    imageAsset: 'assets/eastern province/arugam bay.jpg',
    bio:
        'Born and raised in Arugam Bay, I have been surfing since childhood. I offer lessons for all levels and beach tours along the east coast.',
    languages: 'English, Russian, Sinhala',
    yearsOfExperience: 15,
    dailyRate: 80.0,
    reviewCount: 178,
    availability: ['Mon', 'Tue', 'Thu', 'Fri', 'Sat', 'Sun'],
    specializations: [
      'Surfing Lessons',
      'Arugam Bay',
      'Mirissa',
      'Beach Tours',
    ],
    isVerified: true,
    location: 'Arugam Bay',
  ),
  Guide(
    id: 'g6',
    name: 'Malini De Silva',
    expertise: 'Wellness & Spiritual',
    rating: 5.0,
    imageAsset: 'assets/images/temple_tooth.jpg',
    bio:
        'Certified yoga instructor and meditation practitioner. I guide spiritual retreats combining ancient Buddhist practices with modern wellness.',
    languages: 'English, French, Sinhala',
    yearsOfExperience: 18,
    dailyRate: 90.0,
    reviewCount: 412,
    availability: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    specializations: [
      'Yoga Retreats',
      'Meditation',
      'Ayurveda',
      'Temple Tours',
    ],
    isVerified: true,
    location: 'Kandy',
  ),
];

// 5 Beautiful Places in Sri Lanka - Featured Packages
final List<TravelPackage> mockPackages = [
  TravelPackage(
    id: 'p1',
    title: 'Sigiriya Rock Fortress',
    duration: '2 Days',
    price: 180.00,
    description:
        'Marvel at the ancient rock fortress, a UNESCO World Heritage Site. Climb the majestic lion rock, explore the mirror wall, and witness stunning frescoes dating back 1,500 years.',
    imageAsset: 'assets/images/sigiriya.jpg',
    guideId: 'g1',
    itinerary: [
      'Day 1: Sigiriya Rock climb & museum visit',
      'Day 2: Pidurangala Rock sunrise & village tour',
    ],
  ),
  TravelPackage(
    id: 'p2',
    title: 'Galle Fort Heritage',
    duration: '2 Days',
    price: 150.00,
    description:
        'Walk through 400 years of colonial history within the walls of Galle Fort. Explore Dutch architecture, visit museums, and enjoy stunning sunset views from the ramparts.',
    imageAsset: 'assets/images/galle_fort.jpg',
    guideId: 'g4',
    itinerary: [
      'Day 1: Fort walking tour & lighthouse visit',
      'Day 2: Unawatuna Beach & turtle hatchery',
    ],
  ),
  TravelPackage(
    id: 'p3',
    title: 'Nine Arch Bridge Ella',
    duration: '3 Days',
    price: 220.00,
    description:
        'Experience the iconic Nine Arch Bridge set amidst lush tea plantations. Take the scenic train ride, hike to Little Adams Peak, and witness breathtaking mountain views.',
    imageAsset: 'assets/images/nine_arch_bridge.jpg',
    guideId: 'g3',
    itinerary: [
      'Day 1: Scenic train ride to Ella',
      'Day 2: Nine Arch Bridge & Little Adams Peak',
      'Day 3: Ella Rock hike & tea factory visit',
    ],
  ),
  TravelPackage(
    id: 'p4',
    title: 'Temple of the Tooth',
    duration: '2 Days',
    price: 160.00,
    description:
        'Visit the sacred Temple of the Tooth Relic in Kandy, home to Buddha\'s tooth relic. Experience traditional Kandyan dance and explore the Royal Botanical Gardens.',
    imageAsset: 'assets/images/temple_tooth.jpg',
    guideId: 'g6',
    itinerary: [
      'Day 1: Temple of the Tooth & Kandy Lake',
      'Day 2: Botanical Gardens & cultural show',
    ],
  ),
  TravelPackage(
    id: 'p5',
    title: 'Yala Leopard Safari',
    duration: '2 Days',
    price: 280.00,
    description:
        'Venture into Yala National Park, home to the highest density of leopards in the world. Spot elephants, crocodiles, and over 200 bird species on thrilling game drives.',
    imageAsset: 'assets/images/yala_leopard.jpg',
    guideId: 'g2',
    itinerary: [
      'Day 1: Afternoon safari & sunset viewing',
      'Day 2: Early morning leopard tracking safari',
    ],
  ),
];

// Province-based places with proper images
final Map<String, List<Place>> provincePlaces = {
  'Western': [
    Place(
      name: 'Lotus Tower',
      description:
          'South Asia\'s tallest tower with panoramic views of Colombo.',
      imageUrl:
          'https://images.unsplash.com/photo-1590123706498-e0efc1234d2c?w=400',
    ),
    Place(
      name: 'Gangaramaya Temple',
      description:
          'Eclectic mix of Sri Lankan, Thai, Indian, and Chinese architecture.',
      imageUrl: 'assets/western province/Gangaramaya-Temple.jpg',
    ),
    Place(
      name: 'Galle Face Green',
      description: 'Iconic ocean-side promenade perfect for sunset views.',
      imageUrl: 'assets/western province/galle-face.jpg',
    ),
  ],
  'Central': [
    Place(
      name: 'Sigiriya',
      description: 'UNESCO World Heritage ancient rock fortress.',
      imageUrl: 'assets/images/sigiriya.jpg',
    ),
    Place(
      name: 'Temple of the Tooth',
      description: 'Sacred Buddhist temple housing Buddha\'s tooth relic.',
      imageUrl: 'assets/central province/temple of tooth.jpg',
    ),
    Place(
      name: 'Horton Plains',
      description: 'Scenic plateau featuring World\'s End cliff viewpoint.',
      imageUrl: 'assets/central province/knuckles.jpg',
    ),
  ],
  'Southern': [
    Place(
      name: 'Galle Fort',
      description: 'Historic Dutch-built fortification and UNESCO site.',
      imageUrl: 'assets/images/galle_fort.jpg',
    ),
    Place(
      name: 'Mirissa Beach',
      description: 'Paradise beach famous for whale watching.',
      imageUrl: 'assets/southern province/mirissa beach.jpg',
    ),
    Place(
      name: 'Yala National Park',
      description: 'World\'s highest leopard density and diverse wildlife.',
      imageUrl: 'assets/images/yala_leopard.jpg',
    ),
  ],
  'Uva': [
    Place(
      name: 'Nine Arch Bridge',
      description: 'Iconic colonial-era railway bridge in Ella.',
      imageUrl: 'assets/images/nine_arch_bridge.jpg',
    ),
    Place(
      name: 'Little Adams Peak',
      description: 'Popular hiking destination with stunning views.',
      imageUrl: 'assets/uva province/ella rock.webp',
    ),
  ],
  'Eastern': [
    Place(
      name: 'Arugam Bay',
      description: 'World-class surfing destination on the east coast.',
      imageUrl: 'assets/eastern province/arugam bay.jpg',
    ),
    Place(
      name: 'Trincomalee',
      description: 'Beautiful beaches and historic temples.',
      imageUrl: 'assets/eastern province/pasikuda beach.jpg',
    ),
  ],
};
