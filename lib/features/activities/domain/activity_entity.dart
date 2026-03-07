class ActivityEntity {
  final String id;
  final String title;
  final String description;
  final String category;
  final bool isActive;
  final DateTime createdAt;

  const ActivityEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.isActive,
    required this.createdAt,
  });
}
