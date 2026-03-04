import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../notifiers/auth_state.dart';
import '../notifiers/forgot_password_state.dart';

final _supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

final _authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSourceImpl(ref.watch(_supabaseClientProvider)),
);

final _profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>(
  (ref) => ProfileRemoteDataSourceImpl(ref.watch(_supabaseClientProvider)),
);

final _authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(_authRemoteDataSourceProvider)),
);

final _profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.watch(_profileRemoteDataSourceProvider)),
);

final _signInUseCaseProvider = Provider<SignInUseCase>(
  (ref) => SignInUseCase(
    ref.watch(_authRepositoryProvider),
    ref.watch(_profileRepositoryProvider),
  ),
);

// ── Notifier ─────────────────────────────────────────────────────────────────

// Método que se encarga de notificar el estado de la autenticación
class AuthNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginInitial();

  // Método para iniciar sesión
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const LoginLoading();
    try {
      final result = await ref.read(_signInUseCaseProvider)(
        email: email,
        password: password,
      );
      state = result.hasProfile
          ? LoginSuccess(result.user)
          : LoginProfileIncomplete(result.user);
    } catch (e) {
      state = LoginError(_parseError(e));
    }
  }

  void reset() => state = const LoginInitial();

  // Método para parsear el error
  String _parseError(Object e) {
    final msg = e.toString();
    if (msg.contains('Invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (msg.contains('User already registered')) {
      return 'Este correo ya está registrado.';
    }
    if (msg.contains('network')) {
      return 'Sin conexión a Internet.';
    }
    return 'Ocurrió un error. Intenta de nuevo.';
  }
}

// Provider para el notificador de la autenticación
final authNotifierProvider = NotifierProvider<AuthNotifier, LoginState>(
  AuthNotifier.new,
);

// Stream que emite el estado de sesión de Supabase en tiempo real.
// El primer evento llega casi inmediatamente con la sesión persistida (o null).
final supabaseSessionProvider = StreamProvider<AuthState>(
  (_) => Supabase.instance.client.auth.onAuthStateChange,
);


class ForgotPasswordNotifier extends Notifier<ForgotPasswordState> {
  @override
  ForgotPasswordState build() => const ForgotPasswordInitial();

  Future<void> sendResetEmail({required String email}) async {
    state = const ForgotPasswordLoading();
    try {
      await ref.read(_authRepositoryProvider).resetPassword(email: email);
      state = ForgotPasswordSuccess(email);
    } catch (e) {
      state = ForgotPasswordError(_parseError(e));
    }
  }

  void reset() => state = const ForgotPasswordInitial();

  String _parseError(Object e) {
    final msg = e.toString();
    if (msg.contains('network') || msg.contains('SocketException')) {
      return 'Sin conexión a Internet.';
    }
    if (msg.contains('rate limit') || msg.contains('429')) {
      return 'Demasiados intentos. Espera un momento.';
    }
    return 'Ocurrió un error. Intenta de nuevo.';
  }
}

final forgotPasswordNotifierProvider =
    NotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>(
  ForgotPasswordNotifier.new,
);
