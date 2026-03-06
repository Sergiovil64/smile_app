import '../entities/emotional_log_entity.dart';

abstract class EmotionalLogRepository {
  Future<List<EmotionalLogEntity>> getLogs(String userId);
  Future<void> createLog({
    required String userId,
    required int moodIndicator,
    String? textNote,
  });
}
