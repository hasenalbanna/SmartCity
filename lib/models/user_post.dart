class UserPost {
  final String id;
  final String placeId;
  final String placeName;
  final String userId;
  final String userName;
  final String userHandle;
  final String userAvatar;
  final String? caption;
  final List<String> photoUrls;
  final DateTime createdAt;
  final List<String> likedBy;
  final int commentsCount;
  final double? latitude;
  final double? longitude;
  final String? routeSummary;
  final List<String>? routeStops;
  final double? distanceKm;
  final String? country;
  final String? city;

  UserPost({
    required this.id,
    required this.placeId,
    required this.placeName,
    required this.userId,
    required this.userName,
    String? userHandle,
    required this.userAvatar,
    this.caption,
    required this.photoUrls,
    required this.createdAt,
    this.likedBy = const [],
    this.commentsCount = 0,
    this.latitude,
    this.longitude,
    this.routeSummary,
    this.routeStops,
    this.distanceKm,
    this.country,
    this.city,
  }) : userHandle = userHandle ?? (userName.startsWith('@') ? userName : '@${userName.toLowerCase().replaceAll(' ', '_')}');

  int get likesCount => likedBy.length;

  bool isLikedBy(String usrId) => likedBy.contains(usrId);

  factory UserPost.fromMap(String id, Map<String, dynamic> map) {
    final createdRaw = map['createdAt'];
    final createdAt = createdRaw is DateTime
        ? createdRaw
        : DateTime.tryParse('${map['createdAt']}') ?? DateTime.now();

    final uName = (map['userName'] ?? 'Traveler').toString();
    final uHandle = map['userHandle']?.toString() ??
        (uName.startsWith('@') ? uName : '@${uName.toLowerCase().replaceAll(' ', '_')}');

    return UserPost(
      id: id,
      placeId: (map['placeId'] ?? '').toString(),
      placeName: (map['placeName'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      userName: uName,
      userHandle: uHandle,
      userAvatar: (map['userAvatar'] ?? '').toString(),
      caption: map['caption']?.toString(),
      photoUrls: List<String>.from(map['photoUrls'] ?? const []),
      createdAt: createdAt,
      likedBy: List<String>.from(map['likedBy'] ?? const []),
      commentsCount: (map['commentsCount'] as num?)?.toInt() ?? 0,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      routeSummary: map['routeSummary']?.toString(),
      routeStops: map['routeStops'] != null
          ? List<String>.from(map['routeStops'])
          : null,
      distanceKm: (map['distanceKm'] as num?)?.toDouble(),
      country: map['country']?.toString(),
      city: map['city']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'placeId': placeId,
      'placeName': placeName,
      'userId': userId,
      'userName': userName,
      'userHandle': userHandle,
      'userAvatar': userAvatar,
      'caption': caption,
      'photoUrls': photoUrls,
      'createdAt': createdAt.toIso8601String(),
      'likedBy': likedBy,
      'commentsCount': commentsCount,
      'latitude': latitude,
      'longitude': longitude,
      'routeSummary': routeSummary,
      'routeStops': routeStops,
      'distanceKm': distanceKm,
      'country': country,
      'city': city,
    };
  }

  UserPost copyWith({
    String? id,
    String? placeId,
    String? placeName,
    String? userId,
    String? userName,
    String? userHandle,
    String? userAvatar,
    String? caption,
    List<String>? photoUrls,
    DateTime? createdAt,
    List<String>? likedBy,
    int? commentsCount,
    double? latitude,
    double? longitude,
    String? routeSummary,
    List<String>? routeStops,
    double? distanceKm,
    String? country,
    String? city,
  }) {
    return UserPost(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userHandle: userHandle ?? this.userHandle,
      userAvatar: userAvatar ?? this.userAvatar,
      caption: caption ?? this.caption,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt ?? this.createdAt,
      likedBy: likedBy ?? this.likedBy,
      commentsCount: commentsCount ?? this.commentsCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      routeSummary: routeSummary ?? this.routeSummary,
      routeStops: routeStops ?? this.routeStops,
      distanceKm: distanceKm ?? this.distanceKm,
      country: country ?? this.country,
      city: city ?? this.city,
    );
  }

  // Compatibility getters for UI widgets
  String get authorName => userName;
  String get authorAvatar => userAvatar;
  String get imageUrl => photoUrls.isNotEmpty ? photoUrls.first : '';
  String get location => placeName;
  int get likes => likedBy.length;
}
