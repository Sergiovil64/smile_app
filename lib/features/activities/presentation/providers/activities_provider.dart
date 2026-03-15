import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/activity_entity.dart';

/// Obtiene todas las actividades de autocuidado activas.
///
/// Consulta la tabla self_care_activity con is_active=true,
/// ordenadas por fecha de creación descendente.
final activitiesProvider = FutureProvider<List<ActivityEntity>>((ref) async {
  final data = await Supabase.instance.client
      .from('self_care_activity')
      .select()
      .eq('is_active', true)
      .order('created_at', ascending: false);

  return (data as List)
      .map((row) => ActivityEntity(
            id: row['id'] as String,
            title: row['title'] as String,
            description: row['description'] as String,
            category: row['category'] as String,
            isActive: row['is_active'] as bool,
            createdAt: DateTime.parse(row['created_at'] as String),
          ))
      .toList();
});
