import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_profile_entity.dart';

abstract class ProfileRemoteDataSource {
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

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient _client;

  const ProfileRemoteDataSourceImpl(this._client);

  @override
  Future<bool> hasProfile(String userId) async {
    final data = await _client
        .from('user_profile')
        .select('user_id')
        .eq('user_id', userId)
        .maybeSingle();
    return data != null;
  }

  @override
  Future<UserProfileEntity> createProfile({
    required String userId,
    required String email,
    required String firstName,
    required String lastName,
    required String gender,
    required DateTime birthDate,
    String? avatarLocalPath,
  }) async {
    String? avatarUrl;

    if (avatarLocalPath != null) {
      final file = File(avatarLocalPath);
      final ext = avatarLocalPath.split('.').last.toLowerCase();
      final filePath = '$userId/photo.$ext';

      await _client.storage.from('avatars').upload(
            filePath,
            file,
            fileOptions: FileOptions(
              contentType: 'image/$ext',
              upsert: true,
            ),
          );

      avatarUrl = _client.storage.from('avatars').getPublicUrl(filePath);
    }

    await _client.from('user_profile').insert({
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'birth_date': birthDate.toIso8601String().split('T').first,
      'photo_url': avatarUrl,
    });

    return UserProfileEntity(
      id: userId,
      email: email,
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      birthDate: birthDate,
      avatarUrl: avatarUrl,
    );
  }
}
