import '../entities/content_entity.dart';
import '../repositories/content_repository.dart';

class GetContentsUseCase {
  final ContentRepository _repository;
  const GetContentsUseCase(this._repository);

  Future<List<ContentEntity>> call() => _repository.getContents();
}
