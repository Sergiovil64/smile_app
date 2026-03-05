import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import '../repositories/profile_repository.dart';

// Usecase para iniciar sesión
class SignInResult {
  final UserEntity user;
  final bool hasProfile;
  const SignInResult({required this.user, required this.hasProfile});
}

class SignInUseCase {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  const SignInUseCase(this._authRepository, this._profileRepository);

  // Método para iniciar sesión
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
