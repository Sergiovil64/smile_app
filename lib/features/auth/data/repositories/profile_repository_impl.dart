import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

// Implementación del repositorio de perfil de usuario
// Utilizado como referencia para el repositorio perfil de usuario

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _dataSource;

  const ProfileRepositoryImpl(this._dataSource);

  // Método para verificar si un perfil de usuario existe
  @override
  Future<bool> hasProfile(String userId) => _dataSource.hasProfile(userId);

  // Método para crear un perfil de usuario
  @override
  Future<UserProfileEntity> createProfile({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
    required String gender,
    required DateTime birthDate,
    String? avatarLocalPath,
  }) {
    return _dataSource.createProfile(
      userId: userId,
      email: email,
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      birthDate: birthDate,
      avatarLocalPath: avatarLocalPath,
    );
  }
}
