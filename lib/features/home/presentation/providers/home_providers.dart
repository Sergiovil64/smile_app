import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/domain/entities/user_profile_entity.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'dart:developer';

final currentUserProfileProvider = FutureProvider<UserProfileEntity?>((ref) async {
  // Dependencia al stream de sesión para que el provider se recalcule
  // automáticamente en cada cambio de autenticación (login, logout, refresh).
  // La lógica real usa currentUser, que es síncrono y siempre actualizado.
  ref.watch(supabaseSessionProvider);

  final client = Supabase.instance.client;
  final user = client.auth.currentUser;
  if (user == null) return null;

  final data = await client
      .from('user_profile')
      .select()
      .eq('user_id', user.id)
      .maybeSingle();
  if (data == null) return null;

  return UserProfileEntity(
    id: data['user_id'] as String,
    email: user.email ?? '',
    firstName: data['first_name'] as String,
    lastName: data['last_name'] as String,
    gender: data['gender'] as String,
    birthDate: DateTime.parse(data['birth_date'] as String),
    avatarUrl: data['photo_url'] as String?,
    role: data['role'] as String? ?? 'Adolescent',
  );
});
