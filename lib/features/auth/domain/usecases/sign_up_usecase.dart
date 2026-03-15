import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para crear una cuenta (solo Auth, sin perfil).
///
/// Usado cuando el usuario ya tiene cuenta y solo necesita autenticarse.
/// Para registro completo con perfil, usar [RegisterUserUseCase].
class SignUpUseCase {
  final AuthRepository _repository;

  const SignUpUseCase(this._repository);

  /// Crea el usuario en Supabase Auth. No crea perfil en user_profile.
  Future<UserEntity> call({
    required String email,
    required String password,
  }) {
    return _repository.signUp(email: email, password: password);
  }
}
