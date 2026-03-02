import '../../domain/entities/user_profile_entity.dart';

sealed class RegisterState {
  const RegisterState();
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  final UserProfileEntity profile;
  const RegisterSuccess(this.profile);
}

/// signUp tuvo éxito pero createProfile falló.
/// El userId ya existe en Auth por lo tanto el siguiente intento debe usar completeProfile().
class RegisterPartialSuccess extends RegisterState {
  final String userId;
  final String message;
  const RegisterPartialSuccess({required this.userId, required this.message});
}

class RegisterError extends RegisterState {
  final String message;
  const RegisterError(this.message);
}
