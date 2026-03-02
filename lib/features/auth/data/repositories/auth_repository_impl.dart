import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;

  const AuthRepositoryImpl(this._dataSource);

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) {
    return _dataSource.signIn(email: email, password: password);
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
  }) {
    return _dataSource.signUp(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }
}
