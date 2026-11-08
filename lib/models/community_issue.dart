import 'package:latlong2/latlong.dart';
import 'ai_hazard_analysis.dart';

enum IssueStatus {
  pending,
  inProgress,
  resolved,
}

class CommunityIssue {
  final String id;
  final String category;
  final String categoryLocal;
  final String title;
  final String description;
  final String address;
  final LatLng location;
  final IssueStatus status;
  final String contactNumber;
  final String? imagePath;
  final bool hasAudio;
  final DateTime createdAt;
  final AiHazardAnalysis? aiAnalysis;

  CommunityIssue({
    required this.id,
    required this.category,
    required this.categoryLocal,
    required this.title,
    required this.description,
    required this.address,
    required this.location,
    this.status = IssueStatus.pending,
    required this.contactNumber,
    this.imagePath,
    this.hasAudio = false,
    required this.createdAt,
    this.aiAnalysis,
  });

  CommunityIssue copyWith({
    String? id,
    String? category,
    String? categoryLocal,
    String? title,
    String? description,
    String? address,
    LatLng? location,
    IssueStatus? status,
    String? contactNumber,
    String? imagePath,
    bool? hasAudio,
    DateTime? createdAt,
    AiHazardAnalysis? aiAnalysis,
  }) {
    return CommunityIssue(
      id: id ?? this.id,
      category: category ?? this.category,
      categoryLocal: categoryLocal ?? this.categoryLocal,
      title: title ?? this.title,
      description: description ?? this.description,
      address: address ?? this.address,
      location: location ?? this.location,
      status: status ?? this.status,
      contactNumber: contactNumber ?? this.contactNumber,
      imagePath: imagePath ?? this.imagePath,
      hasAudio: hasAudio ?? this.hasAudio,
      createdAt: createdAt ?? this.createdAt,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'categoryLocal': categoryLocal,
      'title': title,
      'description': description,
      'address': address,
      'lat': location.latitude,
      'lng': location.longitude,
      'status': status.name,
      'contactNumber': contactNumber,
      'imagePath': imagePath,
      'hasAudio': hasAudio,
      'createdAt': createdAt.toIso8601String(),
      'aiAnalysis': aiAnalysis?.toJson(),
    };
  }

  factory CommunityIssue.fromJson(Map<String, dynamic> json) {
    return CommunityIssue(
      id: json['id'] as String,
      category: json['category'] as String,
      categoryLocal: json['categoryLocal'] as String? ?? '',
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      address: json['address'] as String,
      location: LatLng(
        (json['lat'] as num).toDouble(),
        (json['lng'] as num).toDouble(),
      ),
      status: IssueStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => IssueStatus.pending,
      ),
      contactNumber: json['contactNumber'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
      hasAudio: json['hasAudio'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      aiAnalysis: json['aiAnalysis'] != null
          ? AiHazardAnalysis.fromJson(json['aiAnalysis'] as Map<String, dynamic>)
          : null,
    );
  }
}

