import '../../domain/entities/emotional_log_entity.dart';
import '../../domain/repositories/emotional_log_repository.dart';
import '../datasources/emotional_log_remote_datasource.dart';

class EmotionalLogRepositoryImpl implements EmotionalLogRepository {
  final EmotionalLogRemoteDataSource _dataSource;
  const EmotionalLogRepositoryImpl(this._dataSource);

  @override
  Future<List<EmotionalLogEntity>> getLogs(String userId) =>
      _dataSource.getLogs(userId);

  @override
  Future<void> createLog({
    required String userId,
    required int moodIndicator,
    String? textNote,
    String? audioFilePath,
  }) =>
      _dataSource.createLog(
        userId: userId,
        moodIndicator: moodIndicator,
        textNote: textNote,
        audioFilePath: audioFilePath,
      );
}
