import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/emotional_log_remote_datasource.dart';
import '../../data/repositories/emotional_log_repository_impl.dart';
import '../../domain/entities/emotional_log_entity.dart';
import '../../domain/repositories/emotional_log_repository.dart';
import '../../domain/usecases/create_emotional_log_usecase.dart';
import '../../domain/usecases/get_emotional_logs_usecase.dart';
import '../notifiers/emotional_log_state.dart';

final _supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

final _emotionalLogDataSourceProvider =
    Provider<EmotionalLogRemoteDataSource>((ref) {
  return EmotionalLogRemoteDataSourceImpl(ref.read(_supabaseClientProvider));
});

final _emotionalLogRepositoryProvider =
    Provider<EmotionalLogRepository>((ref) {
  return EmotionalLogRepositoryImpl(
    ref.read(_emotionalLogDataSourceProvider),
  );
});

final _getEmotionalLogsUseCaseProvider =
    Provider<GetEmotionalLogsUseCase>((ref) {
  return GetEmotionalLogsUseCase(ref.read(_emotionalLogRepositoryProvider));
});

final _createEmotionalLogUseCaseProvider =
    Provider<CreateEmotionalLogUseCase>((ref) {
  return CreateEmotionalLogUseCase(ref.read(_emotionalLogRepositoryProvider));
});

/// Obtiene todos los registros emocionales del usuario actual, se ejecuta nuevamente al cambiar la autenticación.
final emotionalLogsProvider =
    FutureProvider<List<EmotionalLogEntity>>((ref) async {
  ref.watch(supabaseSessionProvider);

  final client = Supabase.instance.client;
  final userId = client.auth.currentUser?.id;
  if (userId == null) return [];

  return ref.read(_getEmotionalLogsUseCaseProvider)(userId);
});

/// Notificador que maneja el envío del formulario de creación de un registro emocional.
class CreateLogNotifier extends Notifier<CreateLogState> {
  @override
  CreateLogState build() => const CreateLogInitial();

  Future<void> createLog({
    required int moodIndicator,
    String? textNote,
  }) async {
    state = const CreateLogLoading();
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) {
        state = const CreateLogError('Usuario no autenticado.');
        return;
      }
      await ref.read(_createEmotionalLogUseCaseProvider)(
        userId: userId,
        moodIndicator: moodIndicator,
        textNote: textNote,
      );
      state = const CreateLogSuccess();
    } catch (e) {
      state = CreateLogError('Error al guardar el registro. Intenta de nuevo.');
    }
  }

  void reset() => state = const CreateLogInitial();
}

final createLogNotifierProvider =
    NotifierProvider<CreateLogNotifier, CreateLogState>(
  CreateLogNotifier.new,
);
