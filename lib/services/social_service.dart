import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message.dart';
import '../models/comment.dart';
import '../models/traveler_profile.dart';
import '../models/user_post.dart';

class SocialNotificationDoc {
  final String id;
  final Map<String, dynamic> _data;
  SocialNotificationDoc(this.id, this._data);
  Map<String, dynamic> data() => _data;
}

class SocialNotificationSnapshot {
  final List<SocialNotificationDoc> docs;
  SocialNotificationSnapshot(this.docs);
}

class SocialService extends ChangeNotifier {
  final List<Comment> _comments = [];
  final List<UserPost> _userPosts = [];
  final List<TravelerProfile> _travelers = [];
  final Set<String> _followingIds = {};
  final Set<String> _savedPostIds = {};
  final Map<String, List<ChatMessage>> _chatRooms = {};
  final List<SocialNotificationDoc> _notifications = [];

  final StreamController<SocialNotificationSnapshot> _notifController =
      StreamController<SocialNotificationSnapshot>.broadcast();
  final Map<String, StreamController<List<ChatMessage>>> _chatControllers = {};
  final Map<String, StreamController<List<Comment>>> _postCommentsControllers =
      {};

  StreamSubscription<Position>? _locationSub;
  Position? _myPosition;
  bool _locationSharingEnabled = false;
  String? _currentUserId = 'local_user_1';
  String _currentUserName = 'Citizen';

  SocialService() {
    _initLocalSession();
    _seedInitialData();
  }

  List<Comment> get comments => List.unmodifiable(_comments);
  List<UserPost> get userPosts => List.unmodifiable(_userPosts);
  List<TravelerProfile> get travelers => List.unmodifiable(_travelers);
  List<UserPost> get savedPosts => _userPosts
      .where((post) => _savedPostIds.contains(post.id))
      .toList(growable: false);
  String get currentUserId => _currentUserId ?? 'local_user_1';
  String get currentUserName => _currentUserName;
  Position? get myPosition => _myPosition;
  bool get locationSharingEnabled => _locationSharingEnabled;

