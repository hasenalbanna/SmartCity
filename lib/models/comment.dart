class Comment {
  final String id;
  final String placeId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String text;
  final DateTime createdAt;
  final List<String> likedBy;
  final List<String>? photoUrls;

  Comment({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.text,
    required this.createdAt,
    this.likedBy = const [],
    this.photoUrls,
  });

  int get likesCount => likedBy.length;

  bool isLikedBy(String userId) => likedBy.contains(userId);

  factory Comment.fromMap(String id, Map<String, dynamic> map) {
    final createdRaw = map['createdAt'];
    final createdAt = createdRaw is DateTime
        ? createdRaw
        : DateTime.tryParse('${map['createdAt']}') ?? DateTime.now();

    return Comment(
      id: id,
      placeId: (map['placeId'] ?? '').toString(),
      userId: (map['userId'] ?? '').toString(),
      userName: (map['userName'] ?? 'Traveler').toString(),
      userAvatar: (map['userAvatar'] ?? '').toString(),
      text: (map['text'] ?? '').toString(),
      createdAt: createdAt,
      likedBy: List<String>.from(map['likedBy'] ?? const []),
      photoUrls: (map['photoUrls'] as List?)?.map((e) => '$e').toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'placeId': placeId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'likedBy': likedBy,
      'photoUrls': photoUrls,
    };
  }

  Comment copyWith({
    String? id,
    String? placeId,
    String? userId,
    String? userName,
    String? userAvatar,
    String? text,
    DateTime? createdAt,
    List<String>? likedBy,
    List<String>? photoUrls,
  }) {
    return Comment(
      id: id ?? this.id,
      placeId: placeId ?? this.placeId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      likedBy: likedBy ?? this.likedBy,
      photoUrls: photoUrls ?? this.photoUrls,
    );
  }
}
