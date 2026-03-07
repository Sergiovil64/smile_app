import '../repositories/content_repository.dart';

class SaveContentUseCase {
  final ContentRepository _repository;
  const SaveContentUseCase(this._repository);

  Future<void> call({
    String? id,
    required String title,
    required String description,
    required String type,
    String? bodyText,
    String? mediaFilePath,
    String? coverImagePath,
    bool isPublished = false,
  }) =>
      _repository.saveContent(
        id: id,
        title: title,
        description: description,
        type: type,
        bodyText: bodyText,
        mediaFilePath: mediaFilePath,
        coverImagePath: coverImagePath,
        isPublished: isPublished,
      );
}
