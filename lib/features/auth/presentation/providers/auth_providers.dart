import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../notifiers/auth_state.dart';

final _supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

final _authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSourceImpl(ref.watch(_supabaseClientProvider)),
);

final _authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(_authRemoteDataSourceProvider)),
);

final _signInUseCaseProvider = Provider<SignInUseCase>(
  (ref) => SignInUseCase(ref.watch(_authRepositoryProvider)),
);

final _signUpUseCaseProvider = Provider<SignUpUseCase>(
  (ref) => SignUpUseCase(ref.watch(_authRepositoryProvider)),
);

// ── Notifier ─────────────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginInitial();

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const LoginLoading();
    try {
      final user = await ref.read(_signInUseCaseProvider)(
        email: email,
        password: password,
      );
      state = LoginSuccess(user);
    } catch (e) {
      state = LoginError(_parseError(e));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    state = const LoginLoading();
    try {
      final user = await ref.read(_signUpUseCaseProvider)(
        email: email,
        password: password,
      );
      state = LoginSuccess(user);
    } catch (e) {
      state = LoginError(_parseError(e));
    }
  }

  void reset() => state = const LoginInitial();

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

final authNotifierProvider = NotifierProvider<AuthNotifier, LoginState>(
  AuthNotifier.new,
);
