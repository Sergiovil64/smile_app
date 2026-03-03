import '../../domain/entities/user_profile_entity.dart';

// Estado de registro
sealed class RegisterState {
  const RegisterState();
}

// Estado inicial de registro
class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

// Estado de carga de registro
class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

// Estado de éxito de registro
class RegisterSuccess extends RegisterState {
  final UserProfileEntity profile;
  const RegisterSuccess(this.profile);
}

// Estado de parcial éxito de registro
// El userId ya existe en Auth por lo tanto el siguiente intento debe usar completeProfile().
class RegisterPartialSuccess extends RegisterState {
  final String userId;
  final String message;
  const RegisterPartialSuccess({required this.userId, required this.message});
}

// Estado de error de registro
class RegisterError extends RegisterState {
  final String message;
  const RegisterError(this.message);
}
