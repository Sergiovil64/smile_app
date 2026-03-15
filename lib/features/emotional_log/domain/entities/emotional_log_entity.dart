/// Entidad de dominio que representa un registro emocional del usuario.
///
/// Cada registro captura el estado de ánimo (moodIndicator), una nota opcional
/// y/o un audio grabado. Se usa en el historial emocional.
class EmotionalLogEntity {
  /// Identificador único del registro.
  final String id;

  /// ID del usuario que creó el registro.
  final String userId;

  /// Indicador numérico del estado de ánimo (ej. 1-5 o escala personalizada).
  final int moodIndicator;

  /// Nota de texto opcional que acompaña al registro.
  final String? textNote;

  /// URL del audio grabado en Supabase Storage (opcional).
  final String? audioUrl;

  /// Fecha y hora en que se creó el registro.
  final DateTime createdAt;

  const EmotionalLogEntity({
    required this.id,
    required this.userId,
    required this.moodIndicator,
    this.textNote,
    this.audioUrl,
    required this.createdAt,
  });
}
