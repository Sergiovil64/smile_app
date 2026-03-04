import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

// Implementación del repositorio de autenticación
// Utilizado como referencia para el repositorio autenticación de usuario

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  const AuthRepositoryImpl(this._dataSource);

  // Método para iniciar sesión
  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) {
    return _dataSource.signIn(email: email, password: password);
  }

  // Método para crear una cuenta
  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
  }) {
    return _dataSource.signUp(email: email, password: password);
  }

  // Método para cerrar sesión
  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }

  // Método para enviar correo de restablecimiento de contraseña
  @override
  Future<void> resetPassword({required String email}) {
    return _dataSource.resetPassword(email: email);
  }

  // Método para actualizar la contraseña del usuario autenticado
  @override
  Future<void> updatePassword({required String password}) {
    return _dataSource.updatePassword(password: password);
  }
}
