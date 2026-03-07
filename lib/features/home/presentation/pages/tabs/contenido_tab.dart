import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../content/domain/entities/content_entity.dart';
import '../../../../content/presentation/pages/content_detail_page.dart';
import '../../../../content/presentation/providers/content_providers.dart';

class ContenidoTab extends ConsumerWidget {
  const ContenidoTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentsAsync = ref.watch(contentsProvider);

    return contentsAsync.when(
      data: (contents) => contents.isEmpty
          ? Center(
              child: Text(
                'No hay contenido disponible aún.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: contents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _UserContentCard(
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
    );
  }
}

// Widget para mostrar la tarjeta de contenido

class _UserContentCard extends StatelessWidget {
  const _UserContentCard({required this.content, required this.onTap});

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
          child: Row(
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _TypeBadge(type: content.type),
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
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget para mostrar el badge del tipo de contenido

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final String type;

  String get _label {
    switch (type) {
      case 'AUDIO':
        return 'Audio';
      case 'VIDEO':
        return 'Video';
      default:
        return 'Texto';
    }
  }

  IconData get _icon {
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_icon, size: 11, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          _label,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Widget para mostrar la miniatura del contenido

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
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          coverImageUrl!,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _iconBox,
        ),
      );
    }
    return _iconBox;
  }

  Widget get _iconBox => Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(_fallbackIcon, color: AppColors.textSecondary, size: 26),
      );
}
