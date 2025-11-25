class FloorPlan {
  final String id;
  final String name;
  final String imageUrl;
  final DateTime uploadedAt;
  final int version;

  FloorPlan({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.uploadedAt,
    required this.version,
  });
}
