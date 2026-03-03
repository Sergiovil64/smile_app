import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

// Usecase para crear una cuenta
class SignUpUseCase {
  final AuthRepository _repository;

  const SignUpUseCase(this._repository);

  // Método para crear una cuenta
  Future<UserEntity> call({
    required String email,
    required String password,
  }) {
    return _repository.signUp(email: email, password: password);
  }
}
