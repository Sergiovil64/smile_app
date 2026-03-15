import '../repositories/emotional_log_repository.dart';

/// Caso de uso para crear un registro emocional.
///
/// Captura moodIndicator, nota opcional y/o audio. El audio en [audioFilePath]
/// se sube a Supabase Storage.
class CreateEmotionalLogUseCase {
  final EmotionalLogRepository _repository;
  const CreateEmotionalLogUseCase(this._repository);

  Future<void> call({
    required String userId,
    required int moodIndicator,
    String? textNote,
    String? audioFilePath,
  }) =>
      _repository.createLog(
        userId: userId,
        moodIndicator: moodIndicator,
        textNote: textNote,
        audioFilePath: audioFilePath,
      );
}
