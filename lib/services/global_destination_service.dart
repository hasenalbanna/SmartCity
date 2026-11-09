import 'package:latlong2/latlong.dart';
import '../data/global_regions_data.dart';
import '../data/hotels_data.dart' as data_hotels;

/// Lightweight model for country-specific iconic places
class GlobalPlace {
  final String name;
  final String tag;
  final String imageUrl;
  final double rating;
  final String summary;
  final LatLng coordinates;
  final String city;
  final double avgCostUsd;
  final String visitTip;
  final String history;

  const GlobalPlace({
    required this.name,
    required this.tag,
    required this.imageUrl,
    required this.rating,
    required this.summary,
    required this.coordinates,
    required this.city,
    this.avgCostUsd = 25.0,
    this.visitTip = 'Best visited in the early morning or near sunset.',
    this.history = 'A world-famous landmark cherished for its historical and cultural significance.',
  });
}

/// Lightweight model for arrival airports
class GlobalAirport {
  final String code;
  final String name;
  final String city;
  final String region;

  const GlobalAirport({
    required this.code,
    required this.name,
    required this.city,
    required this.region,
  });
}

/// Lightweight model for state/province explorer cards
class GlobalRegionCard {
  final String name;
  final String coverImageUrl;
  final String hotspot;
  final String tempLabel;
  final String liveVisitors;

  const GlobalRegionCard({
    required this.name,
    required this.coverImageUrl,
    required this.hotspot,
    required this.tempLabel,
    required this.liveVisitors,
  });
}

/// Lightweight transit route definition
class GlobalTransitRouteData {
  final String id;
  final String routeNumber;
  final String origin;
  final String destination;
  final int colorHex;
  final String operatingHours;
  final int frequencyMinutes;
  final double fareLocal;
  final String currencyCode;
  final List<LatLng> pathPoints;
  final List<String> stopNames;

  const GlobalTransitRouteData({
    required this.id,
    required this.routeNumber,
    required this.origin,
    required this.destination,
    required this.colorHex,
    required this.operatingHours,
    required this.frequencyMinutes,
    required this.fareLocal,
    required this.currencyCode,
    required this.pathPoints,
    required this.stopNames,
  });
}

/// Full package of country-specific metadata
class CountryExperience {
  final String countryName;
  final String countryCode;
  final String flag;
  final String tagline;
  final String coverImageUrl;
  final String defaultCurrency;
  final List<GlobalAirport> airports;
  final List<GlobalPlace> mustSeePlaces;
  final List<GlobalRegionCard> regionCards;
  final List<data_hotels.Hotel> hotels;
  final List<GlobalTransitRouteData> transitRoutes;
  final List<String> municipalDistricts;

  const CountryExperience({
    required this.countryName,
    required this.countryCode,
    required this.flag,
    required this.tagline,
    required this.coverImageUrl,
    required this.defaultCurrency,
    required this.airports,
    required this.mustSeePlaces,
    required this.regionCards,
    required this.hotels,
    required this.transitRoutes,
    required this.municipalDistricts,
  });
}

/// Ultra-fast in-memory registry of worldwide destinations, cover imagery,
/// airports, must-see places, and hotels. Operates with sub-millisecond execution
/// and zero local asset storage bloat.
class GlobalDestinationService {
  GlobalDestinationService._();

