import '../entities/content_entity.dart';

abstract class ContentRepository {
  Future<List<ContentEntity>> getContents();
  Future<void> saveContent({
    String? id,
    required String title,
    required String description,
    required String type,
    String? bodyText,
    String? mediaFilePath,
    String? coverImagePath,
    bool isPublished,
  });
}
