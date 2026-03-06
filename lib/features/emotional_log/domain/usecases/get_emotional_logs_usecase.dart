import '../entities/emotional_log_entity.dart';
import '../repositories/emotional_log_repository.dart';

class GetEmotionalLogsUseCase {
  final EmotionalLogRepository _repository;
  const GetEmotionalLogsUseCase(this._repository);

  Future<List<EmotionalLogEntity>> call(String userId) =>
      _repository.getLogs(userId);
}
