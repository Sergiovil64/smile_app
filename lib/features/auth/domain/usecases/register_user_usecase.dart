import '../entities/user_profile_entity.dart';
import '../exceptions/auth_exceptions.dart';
import '../repositories/auth_repository.dart';
import '../repositories/profile_repository.dart';

// Usecase para registrar un nuevo usuario
class RegisterUserUseCase {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  const RegisterUserUseCase(this._authRepository, this._profileRepository);

  Future<UserProfileEntity> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String gender,
    required DateTime birthDate,
    String? avatarLocalPath,
  }) async {
    // ── Paso 1: crear usuario en Auth ─────────────────────────────────────────
    // Si falla aquí no hay nada que limpiar, la excepción sube directamente.
    final authUser = await _authRepository.signUp(
      email: email,
      password: password,
    );

    // ── Paso 2: crear perfil ──────────────────────────────────────────────────
    // Si falla, el usuario auth ya existe (usuario huérfano). Se cierra la
    // sesión activa y se lanza ProfileCreationException para que la capa
    // superior informe al usuario que puede reintentar.
    try {
      return await _profileRepository.createProfile(
        userId: authUser.id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        birthDate: birthDate,
        avatarLocalPath: avatarLocalPath,
      );
    } catch (e) {
      // Cerrar sesión para que el usuario no quede autenticado sin perfil
      await _authRepository.signOut().catchError((_) {});

      throw ProfileCreationException(
        authUser.id,
        'Tu cuenta fue creada pero el perfil no pudo guardarse. '
        'Intenta registrarte de nuevo con el mismo correo.',
      );
    }
  }
}
