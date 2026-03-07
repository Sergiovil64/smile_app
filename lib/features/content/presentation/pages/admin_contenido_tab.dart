import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/content_entity.dart';
import '../providers/content_providers.dart';
import 'content_detail_page.dart';
import 'create_edit_content_page.dart';

class AdminContenidoTab extends ConsumerWidget {
  const AdminContenidoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentsAsync = ref.watch(contentsProvider);

    Future<void> goToCreate() async {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CreateEditContentPage()),
      );
      ref.invalidate(contentsProvider);
    }

    return Stack(
      children: [
        contentsAsync.when(
          data: (contents) => contents.isEmpty
              ? Center(
                  child: Text(
                    'No hay contenido aún.\nToca + para agregar.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: contents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _ContentCard(
                    content: contents[index],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ContentDetailPage(content: contents[index]),
                      ),
                    ),
                  ),
                ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (_, __) => Center(
            child: Text(
              'Error al cargar el contenido.',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 2,
            onPressed: goToCreate,
            child: const Icon(Icons.add, size: 28),
          ),
        ),
      ],
    );
  }
}

  // Widget para mostrar el contenido en una tarjeta

class _ContentCard extends StatelessWidget {
  const _ContentCard({
    required this.content,
    required this.onTap,
  });

  final ContentEntity content;
  final VoidCallback onTap;

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.primary.withAlpha(20),
        highlightColor: AppColors.primary.withAlpha(10),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Thumbnail(
                    coverImageUrl: content.coverImageUrl,
                    type: content.type,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content.title,
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          content.description,
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _StatusChip(isPublished: content.isPublished),
                  const Spacer(),
                  Text(
                    _formatDate(content.createdAt),
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget para mostrar el estado del contenido (publicado o borrador)
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isPublished});
  final bool isPublished;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPublished
            ? AppColors.primary.withAlpha(30)
            : AppColors.textHint.withAlpha(80),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isPublished ? AppColors.primary : AppColors.textSecondary,
          width: 0.8,
        ),
      ),
      child: Text(
        isPublished ? 'Publicado' : 'Borrador',
        style: GoogleFonts.inter(
          color: isPublished ? AppColors.primary : AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Widget para mostrar la imagen de portada del contenido
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.coverImageUrl, required this.type});

  final String? coverImageUrl;
  final String type;

  IconData get _fallbackIcon {
    switch (type) {
      case 'AUDIO':
        return LucideIcons.mic;
      case 'VIDEO':
        return LucideIcons.video;
      default:
        return LucideIcons.file_text;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (coverImageUrl != null && coverImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          coverImageUrl!,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _iconBox,
        ),
      );
    }
    return _iconBox;
  }

  Widget get _iconBox => Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(_fallbackIcon, color: AppColors.textSecondary, size: 28),
      );
}
