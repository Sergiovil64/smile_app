import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/content_remote_datasource.dart';
import '../../data/repositories/content_repository_impl.dart';
import '../../domain/entities/content_entity.dart';
import '../../domain/repositories/content_repository.dart';
import '../../domain/usecases/get_contents_usecase.dart';
import '../../domain/usecases/save_content_usecase.dart';
import '../notifiers/content_state.dart';

final _supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

final _contentDataSourceProvider = Provider<ContentRemoteDataSource>((ref) {
  return ContentRemoteDataSourceImpl(ref.read(_supabaseClientProvider));
});

final _contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepositoryImpl(ref.read(_contentDataSourceProvider));
});

final _getContentsUseCaseProvider = Provider<GetContentsUseCase>((ref) {
  return GetContentsUseCase(ref.read(_contentRepositoryProvider));
});

final _saveContentUseCaseProvider = Provider<SaveContentUseCase>((ref) {
  return SaveContentUseCase(ref.read(_contentRepositoryProvider));
});

/// Obtiene todos los contenidos educativos ordenados por fecha de creación.
final contentsProvider = FutureProvider<List<ContentEntity>>((ref) async {
  return ref.read(_getContentsUseCaseProvider)();
});

/// Notificador que maneja el guardado (creación y edición) de contenido educativo.
class SaveContentNotifier extends Notifier<SaveContentState> {
  @override
  SaveContentState build() => const SaveContentInitial();

  Future<void> save({
    String? id,
    required String title,
    required String description,
    required String type,
    String? bodyText,
    String? mediaFilePath,
    String? coverImagePath,
    bool isPublished = false,
  }) async {
    state = const SaveContentLoading();
    try {
      await ref.read(_saveContentUseCaseProvider)(
        id: id,
        title: title,
        description: description,
        type: type,
        bodyText: bodyText,
        mediaFilePath: mediaFilePath,
        coverImagePath: coverImagePath,
        isPublished: isPublished,
      );
      state = const SaveContentSuccess();
    } catch (e) {
      print(e);
      state = const SaveContentError(
          'Error al guardar el contenido. Intenta de nuevo.');
    }
  }

  void reset() => state = const SaveContentInitial();
}

// Provider para el notificador de guardado de contenido
final saveContentNotifierProvider =
    NotifierProvider<SaveContentNotifier, SaveContentState>(
  SaveContentNotifier.new,
);
