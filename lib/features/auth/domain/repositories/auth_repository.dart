import '../entities/user_entity.dart';

/// Contrato del repositorio de autenticación.
///
/// Define las operaciones de login, registro, cierre de sesión y recuperación
/// de contraseña. La implementación usa Supabase Auth.
abstract class AuthRepository {
  /// Inicia sesión con email y contraseña. Retorna [UserEntity] si es exitoso.
  Future<UserEntity> signIn({
    required String email,
    required String password,
  });

  /// Registra un nuevo usuario con email y contraseña.
  Future<UserEntity> signUp({
    required String email,
    required String password,
  });

  /// Cierra la sesión actual del usuario.
  Future<void> signOut();

  /// Envía un correo de recuperación de contraseña al [email] indicado.
  Future<void> resetPassword({required String email});

  /// Actualiza la contraseña del usuario (tras flujo de recuperación).
  Future<void> updatePassword({required String password});
}
