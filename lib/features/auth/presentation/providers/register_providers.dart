import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../domain/exceptions/auth_exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/register_user_usecase.dart';
import '../notifiers/register_state.dart';

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

final _registerUserUseCaseProvider = Provider<RegisterUserUseCase>(
  (ref) => RegisterUserUseCase(
    ref.watch(_authRepositoryProvider),
    ref.watch(_profileRepositoryProvider),
  ),
);

// ── Notifier ─────────────────────────────────────────────────────────────────

// Método que se encarga de notificar el estado de registro
class RegisterNotifier extends Notifier<RegisterState> {
  @override
  RegisterState build() => const RegisterInitial();

  // Método para registrar un nuevo usuario
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String gender,
    required DateTime birthDate,
    String? avatarLocalPath,
  }) async {
    state = const RegisterLoading();
    try {
      final profile = await ref.read(_registerUserUseCaseProvider)(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        birthDate: birthDate,
        avatarLocalPath: avatarLocalPath,
      );
      state = RegisterSuccess(profile);
    } on ProfileCreationException catch (e) {
      // Auth creado, perfil falló entonces el reintento debe usar completeProfile()
      state = RegisterPartialSuccess(userId: e.userId, message: e.message);
    } catch (e) {
      state = RegisterError(_parseError(e));
    }
  }

  // Método para completar el registro
  Future<void> completeProfile({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
    required String gender,
    required DateTime birthDate,
    String? avatarLocalPath,
  }) async {
    state = const RegisterLoading();
    try {
      final profile = await ref.read(_profileRepositoryProvider).createProfile(
            userId: userId,
            email: email,
            firstName: firstName,
            lastName: lastName,
            gender: gender,
            birthDate: birthDate,
            avatarLocalPath: avatarLocalPath,
          );
      state = RegisterSuccess(profile);
    } catch (e) {
      state = RegisterError(_parseError(e));
    }
  }

  void reset() => state = const RegisterInitial();

  // Método para parsear el error
  String _parseError(Object e) {
    if (e is IncompleteRegistrationException) return e.message;

    final msg = e.toString();
    if (msg.contains('User already registered') ||
        msg.contains('already been registered')) {
      return 'Este correo ya está registrado.';
    }
    if (msg.contains('network') || msg.contains('SocketException')) {
      return 'Sin conexión a Internet.';
    }
    if (msg.contains('storage')) {
      return 'Error al subir la foto. Intenta de nuevo.';
    }
    return 'Ocurrió un error. Intenta de nuevo.';
  }
}

// Provider para el notificador de registro
final registerNotifierProvider =
    NotifierProvider<RegisterNotifier, RegisterState>(
  RegisterNotifier.new,
);
