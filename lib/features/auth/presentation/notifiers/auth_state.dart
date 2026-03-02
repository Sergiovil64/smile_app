import '../../domain/entities/user_entity.dart';

sealed class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final UserEntity user;
  const LoginSuccess(this.user);
}

/// El usuario existe en Auth pero no completó el registro del perfil.
class LoginProfileIncomplete extends LoginState {
  final UserEntity user;
  const LoginProfileIncomplete(this.user);
}

class LoginError extends LoginState {
  final String message;
  const LoginError(this.message);
}
