import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileService extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  String _displayName = '';
  String _bio = '';
  String _location = '';
  final DateTime _memberSince = DateTime.now();

  Uint8List? _avatarBytes;
  final List<Uint8List> _uploadedPhotos = [];

  String get displayName => _displayName;
  String get bio => _bio;
  String get location => _location;
  DateTime get memberSince => _memberSince;
  Uint8List? get avatarBytes => _avatarBytes;
  List<Uint8List> get uploadedPhotos => List.unmodifiable(_uploadedPhotos);

  int get tripsCount => (_uploadedPhotos.length / 2).ceil().clamp(0, 999);
  int get reviewsCount => 48 + _uploadedPhotos.length;
  String get milesText =>
      '${(2.4 + (_uploadedPhotos.length * 0.1)).toStringAsFixed(1)}k';

  Future<bool> pickAvatarFromGallery() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return false;

      _avatarBytes = await file.readAsBytes();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addPostFromGallery() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file == null) return false;

      final bytes = await file.readAsBytes();
      _uploadedPhotos.insert(0, bytes);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void updateProfile({
    required String displayName,
    required String bio,
    required String location,
  }) {
    _displayName = displayName.trim().isEmpty
        ? _displayName
        : displayName.trim();
    _bio = bio.trim().isEmpty ? _bio : bio.trim();
    _location = location.trim().isEmpty ? _location : location.trim();
    notifyListeners();
  }
}
