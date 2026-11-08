class UserPost {
  final String id;
  final String placeId;
  final String placeName;
  final String userId;
  final String userName;
  final String userAvatar;
  final String? caption;
  final List<String> photoUrls;
  final DateTime createdAt;
  final List<String> likedBy;
  final int commentsCount;
  final double? latitude;
  final double? longitude;

  UserPost({
    required this.id,
    required this.placeId,
    required this.placeName,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    this.caption,
    required this.photoUrls,
    required this.createdAt,
    this.likedBy = const [],
    this.commentsCount = 0,
    this.latitude,
    this.longitude,
  });

  int get likesCount => likedBy.length;

  bool isLikedBy(String usrId) => likedBy.contains(usrId);

  factory UserPost.fromMap(String id, Map<String, dynamic> map) {
    final createdRaw = map['createdAt'];
    final createdAt = createdRaw is DateTime
        ? createdRaw
        : DateTime.tryParse('${map['createdAt']}') ?? DateTime.now();

    return UserPost(
      id: id,
      placeId: (map['placeId'] ?? '').toString(),
      placeName: (map['placeName'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      userName: (map['userName'] ?? 'Traveler').toString(),
      userAvatar: (map['userAvatar'] ?? '').toString(),
      caption: map['caption']?.toString(),
      photoUrls: List<String>.from(map['photoUrls'] ?? const []),
      createdAt: createdAt,
      likedBy: List<String>.from(map['likedBy'] ?? const []),
      commentsCount: (map['commentsCount'] as num?)?.toInt() ?? 0,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'placeId': placeId,
      'placeName': placeName,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'caption': caption,
      'photoUrls': photoUrls,
      'createdAt': createdAt.toIso8601String(),
      'likedBy': likedBy,
      'commentsCount': commentsCount,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  UserPost copyWith({
    String? id,
    String? placeId,
    String? placeName,
    String? userId,
    String? userName,
    String? userAvatar,
    String? caption,
    List<String>? photoUrls,
    DateTime? createdAt,
    List<String>? likedBy,
    int? commentsCount,
    double? latitude,
    double? longitude,
  }) {
    return UserPost(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      placeName: placeName ?? this.placeName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      caption: caption ?? this.caption,
      photoUrls: photoUrls ?? this.photoUrls,
      createdAt: createdAt ?? this.createdAt,
      likedBy: likedBy ?? this.likedBy,
      commentsCount: commentsCount ?? this.commentsCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
