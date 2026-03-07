import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/content_entity.dart';

abstract class ContentRemoteDataSource {
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

class ContentRemoteDataSourceImpl implements ContentRemoteDataSource {
  final SupabaseClient _client;
  const ContentRemoteDataSourceImpl(this._client);

  // Obtener todos los contenidos educativos
  @override
  Future<List<ContentEntity>> getContents() async {
    final data = await _client
        .from('educational_content')
        .select()
        .order('created_at', ascending: false);

    return (data as List)
        .map((row) => ContentEntity(
              id: row['id'] as String,
              createdByAdminId: row['created_by_admin_id'] as String,
              title: row['title'] as String,
              description: row['description'] as String,
              type: row['type'] as String,
              bodyText: row['body_text'] as String?,
              mediaUrl: row['media_url'] as String?,
              coverImageUrl: row['cover_image_url'] as String?,
              isPublished: row['is_published'] as bool,
              createdAt: DateTime.parse(row['created_at'] as String),
              updatedAt: DateTime.parse(row['updated_at'] as String),
            ))
        .toList();
  }

  // Guardar un contenido educativo
  @override
  Future<void> saveContent({
    String? id,
    required String title,
    required String description,
    required String type,
    String? bodyText,
    String? mediaFilePath,
    String? coverImagePath,
    bool isPublished = false,
  }) async {
    final userId = _client.auth.currentUser?.id;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Subir imagen de portada si se proporciona un archivo local
    String? coverImageUrl;
    if (coverImagePath != null) {
      final ext = coverImagePath.split('.').last.toLowerCase();
      final objectPath = 'covers/$userId/$timestamp.$ext';
      await _client.storage.from('content_media').upload(
            objectPath,
            File(coverImagePath),
            fileOptions: const FileOptions(upsert: true),
          );
      coverImageUrl = _client.storage
          .from('content_media')
          .getPublicUrl(objectPath);
    }

    // Subir archivo multimedia si se proporciona un archivo local
    String? mediaUrl;
    if (mediaFilePath != null) {
      final ext = mediaFilePath.split('.').last.toLowerCase();
      final folder = type.toLowerCase();
      final objectPath = '$folder/$userId/$timestamp.$ext';
      await _client.storage.from('content_media').upload(
            objectPath,
            File(mediaFilePath),
            fileOptions: const FileOptions(upsert: true),
          );
      mediaUrl = _client.storage
          .from('content_media')
          .getPublicUrl(objectPath);
    }

    final payload = <String, dynamic>{
      'title': title,
      'description': description,
      'type': type,
      'is_published': isPublished,
      if (bodyText != null && bodyText.isNotEmpty) 'body_text': bodyText,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
    };

    if (id != null) {
      await _client
          .from('educational_content')
          .update(payload)
          .eq('id', id);
    } else {
      await _client.from('educational_content').insert({
        ...payload,
        'created_by_admin_id': userId,
      });
    }
  }
}
