class EmotionalLogEntity {
  final String id;
  final String userId;
  final int moodIndicator;
  final String? textNote;
  final String? audioUrl;
  final DateTime createdAt;

  const EmotionalLogEntity({
    required this.id,
    required this.userId,
    required this.moodIndicator,
    this.textNote,
    this.audioUrl,
    required this.createdAt,
  });
}
