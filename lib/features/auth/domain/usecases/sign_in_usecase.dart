import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../repositories/profile_repository.dart';

/// Resultado del caso de uso de inicio de sesión.
///
/// Indica si el usuario tiene perfil creado para decidir si redirigir
/// a completar registro o a la pantalla principal.
class SignInResult {
  final UserEntity user;
  final bool hasProfile;
  const SignInResult({required this.user, required this.hasProfile});
}

/// Caso de uso para iniciar sesión con email y contraseña.
///
/// Autentica al usuario y verifica si tiene perfil en user_profile.
/// Si hasProfile es false, la UI debe redirigir a completar registro.
class SignInUseCase {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  const SignInUseCase(this._authRepository, this._profileRepository);

  /// Ejecuta el login. Retorna [SignInResult] con user y hasProfile.
  Future<SignInResult> call({
    required String email,
    required String password,
  }) async {
    final user = await _authRepository.signIn(email: email, password: password);

    // Si la verificación falla por un error transitorio en la BD, se asume
    // hasProfile: true y _RoleGate determina el rol de forma asíncrona.
    try {
      final profileExists = await _profileRepository.hasProfile(user.id);
      return SignInResult(user: user, hasProfile: profileExists);
    } catch (_) {
      return SignInResult(user: user, hasProfile: true);
    }
  }
}
