class TravelerProfile {
  final String uid;
  final String username;
  final String displayName;
  final String avatarUrl;
  final bool locationSharingEnabled;
  final double? latitude;
  final double? longitude;
  final DateTime? locationUpdatedAt;

  const TravelerProfile({
    required this.uid,
    required this.username,
    required this.displayName,
    this.avatarUrl = '',
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
      locationSharingEnabled: map['locationSharingEnabled'] == true,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      locationUpdatedAt: locationUpdatedAt,
    );
  }
}
