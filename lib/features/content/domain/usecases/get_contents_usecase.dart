import '../entities/content_entity.dart';
import '../repositories/content_repository.dart';

/// Caso de uso para obtener la lista de contenidos educativos publicados.
class GetContentsUseCase {
  final ContentRepository _repository;
  const GetContentsUseCase(this._repository);

  Future<List<ContentEntity>> call() => _repository.getContents();
}