  static const Map<String, CountryExperience> _catalog = {
    // 1. UNITED STATES
    'US': CountryExperience(
      countryName: 'United States',
      countryCode: 'US',
      flag: '🇺🇸',
      tagline: 'United States • Iconic Skylines, National Parks & Innovation Hubs',
      coverImageUrl:
          'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=900&q=80',
      defaultCurrency: 'USD',
      municipalDistricts: [
        'Manhattan • Central Civic District',
        'Brooklyn • Innovation Corridor',
        'Queens • Transit & Aviation Hub',
        'Bronx • Urban Eco Zone',
        'Staten Island • Coastal Zone',
      ],
      airports: [
        GlobalAirport(
          code: 'JFK',
          name: 'John F. Kennedy International Airport',
          city: 'New York',
          region: 'New York',
        ),
        GlobalAirport(
          code: 'LAX',
          name: 'Los Angeles International Airport',
          city: 'Los Angeles',
          region: 'California',
        ),
        GlobalAirport(
          code: 'ORD',
          name: 'O\'Hare International Airport',
          city: 'Chicago',
          region: 'Illinois',
        ),
        GlobalAirport(
          code: 'SFO',
          name: 'San Francisco International Airport',
          city: 'San Francisco',
          region: 'California',
        ),
        GlobalAirport(
          code: 'MIA',
          name: 'Miami International Airport',
          city: 'Miami',
          region: 'Florida',
        ),
      ],
      mustSeePlaces: [
        GlobalPlace(
          name: 'Statue of Liberty & Ellis Island',
          tag: 'National Icon',
          imageUrl:
              'https://images.unsplash.com/photo-1605130284535-11dd9eedc58a?w=600&q=75',
          rating: 4.9,
          summary:
              'Global symbol of freedom and democracy standing at New York Harbor.',
          coordinates: LatLng(40.6892, -74.0445),
          city: 'New York',
          avgCostUsd: 30,
          visitTip: 'Take the early morning ferry to avoid long lines at the pedestal.',
          history:
              'Gift from the people of France to the United States dedicated in 1886.',
        ),
        GlobalPlace(
          name: 'Central Park Promenade',
          tag: 'Urban Oasis',
          imageUrl:
              'https://images.unsplash.com/photo-1538688525198-9b88f6f53126?w=600&q=75',
          rating: 4.8,
          summary:
              '843 acres of peaceful lakes, walking paths, and iconic bridges in Manhattan.',
          coordinates: LatLng(40.7829, -73.9654),
          city: 'New York',
          avgCostUsd: 15,
          visitTip: 'Rent a bicycle or stroll near Bethesda Terrace in late afternoon.',
          history:
              'Designed by Frederick Law Olmsted and Calvert Vaux, opened in 1858.',
        ),
        GlobalPlace(
          name: 'Golden Gate Bridge',
          tag: 'Architectural Wonder',
          imageUrl:
              'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=600&q=75',
          rating: 4.9,
          summary:
              'Internationally recognized suspension bridge connecting San Francisco to Marin County.',
          coordinates: LatLng(37.8199, -122.4783),
          city: 'San Francisco',
          avgCostUsd: 20,
          visitTip: 'Walk across the pedestrian path on a clear morning before noon fog.',
          history:
              'Opened in 1937, it was once the tallest and longest suspension bridge in the world.',
        ),
        GlobalPlace(
          name: 'Grand Canyon National Park',
          tag: 'Natural Wonder',
          imageUrl:
              'https://images.unsplash.com/photo-1474044159687-1ee9f3a51722?w=600&q=75',
          rating: 5.0,
          summary:
              'Immense canyon carved over millions of years by the Colorado River.',
          coordinates: LatLng(36.0544, -112.1401),
          city: 'Phoenix',
          avgCostUsd: 35,
          visitTip: 'Watch sunrise from Mather Point or Desert View Watchtower.',
          history:
              'UNESCO World Heritage site protected as a National Park since 1919.',
        ),
        GlobalPlace(
          name: 'Times Square & Broadway',
          tag: 'Entertainment',
          imageUrl:
              'https://images.unsplash.com/photo-1518391846015-55a9cc003b25?w=600&q=75',
          rating: 4.7,
          summary:
              'The bustling crossroads of the world renowned for theaters and dazzling digital billboards.',
          coordinates: LatLng(40.7580, -73.9855),
          city: 'New York',
          avgCostUsd: 50,
          visitTip: 'Visit after dark to experience the full spectacle of neon and theater lights.',
          history:
              'Named after The New York Times headquarters in 1904, it anchors New York theater.',
        ),
      ],
      regionCards: [
        GlobalRegionCard(
          name: 'New York Metro & Hudson Valley',
          coverImageUrl:
              'https://images.unsplash.com/photo-1534430480872-3498386e7856?w=700&q=75',
          hotspot: 'Manhattan Skyline & Brooklyn Waterfront',
          tempLabel: '21°C',
          liveVisitors: '18,420 live',
        ),
        GlobalRegionCard(
          name: 'California Coast & Bay Area',
          coverImageUrl:
              'https://images.unsplash.com/photo-1449034446853-66c86144b0ad?w=700&q=75',
          hotspot: 'San Francisco Bay & Silicon Valley',
          tempLabel: '19°C',
          liveVisitors: '14,350 live',
        ),
        GlobalRegionCard(
          name: 'Midwest & Great Lakes Hub',
          coverImageUrl:
              'https://images.unsplash.com/photo-1494522855154-9297ac14b55f?w=700&q=75',
          hotspot: 'Chicago Loop & Lake Michigan Coast',
          tempLabel: '17°C',
          liveVisitors: '9,810 live',
        ),
        GlobalRegionCard(
          name: 'Florida Sun & Space Coast',
          coverImageUrl:
              'https://images.unsplash.com/photo-1506953823976-52e1fdc0149a?w=700&q=75',
          hotspot: 'Miami Beach Waterfront & Everglades',
          tempLabel: '28°C',
          liveVisitors: '12,940 live',
        ),
      ],
      hotels: [
        data_hotels.Hotel(
          id: 'us_hot_1',
          name: 'The Plaza New York',
          city: 'New York',
          rating: 9.2,
          ratingText: 'Superb',
          reviewCount: 3410,
          description:
              'Timeless luxury facing Central Park South and Fifth Avenue, offering white-glove service and world-class fine dining.',
          imageUrl:
              'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=75',
          priceRange: '\$\$\$\$',
          distanceFromCenter: 0.8,
          location: LatLng(40.7645, -73.9744),
          amenities: ['Free WiFi', 'Spa & Wellness', 'Valet Parking', 'Fine Dining', 'Concierge'],
          highlights: ['Central Park Views', 'Historic Grandeur', 'Champagne Bar'],
        ),
        data_hotels.Hotel(
          id: 'us_hot_2',
          name: '1 Hotel Central Park',
          city: 'New York',
          rating: 9.0,
          ratingText: 'Wonderful',
          reviewCount: 2180,
          description:
              'An eco-conscious urban retreat with living green walls, reclaimed wood, and sustainable luxury in Midtown Manhattan.',
          imageUrl:
              'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=75',
          priceRange: '\$\$\$\$',
          distanceFromCenter: 0.9,
          location: LatLng(40.7648, -73.9760),
          amenities: ['Free WiFi', 'Organic Restaurant', 'Fitness Center', 'Pet Friendly'],
          highlights: ['Eco-Luxury', 'Steps to Central Park', 'Farm-to-Table Cuisine'],
        ),
        data_hotels.Hotel(
          id: 'us_hot_3',
          name: 'The Beverly Hills Hotel',
          city: 'Los Angeles',
          rating: 9.4,
          ratingText: 'Exceptional',
          reviewCount: 2950,
          description:
              'The legendary "Pink Palace" surrounded by lush tropical gardens on Sunset Boulevard with iconic poolside cabanas.',
          imageUrl:
              'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=75',
          priceRange: '\$\$\$\$',
          distanceFromCenter: 2.1,
          location: LatLng(34.0816, -118.4138),
          amenities: ['Outdoor Pool', 'Full Spa', 'Polo Lounge', 'Cabana Service', 'WiFi'],
          highlights: ['Hollywood Royalty Heritage', 'Lush Palm Gardens', 'Iconic Pool'],
        ),
        data_hotels.Hotel(
          id: 'us_hot_4',
          name: 'The Langham Chicago',
          city: 'Chicago',
          rating: 9.3,
          ratingText: 'Superb',
          reviewCount: 1840,
          description:
              'Majestic Mies van der Rohe riverfront landmark offering expansive views of Lake Michigan and the Chicago River.',
          imageUrl:
              'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=75',
          priceRange: '\$\$\$\$',
          distanceFromCenter: 0.5,
          location: LatLng(41.8885, -87.6275),
          amenities: ['Chuan Spa', 'Indoor Lap Pool', 'River View Dining', 'Executive Club'],
          highlights: ['Riverfront Views', 'Award-Winning Spa', 'Prime Loop Location'],
        ),
        data_hotels.Hotel(
          id: 'us_hot_5',
          name: '1 Hotel South Beach',
          city: 'Miami',
          rating: 8.9,
          ratingText: 'Excellent',
          reviewCount: 2640,
          description:
              '600 feet of direct Atlantic shoreline with 4 outdoor swimming pools including an exclusive rooftop pool.',
          imageUrl:
              'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&q=75',
          priceRange: '\$\$\$\$',
          distanceFromCenter: 1.4,
          location: LatLng(25.7983, -80.1265),
          amenities: ['Oceanfront Pools', 'Beach Access', 'Rooftop Bar', 'Spa', 'Free WiFi'],
          highlights: ['Private Beach', 'Adults Rooftop Pool', 'Oceanfront Dining'],
        ),
      ],
      transitRoutes: [
        GlobalTransitRouteData(
          id: 'mta_m15',
          routeNumber: 'MTA M15 SBS',
          origin: 'South Ferry Terminal',
          destination: 'East Harlem 125th St',
          colorHex: 0xFF2563EB,
          operatingHours: '24 Hours Daily',
          frequencyMinutes: 5,
          fareLocal: 2.90,
          currencyCode: 'USD',
          pathPoints: [
            LatLng(40.7013, -74.0134),
            LatLng(40.7128, -74.0060),
            LatLng(40.7282, -73.9872),
            LatLng(40.7527, -73.9772),
            LatLng(40.7769, -73.9532),
            LatLng(40.8033, -73.9358),
          ],
          stopNames: [
            'South Ferry / Whitehall St',
            'Fulton St / Water St',
            'East Houston St / 2nd Ave',
            'Grand Central / 42nd St',
            '86th St / 2nd Ave',
            '125th St / 2nd Ave',
          ],
        ),
        GlobalTransitRouteData(
          id: 'mta_q32',
          routeNumber: 'MTA Q32 Express',
          origin: 'Penn Station 34th St',
          destination: 'Jackson Heights Queens',
          colorHex: 0xFF10B981,
          operatingHours: '05:00 AM - 01:30 AM',
          frequencyMinutes: 10,
          fareLocal: 2.90,
          currencyCode: 'USD',
          pathPoints: [
            LatLng(40.7505, -73.9934),
            LatLng(40.7580, -73.9855),
            LatLng(40.7600, -73.9600),
            LatLng(40.7490, -73.9100),
            LatLng(40.7550, -73.8830),
          ],
          stopNames: [
            'Penn Station / 7th Ave',
            'Times Square / 42nd St',
            'Queensboro Plaza',
            'Roosevelt Ave / 74th St',
            'Jackson Heights Transit Hub',
          ],
        ),
      ],
    ),

    // 2. UNITED KINGDOM
    'GB': CountryExperience(
      countryName: 'United Kingdom',
      countryCode: 'GB',
      flag: '🇬🇧',
      tagline: 'United Kingdom • Royal Heritage, Historic Architecture & Smart Mobility',
      coverImageUrl:
          'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=900&q=80',
      defaultCurrency: 'GBP',
      municipalDistricts: [
        'City of Westminster • Royal Ward',
        'Camden & Kings Cross • Tech Hub',
        'Southwark & London Bridge • Cultural Zone',
        'Kensington & Chelsea • Heritage District',
        'Canary Wharf • Financial Centre',
      ],
      airports: [
        GlobalAirport(
          code: 'LHR',
          name: 'London Heathrow Airport',
          city: 'London',
          region: 'Greater London',
        ),
        GlobalAirport(
          code: 'LGW',
          name: 'London Gatwick Airport',
          city: 'London',
          region: 'West Sussex',
        ),
        GlobalAirport(
          code: 'MAN',
          name: 'Manchester Airport',
          city: 'Manchester',
          region: 'Greater Manchester',
        ),
        GlobalAirport(
          code: 'EDI',
          name: 'Edinburgh Airport',
          city: 'Edinburgh',
          region: 'Scotland',
        ),
      ],
      mustSeePlaces: [
        GlobalPlace(
          name: 'Tower Bridge & Tower of London',
          tag: 'Royal Heritage',
          imageUrl:
              'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=600&q=75',
          rating: 4.9,
          summary:
              'Historic castle and Victorian bascule bridge straddling the River Thames.',
          coordinates: LatLng(51.5055, -0.0754),
          city: 'London',
          avgCostUsd: 32,
          visitTip: 'Walk the glass floor of Tower Bridge walkways for river views.',
        ),
        GlobalPlace(
          name: 'Big Ben & Palace of Westminster',
          tag: 'Parliament Landmark',
          imageUrl:
              'https://images.unsplash.com/photo-1529655683826-aba9b3e77383?w=600&q=75',
          rating: 4.8,
          summary:
              'The iconic Elizabeth Tower clock and seat of the UK Parliament on the Thames.',
          coordinates: LatLng(51.5007, -0.1246),
          city: 'London',
          avgCostUsd: 25,
          visitTip: 'View across Westminster Bridge at dusk for golden hour reflections.',
        ),
        GlobalPlace(
          name: 'Edinburgh Castle & Royal Mile',
          tag: 'Ancient Fortress',
          imageUrl:
              'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb?w=600&q=75',
          rating: 4.9,
          summary:
              'Historic castle dominating the skyline of Edinburgh atop Castle Rock.',
          coordinates: LatLng(55.9486, -3.1999),
          city: 'Edinburgh',
          avgCostUsd: 28,
          visitTip: 'Arrive before 1:00 PM to witness the daily One O\'Clock Gun firing.',
        ),
      ],
      regionCards: [
        GlobalRegionCard(
          name: 'Greater London & Thames Valley',
          coverImageUrl:
              'https://images.unsplash.com/photo-1505761671935-60b3a7427bad?w=700&q=75',
          hotspot: 'Westminster & London Bridge',
          tempLabel: '16°C',
          liveVisitors: '22,100 live',
        ),
        GlobalRegionCard(
          name: 'Scottish Highlands & Edinburgh',
          coverImageUrl:
              'https://images.unsplash.com/photo-1506377247377-2a5b3b417ebb?w=700&q=75',
          hotspot: 'Old Town & Arthur\'s Seat',
          tempLabel: '13°C',
          liveVisitors: '8,400 live',
        ),
      ],
      hotels: [
        data_hotels.Hotel(
          id: 'uk_hot_1',
          name: 'The Ritz London',
          city: 'London',
          rating: 9.3,
          ratingText: 'Superb',
          reviewCount: 3820,
          description:
              'An opulent landmark of world-renowned luxury in Piccadilly offering traditional afternoon tea and Michelin-star dining.',
          imageUrl:
              'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=75',
          priceRange: '\$\$\$\$',
          distanceFromCenter: 0.6,
          location: LatLng(51.5071, -0.1416),
          amenities: ['Afternoon Tea Room', 'Michelin Restaurant', 'Concierge', 'WiFi'],
          highlights: ['World Renowned Tea', 'Neoclassical Splendour', 'Piccadilly Frontage'],
        ),
        data_hotels.Hotel(
          id: 'uk_hot_2',
          name: 'The Savoy',
          city: 'London',
          rating: 9.1,
          ratingText: 'Wonderful',
          reviewCount: 2950,
          description:
              'Historic luxury hotel on the Strand overlooking the River Thames, blending Edwardian and Art Deco elegance.',
          imageUrl:
              'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=75',
          priceRange: '\$\$\$\$',
          distanceFromCenter: 0.4,
          location: LatLng(51.5103, -0.1206),
          amenities: ['Indoor Pool', 'Gordon Ramsay Grill', 'Thames Views', 'Spa', 'WiFi'],
          highlights: ['Thames Riverside', 'American Bar', 'Art Deco Suites'],
        ),
      ],
      transitRoutes: [
        GlobalTransitRouteData(
          id: 'tfl_route9',
          routeNumber: 'TfL Route 9',
          origin: 'Aldwych / Somerset House',
          destination: 'Hammersmith Bus Station',
          colorHex: 0xFFDC2626,
          operatingHours: '05:00 AM - Midnight',
          frequencyMinutes: 6,
          fareLocal: 1.75,
          currencyCode: 'GBP',
          pathPoints: [
            LatLng(51.5126, -0.1171),
            LatLng(51.5080, -0.1281),
            LatLng(51.5033, -0.1585),
            LatLng(51.4927, -0.2227),
          ],
          stopNames: [
            'Aldwych',
            'Trafalgar Square',
            'Hyde Park Corner',
            'High St Kensington',
            'Hammersmith Broadway',
          ],
        ),
      ],
    ),

    // 3. JAPAN
    'JP': CountryExperience(
      countryName: 'Japan',
      countryCode: 'JP',
      flag: '🇯🇵',
      tagline: 'Japan • Futuristic Smart Transit, Shrines & Timeless Traditions',
      coverImageUrl:
          'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=900&q=80',
      defaultCurrency: 'JPY',
      municipalDistricts: [
        'Shinjuku • High-Tech Metro Zone',
        'Shibuya • Cultural & Youth District',
        'Chiyoda • Imperial & Civic Centre',
        'Asakusa • Traditional Heritage Ward',
        'Roppongi • International Art District',
      ],
      airports: [
        GlobalAirport(
          code: 'HND',
          name: 'Tokyo Haneda Airport',
          city: 'Tokyo',
          region: 'Kanto',
        ),
        GlobalAirport(
          code: 'NRT',
          name: 'Narita International Airport',
          city: 'Tokyo',
          region: 'Chiba',
        ),
        GlobalAirport(
          code: 'KIX',
          name: 'Kansai International Airport',
          city: 'Osaka',
          region: 'Kansai',
        ),
      ],
      mustSeePlaces: [
        GlobalPlace(
          name: 'Mount Fuji & Lake Kawaguchiko',
          tag: 'Sacred Peak',
          imageUrl:
              'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=600&q=75',
          rating: 4.9,
          summary:
              'Japan\'s tallest sacred volcano reflected across scenic crater lakes.',
          coordinates: LatLng(35.3606, 138.7274),
          city: 'Tokyo',
          avgCostUsd: 40,
        ),
        GlobalPlace(
          name: 'Fushimi Inari Shrine',
          tag: 'Sacred Shrines',
          imageUrl:
              'https://images.unsplash.com/photo-1478436127897-769e1b3f0f36?w=600&q=75',
          rating: 4.9,
          summary:
              'Thousands of vermilion torii gates winding through tranquil mountain forest paths.',
          coordinates: LatLng(34.9671, 135.7727),
          city: 'Kyoto',
          avgCostUsd: 0,
        ),
      ],
      regionCards: [
        GlobalRegionCard(
          name: 'Greater Tokyo & Kanto',
          coverImageUrl:
              'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=700&q=75',
          hotspot: 'Shinjuku & Shibuya Crossing',
          tempLabel: '18°C',
          liveVisitors: '28,900 live',
        ),
        GlobalRegionCard(
          name: 'Kyoto & Kansai Cultural Belt',
          coverImageUrl:
              'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=700&q=75',
          hotspot: 'Gion & Arashiyama Bamboo Grove',
          tempLabel: '17°C',
          liveVisitors: '16,200 live',
        ),
      ],
      hotels: [
        data_hotels.Hotel(
          id: 'jp_hot_1',
          name: 'Aman Tokyo',
          city: 'Tokyo',
          rating: 9.5,
          ratingText: 'Exceptional',
          reviewCount: 1650,
          description:
              'Urban sanctuary combining traditional Japanese design with modern minimalism high above the Otemachi financial district.',
          imageUrl:
              'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=75',
          priceRange: '\$\$\$\$',
          distanceFromCenter: 0.4,
          location: LatLng(35.6865, 139.7650),
          amenities: ['Indoor Pool', 'Traditional Spa', 'Onsen Baths', 'Fine Japanese Dining'],
          highlights: ['Panoramic Fuji Views', 'High-Rise Serenity', 'Crafted Wood Architecture'],
        ),
      ],
      transitRoutes: [
        GlobalTransitRouteData(
          id: 'toei_bus_01',
          routeNumber: 'Toei Route 01',
          origin: 'Shibuya Station East Exit',
          destination: 'Shinbashi Station West',
          colorHex: 0xFF10B981,
          operatingHours: '05:30 AM - 11:30 PM',
          frequencyMinutes: 4,
          fareLocal: 210.0,
          currencyCode: 'JPY',
          pathPoints: [
            LatLng(35.6580, 139.7016),
            LatLng(35.6628, 139.7314),
            LatLng(35.6663, 139.7583),
          ],
          stopNames: [
            'Shibuya Station',
            'Roppongi Station',
            'Toranomon Hills',
            'Shinbashi Station',
          ],
        ),
      ],
    ),

    // 4. UNITED ARAB EMIRATES
    'AE': CountryExperience(
      countryName: 'United Arab Emirates',
      countryCode: 'AE',
      flag: '🇦🇪',
      tagline: 'UAE • Futuristic Smart Megacities, Desert Dunes & World Records',
      coverImageUrl:
          'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=900&q=80',
      defaultCurrency: 'AED',
      municipalDistricts: [
        'Downtown Dubai • Burj District',
        'Dubai Marina & JBR • Coastal Belt',
        'DIFC • Smart Financial Zone',
        'Deira & Old Creek • Heritage Port',
        'Business Bay • Innovation Canal',
      ],
      airports: [
        GlobalAirport(
          code: 'DXB',
          name: 'Dubai International Airport',
          city: 'Dubai',
          region: 'Dubai',
        ),
        GlobalAirport(
          code: 'AUH',
          name: 'Zayed International Airport',
          city: 'Abu Dhabi',
          region: 'Abu Dhabi',
        ),
      ],
      mustSeePlaces: [
        GlobalPlace(
          name: 'Burj Khalifa & Dubai Fountain',
          tag: 'World Record',
          imageUrl:
              'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=600&q=75',
          rating: 4.9,
          summary:
              'The world\'s tallest architectural structure rising 828 meters above Downtown Dubai.',
          coordinates: LatLng(25.1972, 55.2744),
          city: 'Dubai',
          avgCostUsd: 45,
        ),
        GlobalPlace(
          name: 'Sheikh Zayed Grand Mosque',
          tag: 'Architectural Gem',
          imageUrl:
              'https://images.unsplash.com/photo-1580674684081-7617fbf3d745?w=600&q=75',
          rating: 5.0,
          summary:
              'Majestic white marble landmark with 82 domes and 24-carat gold gilded chandeliers.',
          coordinates: LatLng(24.4128, 54.4750),
          city: 'Abu Dhabi',
          avgCostUsd: 0,
        ),
      ],
      regionCards: [
        GlobalRegionCard(
          name: 'Dubai Smart Urban Belt',
          coverImageUrl:
              'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=700&q=75',
          hotspot: 'Burj Khalifa & Museum of the Future',
          tempLabel: '32°C',
          liveVisitors: '25,400 live',
        ),
      ],
      hotels: [
        data_hotels.Hotel(
          id: 'ae_hot_1',
          name: 'Burj Al Arab Jumeirah',
          city: 'Dubai',
          rating: 9.6,
          ratingText: 'Exceptional',
          reviewCount: 3890,
          description:
              'The world\'s most iconic sail-shaped luxury hotel, resting on its own island with private butler service for every suite.',
          imageUrl:
              'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=75',
          priceRange: '\$\$\$\$',
          distanceFromCenter: 2.8,
          location: LatLng(25.1412, 55.1852),
          amenities: ['Private Beach', 'Talise Spa', 'Helipad', 'Underwater Restaurant', 'WiFi'],
          highlights: ['Sail-Shaped Icon', 'Private Island', 'Ultra-Luxury Suites'],
        ),
      ],
      transitRoutes: [
        GlobalTransitRouteData(
          id: 'rta_route8',
          routeNumber: 'RTA Route 8',
          origin: 'Gold Souq Bus Station',
          destination: 'Dubai Marina / JBR',
          colorHex: 0xFFD97706,
          operatingHours: '05:00 AM - 11:30 PM',
          frequencyMinutes: 10,
          fareLocal: 7.50,
          currencyCode: 'AED',
          pathPoints: [
            LatLng(25.2697, 55.3006),
            LatLng(25.2285, 55.2600),
            LatLng(25.1412, 55.1852),
            LatLng(25.0780, 55.1340),
          ],
          stopNames: [
            'Gold Souq Deira',
            'Jumeirah Mosque',
            'Burj Al Arab',
            'Dubai Marina Mall',
          ],
        ),
      ],
    ),

    // 5. SRI LANKA
    'LK': CountryExperience(
      countryName: 'Sri Lanka',
      countryCode: 'LK',
      flag: '🇱🇰',
      tagline: 'Sri Lanka • Ancient Kingdoms, Emerald Tea Valleys & Coastal Paradises',
      coverImageUrl: 'assets/cover.png',
      defaultCurrency: 'LKR',
      municipalDistricts: [
        'Ward 01 — Nintavur North',
        'Ward 02 — Hospital Road',
        'Ward 03 — Town Central',
        'Ward 04 — Addappalam',
        'Ward 05 — Coastal Belt',
      ],
      airports: [
        GlobalAirport(
          code: 'CMB',
          name: 'Bandaranaike International Airport',
          city: 'Katunayake',
          region: 'Western',
        ),
        GlobalAirport(
          code: 'HRI',
          name: 'Mattala Rajapaksa International Airport',
          city: 'Hambantota',
          region: 'Southern',
        ),
        GlobalAirport(
          code: 'JAF',
          name: 'Jaffna International Airport',
          city: 'Jaffna',
          region: 'Northern',
        ),
        GlobalAirport(
          code: 'BTC',
          name: 'Batticaloa Airport (Near Nintavur)',
          city: 'Batticaloa',
          region: 'Eastern',
        ),
      ],
      mustSeePlaces: [
        GlobalPlace(
          name: 'Sigiriya Rock Fortress',
          tag: 'Ancient Wonder',
          imageUrl: 'assets/images/sigiriya.jpg',
          rating: 4.9,
          summary:
              'Ancient 5th-century sky fortress with frescoes, mirror wall, and 360-degree jungle views.',
          coordinates: LatLng(7.9570, 80.7603),
          city: 'Sigiriya',
          avgCostUsd: 30,
        ),
        GlobalPlace(
          name: 'Galle Dutch Fort',
          tag: 'Colonial Heritage',
          imageUrl: 'assets/images/galle_fort.jpg',
          rating: 4.8,
          summary:
              'UNESCO coastal fort city with colonial ramparts, ocean vistas, and heritage cafes.',
          coordinates: LatLng(6.0270, 80.2170),
          city: 'Galle',
          avgCostUsd: 10,
        ),
        GlobalPlace(
          name: 'Temple of the Sacred Tooth Relic',
          tag: 'Spiritual Gem',
          imageUrl: 'assets/central province/temple of tooth.jpg',
          rating: 4.8,
          summary:
              'Venerated Buddhist shrine in the heart of Kandy by the tranquil Kandy Lake.',
          coordinates: LatLng(7.2936, 80.6413),
          city: 'Kandy',
          avgCostUsd: 15,
        ),
      ],
      regionCards: [
        GlobalRegionCard(
          name: 'Eastern Province (Nintavur & Batticaloa)',
          coverImageUrl: 'assets/PROVINCE COVER PHOTO/EASTERN.png',
          hotspot: 'Smart Coastal Belt & Arugam Bay',
          tempLabel: '29°C',
          liveVisitors: '6,420 live',
        ),
        GlobalRegionCard(
          name: 'Central Province (Kandy & Sigiriya)',
          coverImageUrl: 'assets/PROVINCE COVER PHOTO/CENTRAL.png',
          hotspot: 'Sigiriya & Cultural Route',
          tempLabel: '22°C',
          liveVisitors: '5,184 live',
        ),
        GlobalRegionCard(
          name: 'Western Province (Colombo Metro)',
          coverImageUrl: 'assets/PROVINCE COVER PHOTO/WESTERN.png',
          hotspot: 'Colombo Waterfront & City of Dreams',
          tempLabel: '25°C',
          liveVisitors: '5,945 live',
        ),
      ],
      hotels: [], // Will merge with existing `data_hotels.allHotels`
      transitRoutes: [
        GlobalTransitRouteData(
          id: 'route_22',
          routeNumber: 'Route 22 Express',
          origin: 'Nintavur Main Terminal',
          destination: 'Kalmunai Central Stand',
          colorHex: 0xFF2563EB,
          operatingHours: '05:30 AM - 10:00 PM',
          frequencyMinutes: 8,
          fareLocal: 85.0,
          currencyCode: 'LKR',
          pathPoints: [
            LatLng(7.3486, 81.8494),
            LatLng(7.3620, 81.8460),
            LatLng(7.3780, 81.8420),
            LatLng(7.3950, 81.8360),
            LatLng(7.4167, 81.8333),
          ],
          stopNames: [
            'Nintavur Terminal',
            'Hospital Junction',
            'Addappalam Market',
            'Sainthamaruthu',
            'Kalmunai Stand',
          ],
        ),
      ],
    ),
  };

