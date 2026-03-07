import '../../domain/entities/content_entity.dart';
import '../../domain/repositories/content_repository.dart';
import '../datasources/content_remote_datasource.dart';

class ContentRepositoryImpl implements ContentRepository {
  final ContentRemoteDataSource _dataSource;
  const ContentRepositoryImpl(this._dataSource);

  @override
  Future<List<ContentEntity>> getContents() => _dataSource.getContents();

  @override
  Future<void> saveContent({
    String? id,
    required String title,
    required String description,
    required String type,
    String? bodyText,
    String? mediaFilePath,
    String? coverImagePath,
    bool isPublished = false,
  }) =>
      _dataSource.saveContent(
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
