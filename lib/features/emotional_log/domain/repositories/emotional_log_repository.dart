import '../entities/emotional_log_entity.dart';

/// Contrato del repositorio de registros emocionales.
///
/// Gestiona la creación y listado de registros emocionales por usuario.
/// Los audios se suben a Supabase Storage.
abstract class EmotionalLogRepository {
  /// Obtiene todos los registros emocionales del usuario [userId].
  Future<List<EmotionalLogEntity>> getLogs(String userId);

  /// Crea un nuevo registro emocional. [audioFilePath] es ruta local que se sube a Storage.
  Future<void> createLog({
    required String userId,
    required int moodIndicator,
    String? textNote,
    String? audioFilePath,
  });
}
