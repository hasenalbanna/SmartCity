class TravelPackage {
  final String id;
  final String title;
  final String duration;
  final double price;
  final String description;
  final String imageAsset;
  final String guideId;
  final List<String> itinerary;

  TravelPackage({
    required this.id,
    required this.title,
    required this.duration,
    required this.price,
    required this.description,
    required this.imageAsset,
    required this.guideId,
    required this.itinerary,
  });
}
