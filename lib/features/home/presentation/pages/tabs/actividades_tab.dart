import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../activities/domain/activity_entity.dart';
import '../../../../activities/presentation/providers/activities_provider.dart';

class ActividadesTab extends ConsumerStatefulWidget {
  const ActividadesTab({super.key});

  @override
  ConsumerState<ActividadesTab> createState() => _ActividadesTabState();
}

class _ActividadesTabState extends ConsumerState<ActividadesTab> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ActivityEntity> _filtered(List<ActivityEntity> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all
        .where((a) =>
            a.title.toLowerCase().contains(q) ||
            a.description.toLowerCase().contains(q) ||
            a.category.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final activitiesAsync = ref.watch(activitiesProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Buscar actividad...',
              hintStyle: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                LucideIcons.search,
                color: AppColors.textSecondary,
                size: 18,
              ),
              suffixIcon: _query.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      child: const Icon(LucideIcons.x,
                          color: AppColors.textSecondary, size: 16),
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
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
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ),

        // Lista de actividades
        Expanded(
          child: activitiesAsync.when(
            data: (activities) {
              final filtered = _filtered(activities);
              if (filtered.isEmpty) {
                return Center(
                  child: Text(
                    _query.isEmpty
                        ? 'No hay actividades disponibles.'
                        : 'Sin resultados para "$_query".',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _ActivityCard(activity: filtered[i]),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (_, __) => Center(
              child: Text(
                'Error al cargar las actividades.',
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Widget para mostrar la tarjeta de actividad

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});
  final ActivityEntity activity;

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}';
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'mindfulness':
        return LucideIcons.brain;
      case 'bienestar':
        return LucideIcons.heart;
      case 'respiracion':
      case 'respiración':
        return LucideIcons.wind;
      case 'movimiento':
        return LucideIcons.activity;
      default:
        return LucideIcons.sparkles;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title bar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Text(
              activity.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // Fila de contenido: icono + descripción
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono de la categoría
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _categoryIcon(activity.category),
                    color: AppColors.textSecondary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                // Descripción
                Expanded(
                  child: Text(
                    activity.description,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Fila de metadatos: categoría + fecha
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Text(
                  activity.category,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(activity.createdAt),
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Botón de APRENDER (deshabilitado)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary,
                  disabledForegroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 16),
                    Text(
                      'APRENDER',
                      style: GoogleFonts.inter(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.onPrimary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
