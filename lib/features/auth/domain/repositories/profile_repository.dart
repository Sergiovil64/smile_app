import '../entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Future<bool> hasProfile(String userId);

  Future<UserProfileEntity> createProfile({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
    required String gender,
    required DateTime birthDate,
    String? avatarLocalPath,
  });
}
