class Guide {
  final String id;
  final String name;
  final String expertise;
  final double rating;
  final String imageAsset;
  final String bio;
  final String languages;
  // Enhanced fields
  final int yearsOfExperience;
  final double dailyRate;
  final int reviewCount;
  final List<String> availability; // Days available
  final String? photoUrl;
  final List<String> specializations;
  final bool isVerified;
  final String location;

  Guide({
    required this.id,
    required this.name,
    required this.expertise,
    required this.rating,
    required this.imageAsset,
    required this.bio,
    required this.languages,
    this.yearsOfExperience = 5,
    this.dailyRate = 50.0,
    this.reviewCount = 0,
    this.availability = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    this.photoUrl,
    this.specializations = const [],
    this.isVerified = false,
    this.location = 'Colombo',
  });
}
