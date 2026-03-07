class ContentEntity {
  final String id;
  final String createdByAdminId;
  final String title;
  final String description;
  final String type; // 'TEXTO' | 'AUDIO' | 'VIDEO'
  final String? bodyText;
  final String? mediaUrl;
  final String? coverImageUrl;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ContentEntity({
    required this.id,
    required this.createdByAdminId,
    required this.title,
    required this.description,
    required this.type,
    this.bodyText,
    this.mediaUrl,
    this.coverImageUrl,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });
}