  /// Retrieves the rich CountryExperience for any country query with instant fallback
  static CountryExperience getExperience(String query) {
    final region = GlobalRegions.findCountry(query);
    final match = _catalog[region.code];
    if (match != null) {
      if (region.code == 'LK' && match.hotels.isEmpty) {
        return CountryExperience(
          countryName: match.countryName,
          countryCode: match.countryCode,
          flag: match.flag,
          tagline: match.tagline,
          coverImageUrl: match.coverImageUrl,
          defaultCurrency: match.defaultCurrency,
          airports: match.airports,
          mustSeePlaces: match.mustSeePlaces,
          regionCards: match.regionCards,
          hotels: data_hotels.allHotels,
          transitRoutes: match.transitRoutes,
          municipalDistricts: match.municipalDistricts,
        );
      }
      return match;
    }

    // Dynamic zero-allocation generator for any other country
    final cityNames = region.cities.map((c) => c.name).toList();
    final primaryCity = cityNames.isNotEmpty ? cityNames.first : region.name;

    return CountryExperience(
      countryName: region.name,
      countryCode: region.code,
      flag: region.flag,
      tagline: '${region.name} • Global Smart City & Explorer Network',
      coverImageUrl:
          'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=900&q=80',
      defaultCurrency: 'USD',
      municipalDistricts: [
        '$primaryCity • Central Civic Ward',
        '$primaryCity • Innovation Zone',
        '$primaryCity • Transit Hub',
        '$primaryCity • Eco-Corridor',
      ],
      airports: [
        GlobalAirport(
          code: '${region.code}A',
          name: '$primaryCity International Airport',
          city: primaryCity,
          region: region.name,
        ),
      ],
      mustSeePlaces: [
        GlobalPlace(
          name: '$primaryCity Landmark & Historic Centre',
          tag: 'City Centre',
          imageUrl:
              'https://images.unsplash.com/photo-1477959858617-67f30bc75b82?w=600&q=75',
          rating: 4.8,
          summary: 'Premier cultural and architectural district of $primaryCity.',
          coordinates: region.center,
          city: primaryCity,
        ),
      ],
      regionCards: [
        GlobalRegionCard(
          name: '$primaryCity Metro & Surroundings',
          coverImageUrl:
              'https://images.unsplash.com/photo-1480714378408-67cf0d13bc1b?w=700&q=75',
          hotspot: '$primaryCity Central Plaza',
          tempLabel: '24°C',
          liveVisitors: '11,200 live',
        ),
      ],
      hotels: [
        data_hotels.Hotel(
          id: '${region.code.toLowerCase()}_hot_1',
          name: '$primaryCity Grand Metropolitan Hotel',
          city: primaryCity,
          rating: 9.1,
          ratingText: 'Superb',
          reviewCount: 1420,
          description:
              'World-class luxury hotel located directly in the cultural and business centre of $primaryCity.',
          imageUrl:
              'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=75',
          priceRange: '\$\$\$\$',
          distanceFromCenter: 0.8,
          location: region.center,
          amenities: ['Free WiFi', 'Pool', 'Fine Dining', 'Fitness Center'],
          highlights: ['Prime Location', 'Panoramic Views', 'Executive Lounge'],
        ),
      ],
      transitRoutes: [
        GlobalTransitRouteData(
          id: '${region.code.toLowerCase()}_metro_1',
          routeNumber: 'Line 1 Express',
          origin: '$primaryCity Terminal',
          destination: '$primaryCity North Hub',
          colorHex: 0xFF2563EB,
          operatingHours: '05:30 AM - Midnight',
          frequencyMinutes: 8,
          fareLocal: 2.50,
          currencyCode: 'USD',
          pathPoints: [
            region.center,
            LatLng(region.center.latitude + 0.02, region.center.longitude + 0.02),
          ],
          stopNames: ['$primaryCity Terminal', '$primaryCity Central', '$primaryCity North'],
        ),
      ],
    );
  }

  /// Returns must-see places for a given country
  static List<GlobalPlace> getMustSeePlaces(String countryQuery) {
    return getExperience(countryQuery).mustSeePlaces;
  }

  /// Returns airports for a given country
  static List<GlobalAirport> getAirports(String countryQuery) {
    return getExperience(countryQuery).airports;
  }

  /// Returns hotels for a given country with optional city filter
  static List<data_hotels.Hotel> getHotels(String countryQuery, {String city = 'All'}) {
    final exp = getExperience(countryQuery);
    final all = exp.hotels;
    if (city == 'All' || city.trim().isEmpty) {
      return all;
    }
    final cLower = city.trim().toLowerCase();
    final filtered = all
        .where((h) =>
            h.city.toLowerCase() == cLower ||
            h.city.toLowerCase().contains(cLower) ||
            cLower.contains(h.city.toLowerCase()))
        .toList();
    return filtered.isNotEmpty ? filtered : all;
  }

  /// Returns cover photo URL for a country
  static String getCoverImage(String countryQuery) {
    return getExperience(countryQuery).coverImageUrl;
  }
}
