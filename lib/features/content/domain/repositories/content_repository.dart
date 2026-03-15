import '../entities/content_entity.dart';

/// Contrato del repositorio de contenido educativo.
///
/// Obtiene contenidos publicados y permite crear/actualizar contenidos
/// (admin). Los archivos multimedia se suben a Supabase Storage.
abstract class ContentRepository {
  /// Obtiene la lista de contenidos publicados.
  Future<List<ContentEntity>> getContents();

  /// Crea o actualiza un contenido. Si [id] es null, crea uno nuevo.
  /// [mediaFilePath] y [coverImagePath] son rutas locales que se suben a Storage.
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
