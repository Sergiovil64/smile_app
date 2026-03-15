import '../../domain/entities/user_entity.dart';

/// Estados posibles del flujo de login manejados por [AuthNotifier].
sealed class LoginState {
  const LoginState();
}

/// Estado inicial antes de intentar login.
class LoginInitial extends LoginState {
  const LoginInitial();
}

/// Estado de carga mientras se autentica.
class LoginLoading extends LoginState {
  const LoginLoading();
}

/// Login exitoso con perfil completo. Redirige a home.
class LoginSuccess extends LoginState {
  final UserEntity user;
  const LoginSuccess(this.user);
}

/// Login exitoso pero sin perfil. Redirige a completar registro.
class LoginProfileIncomplete extends LoginState {
  final UserEntity user;
  const LoginProfileIncomplete(this.user);
}

/// Error en el login. [message] es el mensaje mostrado al usuario.
class LoginError extends LoginState {
  final String message;
  const LoginError(this.message);
}
