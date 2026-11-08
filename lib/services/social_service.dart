import 'dart:async';

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
    // Seed sample travelers
    _travelers.addAll([
      const TravelerProfile(
        uid: 'user_alex',
        username: 'alex_smart',
        displayName: 'Alex M.',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        locationSharingEnabled: true,
        latitude: 6.9271,
        longitude: 79.8612,
      ),
      const TravelerProfile(
        uid: 'user_sarah',
        username: 'sarah_city',
        displayName: 'Sarah K.',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        locationSharingEnabled: true,
        latitude: 6.9319,
        longitude: 79.8478,
      ),
      const TravelerProfile(
        uid: 'user_david',
        username: 'david_transit',
        displayName: 'David R.',
        avatarUrl: 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150',
        locationSharingEnabled: false,
      ),
    ]);

    // Seed sample posts
    _userPosts.addAll([
      UserPost(
        id: 'post_1',
        placeId: 'city_center',
        placeName: 'City Center Plaza',
        userId: 'user_alex',
        userName: 'Alex M.',
        userAvatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        caption: 'The newly upgraded smart transit hub is now fully operational! Very smooth commute today.',
        photoUrls: [
          'https://images.unsplash.com/photo-1477959858617-67f30bc75b82?w=800',
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likedBy: ['local_user_1', 'user_sarah'],
        commentsCount: 3,
        latitude: 6.9271,
        longitude: 79.8612,
      ),
      UserPost(
        id: 'post_2',
        placeId: 'green_park',
        placeName: 'Eco Central Park',
        userId: 'user_sarah',
        userName: 'Sarah K.',
        userAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        caption: 'Solar charging stations and high-speed public Wi-Fi working great throughout the park gardens.',
        photoUrls: [
          'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=800',
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likedBy: ['user_alex'],
        commentsCount: 1,
        latitude: 6.9319,
        longitude: 79.8478,
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

  List<UserPost> getAllPosts() {
    return List<UserPost>.from(_userPosts)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<UserPost> getAlgorithmAlignedPosts() {
    final posts = List<UserPost>.from(_userPosts);
    posts.sort((a, b) {
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
    // Local image handler (returns placeholder for uploaded images)
    return imageBytes.map((_) => 'https://images.unsplash.com/photo-1477959858617-67f30bc75b82?w=800').toList();
  }

  Future<void> addUserPost({
    required String placeId,
    required String placeName,
    String? caption,
    required List<String> photoUrls,
    double? latitude,
    double? longitude,
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

    _userPosts[index] = UserPost(
      id: post.id,
      placeId: post.placeId,
      placeName: post.placeName,
      userId: post.userId,
      userName: post.userName,
      userAvatar: post.userAvatar,
      caption: post.caption,
      photoUrls: post.photoUrls,
      createdAt: post.createdAt,
      likedBy: liked,
      commentsCount: post.commentsCount,
      latitude: post.latitude,
      longitude: post.longitude,
    );

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
      _userPosts[index] = UserPost(
        id: p.id,
        placeId: p.placeId,
        placeName: p.placeName,
        userId: p.userId,
        userName: p.userName,
        userAvatar: p.userAvatar,
        caption: p.caption,
        photoUrls: p.photoUrls,
        createdAt: p.createdAt,
        likedBy: p.likedBy,
        commentsCount: p.commentsCount + 1,
        latitude: p.latitude,
        longitude: p.longitude,
      );

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