  Future<void> _initLocalSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getString('local_user_id');
      final savedName = prefs.getString('local_username');
      if (savedId != null) _currentUserId = savedId;
      if (savedName != null) _currentUserName = savedName;
      notifyListeners();
    } catch (_) {}
  }

  void _seedInitialData() {
    // Seed global & local registered citizens and travelers
    _travelers.addAll([
      const TravelerProfile(
        uid: 'user_albanna',
        username: 'albanna',
        displayName: 'AL Banna',
        avatarUrl: '',
        bio: 'Senior Civic Steward & Global Smart City Lead Contributor',
        country: 'Sri Lanka',
        city: 'Nintavur',
        countryFlag: '🇱🇰',
        followersCount: 512,
        placesTraveledCount: 14,
        routesSharedCount: 6,
        isVerified: true,
        recentRoute: 'Colombo Lotus Tower ➔ Galle Face ➔ Nintavur Hub',
        locationSharingEnabled: true,
        latitude: 7.3486,
        longitude: 81.8494,
      ),
      const TravelerProfile(
        uid: 'user_alex',
        username: 'alex_smart',
        displayName: 'Alex Rivera',
        avatarUrl: '',
        bio: 'Full-Stack Smart City Engineer & High-Altitude Urban Explorer',
        country: 'United States',
        city: 'New York',
        countryFlag: '🇺🇸',
        followersCount: 584,
        placesTraveledCount: 21,
        routesSharedCount: 11,
        isVerified: true,
        recentRoute: 'Central Park Promenade ➔ Bethesda Terrace ➔ The Met',
        locationSharingEnabled: true,
        latitude: 40.7829,
        longitude: -73.9654,
      ),
      const TravelerProfile(
        uid: 'user_sarah',
        username: 'sarah_city',
        displayName: 'Sarah Jenkins',
        avatarUrl: '',
        bio: 'Hudson River Ecosystem Monitor & Brooklyn Trail Guide',
        country: 'United States',
        city: 'New York',
        countryFlag: '🇺🇸',
        followersCount: 490,
        placesTraveledCount: 19,
        routesSharedCount: 8,
        isVerified: true,
        recentRoute: 'City Hall ➔ Brooklyn Bridge ➔ DUMBO Pebble Beach',
        locationSharingEnabled: true,
        latitude: 40.7061,
        longitude: -73.9969,
      ),
      const TravelerProfile(
        uid: 'user_david',
        username: 'david_transit',
        displayName: 'David Ross',
        avatarUrl: '',
        bio: 'National Parks Trail Documenter & Transit Corridor Optimizer',
        country: 'United States',
        city: 'Phoenix',
        countryFlag: '🇺🇸',
        followersCount: 395,
        placesTraveledCount: 18,
        routesSharedCount: 7,
        isVerified: true,
        recentRoute: 'Mather Point ➔ Bright Angel Trail ➔ Ooh Aah Point',
        locationSharingEnabled: false,
        latitude: 36.0544,
        longitude: -112.1401,
      ),
      const TravelerProfile(
        uid: 'user_elena',
        username: 'elena_tokyo',
        displayName: 'Elena Sato',
        avatarUrl: '',
        bio: 'Tokyo Smart Mobility Urbanist & Mountain Route Trailblazer',
        country: 'Japan',
        city: 'Tokyo',
        countryFlag: '🇯🇵',
        followersCount: 640,
        placesTraveledCount: 22,
        routesSharedCount: 9,
        isVerified: true,
        recentRoute: 'Shinjuku Station ➔ Lake Ashi ➔ Mt. Fuji 5th Station',
        locationSharingEnabled: true,
        latitude: 35.6762,
        longitude: 139.6503,
      ),
      const TravelerProfile(
        uid: 'user_marcus',
        username: 'marcus_london',
        displayName: 'Marcus Davies',
        avatarUrl: '',
        bio: 'Civic Infrastructure Auditor & Historic Trail Hiker',
        country: 'United Kingdom',
        city: 'London',
        countryFlag: '🇬🇧',
        followersCount: 410,
        placesTraveledCount: 16,
        routesSharedCount: 5,
        isVerified: true,
        recentRoute: 'London Tower Bridge ➔ Oxford Bodleian ➔ Cotswolds',
        locationSharingEnabled: true,
        latitude: 51.5074,
        longitude: -0.1278,
      ),
      const TravelerProfile(
        uid: 'user_amira',
        username: 'amira_dubai',
        displayName: 'Amira Al-Mansoor',
        avatarUrl: '',
        bio: 'Next-Gen Autonomous City Researcher & Desert Route Mapper',
        country: 'United Arab Emirates',
        city: 'Dubai',
        countryFlag: '🇦🇪',
        followersCount: 325,
        placesTraveledCount: 12,
        routesSharedCount: 4,
        isVerified: true,
        recentRoute: 'Downtown Dubai ➔ Al Qudra Lakes ➔ Hatta Dam',
        locationSharingEnabled: true,
        latitude: 25.2048,
        longitude: 55.2708,
      ),
    ]);

    // Seed sample travel journeys with real map paths and high-definition photography
    _userPosts.addAll([
      // 1. United States - New York Central Park
      UserPost(
        id: 'post_us_1',
        placeId: 'central_park_midtown',
        placeName: 'Central Park Promenade & Bethesda Terrace',
        userId: 'user_alex',
        userName: 'Alex Rivera',
        userHandle: '@alex_smart',
        userAvatar: '',
        caption:
            'Morning jog through The Mall and Bethesda Fountain in Central Park! Beat the NYC crowd and caught sunrise through the elm trees. Path logged below! 🏃‍♂️🍂 #CentralPark #NewYorkRoute',
        photoUrls: [
          'https://images.unsplash.com/photo-1538688525198-9b88f6f53126?w=700&q=75',
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        likedBy: ['local_user_1', 'user_sarah', 'user_david'],
        commentsCount: 8,
        latitude: 40.7829,
        longitude: -73.9654,
        routeSummary: 'Central Park Mall ➔ Bethesda Terrace ➔ The Met',
        routeStops: ['Central Park South', 'Bethesda Terrace', 'The Met'],
        distanceKm: 5.4,
        country: 'United States',
        city: 'New York',
      ),
      // 2. United States - Brooklyn Bridge & DUMBO
      UserPost(
        id: 'post_us_2',
        placeId: 'brooklyn_dumbo',
        placeName: 'Brooklyn Bridge Walkway & DUMBO Waterfront',
        userId: 'user_sarah',
        userName: 'Sarah Jenkins',
        userHandle: '@sarah_city',
        userAvatar: '',
        caption:
            'Crossed the iconic Brooklyn Bridge on foot into DUMBO for sunset skyline views over Lower Manhattan! Smooth pedestrian flow and breezy air. 🌉🗽 #BrooklynBridge #NYCTrail',
        photoUrls: [
          'https://images.unsplash.com/photo-1485871981521-5b1fd3805eee?w=700&q=75',
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        likedBy: ['user_alex', 'local_user_1', 'user_marcus'],
        commentsCount: 12,
        latitude: 40.7061,
        longitude: -73.9969,
        routeSummary: 'City Hall Park ➔ Brooklyn Bridge ➔ DUMBO Pebble Beach',
        routeStops: ['City Hall Park', 'Bridge Tower', 'Pebble Beach DUMBO'],
        distanceKm: 3.8,
        country: 'United States',
        city: 'New York',
      ),
      // 3. United States - Grand Canyon
      UserPost(
        id: 'post_us_3',
        placeId: 'grand_canyon_trail',
        placeName: 'Grand Canyon South Rim & Bright Angel Trail',
        userId: 'user_david',
        userName: 'David Ross',
        userHandle: '@david_transit',
        userAvatar: '',
        caption:
            'Hiked the South Rim trail down towards Indian Garden. The depth of the canyon layers in morning light is completely mind-blowing. Full GPS trail logged! 🏜️🦅 #GrandCanyon #Arizona',
        photoUrls: [
          'https://images.unsplash.com/photo-1474044159687-1ee9f3a51722?w=700&q=75',
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        likedBy: ['user_alex', 'user_sarah', 'user_albanna'],
        commentsCount: 9,
        latitude: 36.0544,
        longitude: -112.1401,
        routeSummary: 'Mather Point ➔ Bright Angel Trail ➔ Ooh Aah Point',
        routeStops: ['Mather Point', 'Bright Angel Trailhead', 'Ooh Aah Point'],
        distanceKm: 15.2,
        country: 'United States',
        city: 'Phoenix',
      ),
      // 4. United States - Golden Gate Bridge
      UserPost(
        id: 'post_us_4',
        placeId: 'golden_gate_marin',
        placeName: 'Golden Gate Bridge & Marin Headlands',
        userId: 'user_albanna',
        userName: 'AL Banna',
        userHandle: '@albanna',
        userAvatar: '',
        caption:
            'Biked across Golden Gate Bridge up to Hawk Hill in Marin Headlands. Clear blue Pacific skies with zero fog today! Smart transit bike lanes were flawless. 🌁🚴 #GoldenGate #SanFrancisco',
        photoUrls: [
          'https://images.unsplash.com/photo-1501594907352-04cda38ebc29?w=700&q=75',
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 9)),
        likedBy: ['user_alex', 'user_sarah', 'user_elena'],
        commentsCount: 15,
        latitude: 37.8199,
        longitude: -122.4783,
        routeSummary: 'Presidio ➔ Golden Gate Bridge ➔ Marin Headlands Vista',
        routeStops: ['Presidio', 'Golden Gate Span', 'Hawk Hill'],
        distanceKm: 12.6,
        country: 'United States',
        city: 'San Francisco',
      ),
      // 5. United States - Miami South Beach
      UserPost(
        id: 'post_us_5',
        placeId: 'miami_south_beach',
        placeName: 'Miami Ocean Drive & Wynwood Art Corridor',
        userId: 'user_elena',
        userName: 'Elena Sato',
        userHandle: '@elena_miami',
        userAvatar: '',
        caption:
            'Cruised from South Beach Ocean Drive art deco buildings into the colorful Wynwood street art district. Electric micromobility lanes made the commute seamless! 🌴🎨 #Miami #Wynwood',
        photoUrls: [
          'https://images.unsplash.com/photo-1506953823976-52e1fdc0149a?w=700&q=75',
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 14)),
        likedBy: ['user_albanna', 'user_david', 'local_user_1'],
        commentsCount: 7,
        latitude: 25.7617,
        longitude: -80.1918,
        routeSummary: 'South Beach ➔ Venetian Causeway ➔ Wynwood Walls',
        routeStops: ['Ocean Drive', 'Venetian Causeway', 'Wynwood'],
        distanceKm: 9.3,
        country: 'United States',
        city: 'Miami',
      ),
      // 6. United States - Yosemite Valley
      UserPost(
        id: 'post_us_6',
        placeId: 'yosemite_valley',
        placeName: 'Yosemite Valley & Tunnel View Scenic Loop',
        userId: 'user_marcus',
        userName: 'Marcus Davies',
        userHandle: '@marcus_us',
        userAvatar: '',
        caption:
            'Witnessed the monumental granite domes of El Capitan and Half Dome from Tunnel View. Nature in its most magnificent form! 🌲🏔️ #Yosemite #CaliforniaTrails',
        photoUrls: [
          'https://images.unsplash.com/photo-1426604966848-d7adac402bff?w=700&q=75',
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 20)),
        likedBy: ['user_alex', 'user_albanna', 'user_sarah'],
        commentsCount: 11,
        latitude: 37.8651,
        longitude: -119.5383,
        routeSummary: 'Wawona Road ➔ Tunnel View ➔ Yosemite Valley Floor',
        routeStops: ['Wawona', 'Tunnel View', 'Valley Floor'],
        distanceKm: 26.4,
        country: 'United States',
        city: 'Los Angeles',
      ),
      // 7. Sri Lanka - Sigiriya
      UserPost(
        id: 'post_1',
        placeId: 'sigiriya_kandy',
        placeName: 'Sigiriya Rock Fortress & Golden Caves',
        userId: 'user_alex',
        userName: 'Alex Rivera',
        userHandle: '@alex_smart',
        userAvatar: '',
        caption:
            'Traveled from Colombo up to Sigiriya Fortress via Dambulla! Sunrise climb at 6:00 AM beat the heat and crowds. Map path logged below. 🦁🌄 #Sigiriya #TravelRoute',
        photoUrls: ['assets/central province/sigiriya.jpg'],
        createdAt: DateTime.now().subtract(const Duration(hours: 22)),
        likedBy: ['local_user_1', 'user_sarah', 'user_david', 'user_elena'],
        commentsCount: 6,
        latitude: 7.9570,
        longitude: 80.7603,
        routeSummary: 'Sigiriya Rock ➔ Dambulla Cave ➔ Kandy Lake',
        routeStops: ['Sigiriya', 'Dambulla', 'Kandy'],
        distanceKm: 92.4,
        country: 'Sri Lanka',
        city: 'Sigiriya',
      ),
      // 8. Sri Lanka - Ella
      UserPost(
        id: 'post_2',
        placeId: 'ella_gap',
        placeName: 'Demodara Nine Arch Bridge & Ella Rock',
        userId: 'user_sarah',
        userName: 'Sarah Jenkins',
        userHandle: '@sarah_city',
        userAvatar: '',
        caption:
            'Epic scenic journey through Ella! Caught the blue express train over Demodara Bridge then trekked to Little Adam\'s Peak. Highly recommend this walking path. 🚂⛰️ #Ella #NineArch',
        photoUrls: ['assets/images/nine_arch_bridge.jpg'],
        createdAt: DateTime.now().subtract(const Duration(hours: 24)),
        likedBy: ['user_alex', 'local_user_1', 'user_marcus'],
        commentsCount: 8,
        latitude: 6.8728,
        longitude: 81.0466,
        routeSummary: 'Ella Station ➔ Demodara Bridge ➔ Little Adam Peak',
        routeStops: ['Ella Station', 'Demodara Bridge', 'Little Adam Peak'],
        distanceKm: 18.6,
        country: 'Sri Lanka',
        city: 'Ella',
      ),
      // 9. Sri Lanka - Galle
      UserPost(
        id: 'post_3',
        placeId: 'galle_coast',
        placeName: 'Galle Dutch Fort & LightHouse Ramparts',
        userId: 'user_david',
        userName: 'David Ross',
        userHandle: '@david_transit',
        userAvatar: '',
        caption:
            'Sunset stroll along the centuries-old ocean ramparts of Galle Fort. Clean cobblestone streets, zero traffic congestion, pure coastal magic. 🌊🏰 #GalleFort #HeritagePath',
        photoUrls: ['assets/images/galle_fort.jpg'],
        createdAt: DateTime.now().subtract(const Duration(hours: 28)),
        likedBy: ['user_alex', 'user_sarah', 'user_albanna'],
        commentsCount: 4,
        latitude: 6.0328,
        longitude: 80.2170,
        routeSummary: 'Mirissa Bay ➔ Galle Dutch Fort ➔ Bentota Beach',
        routeStops: ['Mirissa', 'Galle Fort', 'Bentota'],
        distanceKm: 74.2,
        country: 'Sri Lanka',
        city: 'Galle',
      ),
      // 10. Sri Lanka - Colombo
      UserPost(
        id: 'post_4',
        placeId: 'colombo_nintavur',
        placeName: 'Colombo Lotus Tower & Marine Promenade',
        userId: 'user_albanna',
        userName: 'AL Banna',
        userHandle: '@albanna',
        userAvatar: '',
        caption:
            'Cross-island telemetry expedition: Started at Colombo coastal promenade, traveled east through the central hills, arriving at Nintavur Coastal Hub. All civic sensors active! 📡🇱🇰 #IslandRoute',
        photoUrls: ['assets/western province/galle-face.jpg'],
        createdAt: DateTime.now().subtract(const Duration(hours: 32)),
        likedBy: ['user_alex', 'user_sarah', 'user_elena', 'user_david'],
        commentsCount: 9,
        latitude: 6.9298,
        longitude: 79.8592,
        routeSummary: 'Lotus Tower ➔ Kandy Corridor ➔ Nintavur Hub',
        routeStops: ['Lotus Tower', 'Kandy Corridor', 'Nintavur Hub'],
        distanceKm: 320.5,
        country: 'Sri Lanka',
        city: 'Colombo',
      ),
      // 11. Japan - Tokyo
      UserPost(
        id: 'post_5',
        placeId: 'tokyo_fuji',
        placeName: 'Mount Fuji & Hakone Crater Lake',
        userId: 'user_elena',
        userName: 'Elena Sato',
        userHandle: '@elena_tokyo',
        userAvatar: '',
        caption:
            'Took the Romancecar from Shinjuku out to Hakone, sailed across Lake Ashi, and reached Mount Fuji 5th Station. Clear skies and stunning peak vistas! 🗻🚄 #FujiPath #JapanTravel',
        photoUrls: [
          'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=700&q=75',
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 36)),
        likedBy: ['user_albanna', 'user_alex', 'user_marcus'],
        commentsCount: 11,
        latitude: 35.3606,
        longitude: 138.7274,
        routeSummary: 'Shinjuku ➔ Hakone Lake ➔ Mt. Fuji 5th Station',
        routeStops: ['Shinjuku', 'Hakone', 'Mt. Fuji'],
        distanceKm: 138.0,
        country: 'Japan',
        city: 'Tokyo',
      ),
      // 12. United Kingdom - London
      UserPost(
        id: 'post_6',
        placeId: 'london_thames',
        placeName: 'London Tower Bridge & South Bank Promenade',
        userId: 'user_marcus',
        userName: 'Marcus Davies',
        userHandle: '@marcus_london',
        userAvatar: '',
        caption:
            'Walked along Thames Path from Westminster Bridge past the Tate Modern to Tower Bridge. Clean historic corridors with smart bus connections! 🇬🇧🏰 #LondonPath #ThamesWalk',
        photoUrls: [
          'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=700&q=75',
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 40)),
        likedBy: ['user_alex', 'user_sarah', 'local_user_1'],
        commentsCount: 5,
        latitude: 51.5055,
        longitude: -0.0754,
        routeSummary: 'Westminster ➔ South Bank ➔ Tower Bridge',
        routeStops: ['Westminster', 'South Bank', 'Tower Bridge'],
        distanceKm: 4.8,
        country: 'United Kingdom',
        city: 'London',
      ),
    ]);

    // Seed sample comments
    _comments.addAll([
      Comment(
        id: 'comment_1',
        placeId: 'city_center',
        userId: 'user_sarah',
        userName: 'Sarah K.',
        userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        text: 'Agreed! The bus arrival board is accurate to within 30 seconds.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        likedBy: ['user_alex'],
      ),
    ]);
  }

  List<Comment> getCommentsForPlace(String placeId) {
    return _comments
        .where((c) => c.placeId.toLowerCase() == placeId.toLowerCase())
        .toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<UserPost> getPostsForPlace(String placeId) {
    return _userPosts
        .where((p) => p.placeId.toLowerCase() == placeId.toLowerCase())
        .toList(growable: false)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<TravelerProfile> getTravelersForCountry([String? country]) {
    if (country == null || country.isEmpty) return travelers;
    final c = country.toLowerCase();
    final isUs = c.contains('united states') ||
        c.contains('america') ||
        c.contains('usa') ||
        c == 'us';
    final list = List<TravelerProfile>.from(_travelers);
    list.sort((a, b) {
      final aMatch = isUs
          ? (a.country.toLowerCase().contains('united states') ||
              a.country.toLowerCase().contains('america') ||
              a.country.toLowerCase().contains('usa') ||
              a.country.toLowerCase() == 'us')
          : a.country.toLowerCase().contains(c);
      final bMatch = isUs
          ? (b.country.toLowerCase().contains('united states') ||
              b.country.toLowerCase().contains('america') ||
              b.country.toLowerCase().contains('usa') ||
              b.country.toLowerCase() == 'us')
          : b.country.toLowerCase().contains(c);
      if (aMatch && !bMatch) return -1;
      if (!aMatch && bMatch) return 1;
      return b.followersCount.compareTo(a.followersCount);
    });
    return list;
  }

  List<UserPost> getAllPosts({String? country}) {
    final list = List<UserPost>.from(_userPosts);
    if (country != null && country.isNotEmpty) {
      final c = country.toLowerCase();
      final isUs = c.contains('united states') ||
          c.contains('america') ||
          c.contains('usa') ||
          c == 'us';
      list.sort((a, b) {
        final aMatch = isUs
            ? (a.country?.toLowerCase().contains('united states') == true ||
                a.country?.toLowerCase().contains('america') == true ||
                a.country?.toLowerCase().contains('usa') == true ||
                a.country?.toLowerCase() == 'us')
            : (a.country?.toLowerCase().contains(c) == true);
        final bMatch = isUs
            ? (b.country?.toLowerCase().contains('united states') == true ||
                b.country?.toLowerCase().contains('america') == true ||
                b.country?.toLowerCase().contains('usa') == true ||
                b.country?.toLowerCase() == 'us')
            : (b.country?.toLowerCase().contains(c) == true);
        if (aMatch && !bMatch) return -1;
        if (!aMatch && bMatch) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
    } else {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  List<UserPost> getAlgorithmAlignedPosts({String? country}) {
    final posts = List<UserPost>.from(_userPosts);
    final c = country?.toLowerCase();
    final isUs = c != null &&
        (c.contains('united states') ||
            c.contains('america') ||
            c.contains('usa') ||
            c == 'us');

    posts.sort((a, b) {
      if (country != null && country.isNotEmpty) {
        final aMatch = isUs
            ? (a.country?.toLowerCase().contains('united states') == true ||
                a.country?.toLowerCase().contains('america') == true ||
                a.country?.toLowerCase().contains('usa') == true ||
                a.country?.toLowerCase() == 'us')
            : (a.country?.toLowerCase().contains(c!) == true);
        final bMatch = isUs
            ? (b.country?.toLowerCase().contains('united states') == true ||
                b.country?.toLowerCase().contains('america') == true ||
                b.country?.toLowerCase().contains('usa') == true ||
                b.country?.toLowerCase() == 'us')
            : (b.country?.toLowerCase().contains(c!) == true);
        if (aMatch && !bMatch) return -1;
        if (!aMatch && bMatch) return 1;
      }
      final aAgeHours = DateTime.now().difference(a.createdAt).inHours;
      final bAgeHours = DateTime.now().difference(b.createdAt).inHours;
      final aScore = (a.likesCount * 2) + a.commentsCount - aAgeHours;
      final bScore = (b.likesCount * 2) + b.commentsCount - bAgeHours;
      return bScore.compareTo(aScore);
    });
    return posts;
  }

  Future<void> addComment(
    String placeId,
    String text, {
    List<String>? photoUrls,
  }) async {
    final uid = currentUserId;
    if (text.trim().isEmpty) return;

    final newComment = Comment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      placeId: placeId,
      userId: uid,
      userName: _currentUserName,
      userAvatar: '',
      text: text.trim(),
      createdAt: DateTime.now(),
      photoUrls: photoUrls,
    );

    _comments.insert(0, newComment);
    notifyListeners();
  }

  Future<void> toggleCommentLike(String commentId) async {
    final uid = currentUserId;
    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index == -1) return;

    final comment = _comments[index];
    final liked = List<String>.from(comment.likedBy);
    if (liked.contains(uid)) {
      liked.remove(uid);
    } else {
      liked.add(uid);
    }

    _comments[index] = Comment(
      id: comment.id,
      placeId: comment.placeId,
      userId: comment.userId,
      userName: comment.userName,
      userAvatar: comment.userAvatar,
      text: comment.text,
      createdAt: comment.createdAt,
      likedBy: liked,
      photoUrls: comment.photoUrls,
    );

    notifyListeners();
  }

  Future<List<String>> uploadPostImages(List<Uint8List> imageBytes) async {
    return imageBytes
        .map((bytes) => 'data:image/jpeg;base64,${base64Encode(bytes)}')
        .toList();
  }

  void syncCurrentUser({
    required String uid,
    required String username,
    required String displayName,
    String country = 'Sri Lanka',
    String city = 'Nintavur',
    String countryFlag = '🇱🇰',
  }) {
    final cleanUsername = username.replaceAll('@', '').trim().toLowerCase();
    final existingIdx = _travelers.indexWhere(
      (t) => t.username.toLowerCase() == cleanUsername || t.uid == uid,
    );
    final profile = TravelerProfile(
      uid: uid,
      username: cleanUsername,
      displayName: displayName.isNotEmpty ? displayName : cleanUsername,
      avatarUrl: '',
      bio: 'Verified Citizen & Global Smart City Steward',
      country: country,
      city: city,
      countryFlag: countryFlag,
      followersCount: 180,
      placesTraveledCount: 7,
      routesSharedCount: 3,
      isVerified: true,
      recentRoute: '$city Corridor ➔ Smart City Civic Hub',
      locationSharingEnabled: true,
    );

    if (existingIdx >= 0) {
      _travelers[existingIdx] = profile;
    } else {
      _travelers.insert(0, profile);
    }
    _currentUserId = uid;
    _currentUserName = displayName.isNotEmpty ? displayName : cleanUsername;
    notifyListeners();
  }

  Future<void> addUserPost({
    required String placeId,
    required String placeName,
    String? caption,
    required List<String> photoUrls,
    double? latitude,
    double? longitude,
    String? routeSummary,
    List<String>? routeStops,
    double? distanceKm,
    String? country,
    String? city,
  }) async {
    final uid = currentUserId;

    final newPost = UserPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      placeId: placeId,
      placeName: placeName,
      userId: uid,
      userName: _currentUserName,
      userAvatar: '',
      caption: caption?.trim(),
      photoUrls: photoUrls,
      createdAt: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      routeSummary: routeSummary,
      routeStops: routeStops,
      distanceKm: distanceKm,
      country: country,
      city: city,
    );

    _userPosts.insert(0, newPost);
    notifyListeners();
  }

  Future<void> togglePostLike(String postId) async {
    final uid = currentUserId;
    final index = _userPosts.indexWhere((p) => p.id == postId);
    if (index == -1) return;

    final post = _userPosts[index];
    final liked = List<String>.from(post.likedBy);
    if (liked.contains(uid)) {
      liked.remove(uid);
    } else {
      liked.add(uid);
      if (post.userId != uid) {
        _addNotification(
          recipientId: post.userId,
          type: 'like',
          title: 'New like',
          body: '@$_currentUserName liked your post at ${post.placeName}.',
        );
      }
    }

    _userPosts[index] = post.copyWith(likedBy: liked);
    notifyListeners();
  }

  Stream<List<Comment>> streamCommentsForPost(String postId) {
    final controller = _postCommentsControllers.putIfAbsent(
      postId,
      () => StreamController<List<Comment>>.broadcast(),
    );

    Future.microtask(() {
      final postComments = _comments.where((c) => c.placeId == postId).toList();
      controller.add(postComments);
    });

    return controller.stream;
  }

  Future<void> addPostComment({
    required String postId,
    required String text,
  }) async {
    final uid = currentUserId;
    if (text.trim().isEmpty) return;

    final index = _userPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final p = _userPosts[index];
      _userPosts[index] = p.copyWith(commentsCount: p.commentsCount + 1);
      if (p.userId != uid) {
        _addNotification(
          recipientId: p.userId,
          type: 'comment',
          title: 'New comment',
          body: '@$_currentUserName commented on your post.',
        );
      }
    }

    final comment = Comment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      placeId: postId,
      userId: uid,
      userName: _currentUserName,
      userAvatar: '',
      text: text.trim(),
      createdAt: DateTime.now(),
    );
    _comments.insert(0, comment);

    final controller = _postCommentsControllers[postId];
    if (controller != null && !controller.isClosed) {
      final postComments = _comments.where((c) => c.placeId == postId).toList();
      controller.add(postComments);
    }

    notifyListeners();
  }

  Future<void> toggleSavePost(UserPost post) async {
    if (_savedPostIds.contains(post.id)) {
      _savedPostIds.remove(post.id);
    } else {
      _savedPostIds.add(post.id);
    }
    notifyListeners();
  }

  bool isPostSaved(String postId) => _savedPostIds.contains(postId);

  List<TravelerProfile> searchTravelers(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return travelers;
    return _travelers
        .where(
          (t) =>
              t.username.toLowerCase().contains(q) ||
              t.displayName.toLowerCase().contains(q),
        )
        .toList(growable: false);
  }

  bool isFollowing(String travelerId) => _followingIds.contains(travelerId);

  Future<void> toggleFollow(String travelerId) async {
    final uid = currentUserId;
    if (travelerId == uid) return;

    if (_followingIds.contains(travelerId)) {
      _followingIds.remove(travelerId);
    } else {
      _followingIds.add(travelerId);
      _addNotification(
        recipientId: travelerId,
        type: 'follow',
        title: 'New follower',
        body: '@$_currentUserName started following you.',
      );
    }
    notifyListeners();
  }

  Future<bool> setLocationSharing(bool enabled) async {
    if (!enabled) {
      await _locationSub?.cancel();
      _locationSub = null;
      _locationSharingEnabled = false;
      notifyListeners();
      return true;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    _locationSharingEnabled = true;
    try {
      final initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _myPosition = initialPosition;
    } catch (_) {}

    _locationSub?.cancel();
    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
      ),
    ).listen((position) {
      _myPosition = position;
      notifyListeners();
    });

    notifyListeners();
    return true;
  }

  double? distanceToTraveler(TravelerProfile traveler) {
    if (_myPosition == null ||
        traveler.latitude == null ||
        traveler.longitude == null) {
      return null;
    }
    return Geolocator.distanceBetween(
      _myPosition!.latitude,
      _myPosition!.longitude,
      traveler.latitude!,
      traveler.longitude!,
    );
  }

  String chatRoomIdFor(String peerId) {
    final uid = currentUserId;
    final sorted = [uid, peerId]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Stream<List<ChatMessage>> streamChatMessages(String peerId) {
    final roomId = chatRoomIdFor(peerId);
    final controller = _chatControllers.putIfAbsent(
      roomId,
      () => StreamController<List<ChatMessage>>.broadcast(),
    );

    Future.microtask(() {
      final msgs = _chatRooms[roomId] ?? [];
      controller.add(List.unmodifiable(msgs.reversed));
    });

    return controller.stream;
  }

  Future<void> sendChatMessage({
    required String peerId,
    required String text,
  }) async {
    final body = text.trim();
    if (body.isEmpty) return;

    final roomId = chatRoomIdFor(peerId);
    final newMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      roomId: roomId,
      senderId: currentUserId,
      senderName: _currentUserName,
      text: body,
      createdAt: DateTime.now(),
    );

    _chatRooms.putIfAbsent(roomId, () => []).add(newMsg);

    final controller = _chatControllers[roomId];
    if (controller != null && !controller.isClosed) {
      final msgs = _chatRooms[roomId] ?? [];
      controller.add(List.unmodifiable(msgs.reversed));
    }

    _addNotification(
      recipientId: peerId,
      type: 'chat',
      title: 'New message',
      body: '@$_currentUserName: $body',
    );
  }

  Stream<SocialNotificationSnapshot> notificationsStream() {
    Future.microtask(() {
      _notifController.add(SocialNotificationSnapshot(_notifications));
    });
    return _notifController.stream;
  }

  Future<void> markNotificationRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      final existing = _notifications[index];
      final updatedData = Map<String, dynamic>.from(existing.data());
      updatedData['isRead'] = true;
      _notifications[index] = SocialNotificationDoc(existing.id, updatedData);
      _notifController.add(SocialNotificationSnapshot(_notifications));
    }
  }

  void _addNotification({
    required String recipientId,
    required String type,
    required String title,
    required String body,
  }) {
    final notif = SocialNotificationDoc(
      'notif_${DateTime.now().millisecondsSinceEpoch}',
      {
        'recipientId': recipientId,
        'senderId': currentUserId,
        'type': type,
        'title': title,
        'body': body,
        'isRead': false,
        'createdAt': DateTime.now(),
      },
    );
    _notifications.insert(0, notif);
    _notifController.add(SocialNotificationSnapshot(_notifications));
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    _notifController.close();
    for (final c in _chatControllers.values) {
      c.close();
    }
    for (final c in _postCommentsControllers.values) {
      c.close();
    }
    super.dispose();
  }
}
