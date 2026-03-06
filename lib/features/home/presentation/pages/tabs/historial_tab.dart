import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../emotional_log/domain/entities/emotional_log_entity.dart';
import '../../../../emotional_log/presentation/pages/create_emotional_log_page.dart';
import '../../../../emotional_log/presentation/providers/emotional_log_providers.dart';

const _moodEmojis = ['😢', '😕', '😐', '😊', '😄'];

const _spanishMonths = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
];

String _formatGroupDate(DateTime date) =>
    '${date.day} de ${_spanishMonths[date.month - 1]}, ${date.year}';

String _emojiForMood(int mood) => _moodEmojis[(mood - 1).clamp(0, 4)];

/// Agrupa los registros por su fecha local (año/mes/día).
Map<DateTime, List<EmotionalLogEntity>> _groupByDate(
    List<EmotionalLogEntity> logs) {
  final map = <DateTime, List<EmotionalLogEntity>>{};
  for (final log in logs) {
    final local = log.createdAt.toLocal();
    final key = DateTime(local.year, local.month, local.day);
    map.putIfAbsent(key, () => []).add(log);
  }
  return map;
}

class HistorialTab extends ConsumerStatefulWidget {
  const HistorialTab({super.key});

  @override
  ConsumerState<HistorialTab> createState() => _HistorialTabState();
}

class _HistorialTabState extends ConsumerState<HistorialTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EmotionalLogEntity> _filtered(List<EmotionalLogEntity> logs) {
    if (_query.isEmpty) return logs;
    return logs
        .where((l) => l.textNote?.toLowerCase().contains(_query) ?? false)
        .toList();
  }

  void _openCreate() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateEmotionalLogPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(emotionalLogsProvider);

    return Stack(
      children: [
        Column(
          children: [
            _SearchBar(controller: _searchController),
            Expanded(
              child: logsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (_, __) => Center(
                  child: Text(
                    'Error al cargar los registros.',
                    style: GoogleFonts.inter(color: AppColors.textSecondary),
                  ),
                ),
                data: (logs) {
                  final filtered = _filtered(logs);
                  if (filtered.isEmpty) {
                    return _EmptyState(hasQuery: _query.isNotEmpty);
                  }
                  final grouped = _groupByDate(filtered);
                  final dates = grouped.keys.toList()
                    ..sort((a, b) => b.compareTo(a));
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: dates.length,
                    itemBuilder: (_, i) {
                      final date = dates[i];
                      final dayLogs = grouped[date]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              _formatGroupDate(date),
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                          ...dayLogs.map((log) => _LogCard(log: log)),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 24,
          child: FloatingActionButton(
            onPressed: _openCreate,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 4,
            child: const Icon(LucideIcons.plus),
          ),
        ),
      ],
    );
  }
}

// Widget para el campo de busqueda de los registros emocionales
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Buscar registros...',
          hintStyle:
              const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          prefixIcon:
              const Icon(LucideIcons.search, color: AppColors.textSecondary, size: 18),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// Widget para la tarjeta de un registro emocional
class _LogCard extends StatelessWidget {
  const _LogCard({required this.log});
  final EmotionalLogEntity log;

  @override
  Widget build(BuildContext context) {
    final hasAudio = log.audioUrl != null;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasAudio)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.mic, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Nota de audio',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          if (log.textNote != null && log.textNote!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                log.textNote!,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  height: 1.5,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Row(
            children: [
              Text(
                'Estado emocional',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _emojiForMood(log.moodIndicator),
                style: const TextStyle(fontSize: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget para el estado de no hay registros
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasQuery});
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hasQuery ? '🔍' : '📓',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(
              hasQuery
                  ? 'No se encontraron registros.'
                  : 'Aún no tienes registros.\nToca + para agregar el primero.',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
