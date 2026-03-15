/// Entidad de dominio que representa un contenido educativo.
///
/// Los contenidos son creados por administradores y pueden ser de tipo texto,
/// audio o video. Se muestran en la pestaña Contenido para los adolescentes.
class ContentEntity {
  /// Identificador único del contenido.
  final String id;

  /// ID del administrador que creó el contenido.
  final String createdByAdminId;

  /// Título del contenido.
  final String title;

  /// Descripción breve.
  final String description;

  /// Tipo de contenido: 'TEXTO', 'AUDIO' o 'VIDEO'.
  final String type;

  /// Texto del contenido (para tipo TEXTO).
  final String? bodyText;

  /// URL del archivo multimedia en Storage (para AUDIO/VIDEO).
  final String? mediaUrl;

  /// URL de la imagen de portada (opcional).
  final String? coverImageUrl;

  /// Si está publicado y visible para los usuarios.
  final bool isPublished;

  /// Fecha de creación.
  final DateTime createdAt;

  /// Fecha de última actualización.
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
