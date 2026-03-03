import '../../domain/entities/user_entity.dart';

// Estado de la autenticación
sealed class LoginState {
  const LoginState();
}

// Estado inicial de la autenticación
class LoginInitial extends LoginState {
  const LoginInitial();
}

// Estado de carga de la autenticación
class LoginLoading extends LoginState {
  const LoginLoading();
}

// Estado de éxito de la autenticación
class LoginSuccess extends LoginState {
  final UserEntity user;
  const LoginSuccess(this.user);
}

// Estado de perfil incompleto de la autenticación
class LoginProfileIncomplete extends LoginState {
  final UserEntity user;
  const LoginProfileIncomplete(this.user);
}

// Estado de error de la autenticación
class LoginError extends LoginState {
  final String message;
  const LoginError(this.message);
}
