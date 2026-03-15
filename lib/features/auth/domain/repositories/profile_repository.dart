import '../entities/user_profile_entity.dart';

/// Contrato del repositorio de perfil de usuario.
///
/// Gestiona la existencia y creación de perfiles en la tabla user_profile.
/// Usado tras el registro para completar datos personales y rol.
abstract class ProfileRepository {
  /// Verifica si el usuario [userId] tiene un perfil creado en user_profile.
  Future<bool> hasProfile(String userId);

  /// Crea el perfil del usuario con datos personales. Sube avatar si [avatarLocalPath] existe.
  Future<UserProfileEntity> createProfile({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
    required String gender,
    required DateTime birthDate,
    String? avatarLocalPath,
  });
}
