import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity> signIn({required String email, required String password});
  Future<UserEntity> signUp({required String email, required String password});
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;

  const AuthRemoteDataSourceImpl(this._client);

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) throw Exception('Error al iniciar sesión.');

    return UserEntity(id: user.id, email: user.email ?? email);
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) throw Exception('Error al crear la cuenta.');

    return UserEntity(id: user.id, email: user.email ?? email);
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
