class TravelerProfile {
  final String uid;
  final String username;
  final String displayName;
  final String avatarUrl;
  final String bio;
  final String country;
  final String city;
  final String countryFlag;
  final int followersCount;
  final int placesTraveledCount;
  final int routesSharedCount;
  final bool isVerified;
  final String? recentRoute;
  final bool locationSharingEnabled;
  final double? latitude;
  final double? longitude;
  final DateTime? locationUpdatedAt;

  const TravelerProfile({
    required this.uid,
    required this.username,
    required this.displayName,
    this.avatarUrl = '',
    this.bio = 'Active Smart City Explorer & Community Steward',
    this.country = 'Sri Lanka',
    this.city = 'Nintavur',
    this.countryFlag = '🇱🇰',
    this.followersCount = 142,
    this.placesTraveledCount = 8,
    this.routesSharedCount = 3,
    this.isVerified = true,
    this.recentRoute,
    this.locationSharingEnabled = false,
    this.latitude,
    this.longitude,
    this.locationUpdatedAt,
  });

  factory TravelerProfile.fromMap(String uid, Map<String, dynamic> map) {
    final ts = map['locationUpdatedAt'];
    DateTime? locationUpdatedAt;
    if (ts is DateTime) {
      locationUpdatedAt = ts;
    } else {
      locationUpdatedAt = DateTime.tryParse('${map['locationUpdatedAt']}');
    }

    return TravelerProfile(
      uid: uid,
      username: (map['username'] ?? '').toString(),
      displayName: (map['displayName'] ?? 'Traveler').toString(),
      avatarUrl: (map['avatarUrl'] ?? '').toString(),
      bio: (map['bio'] ?? 'Active Smart City Explorer & Community Steward').toString(),
      country: (map['country'] ?? 'Sri Lanka').toString(),
      city: (map['city'] ?? 'Nintavur').toString(),
      countryFlag: (map['countryFlag'] ?? '🇱🇰').toString(),
      followersCount: (map['followersCount'] as num?)?.toInt() ?? 120,
      placesTraveledCount: (map['placesTraveledCount'] as num?)?.toInt() ?? 5,
      routesSharedCount: (map['routesSharedCount'] as num?)?.toInt() ?? 2,
      isVerified: map['isVerified'] != false,
      recentRoute: map['recentRoute']?.toString(),
      locationSharingEnabled: map['locationSharingEnabled'] == true,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      locationUpdatedAt: locationUpdatedAt,
    );
  }
}
