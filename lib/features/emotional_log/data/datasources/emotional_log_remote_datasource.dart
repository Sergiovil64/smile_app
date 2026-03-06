import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/emotional_log_entity.dart';

abstract class EmotionalLogRemoteDataSource {
  Future<List<EmotionalLogEntity>> getLogs(String userId);
  Future<void> createLog({
    required String userId,
    required int moodIndicator,
    String? textNote,
  });
}

class EmotionalLogRemoteDataSourceImpl implements EmotionalLogRemoteDataSource {
  final SupabaseClient _client;
  const EmotionalLogRemoteDataSourceImpl(this._client);

  // Obtener los registros emocionales del usuario
  @override
  Future<List<EmotionalLogEntity>> getLogs(String userId) async {
    final data = await _client
        .from('emotional_log')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((row) => EmotionalLogEntity(
              id: row['id'] as String,
              userId: row['user_id'] as String,
              moodIndicator: row['mood_indicator'] as int,
              textNote: row['text_note'] as String?,
              audioUrl: row['audio_url'] as String?,
              createdAt: DateTime.parse(row['created_at'] as String),
            ))
        .toList();
  }

  // Crear un nuevo registro emocional
  @override
  Future<void> createLog({
    required String userId,
    required int moodIndicator,
    String? textNote,
  }) async {
    await _client.from('emotional_log').insert({
      'user_id': userId,
      'mood_indicator': moodIndicator,
      if (textNote != null && textNote.isNotEmpty) 'text_note': textNote,
    });
  }
}
