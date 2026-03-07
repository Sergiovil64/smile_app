import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../domain/entities/content_entity.dart';

// Página de detalle de contenido

class ContentDetailPage extends StatelessWidget {
  const ContentDetailPage({super.key, required this.content});

  final ContentEntity content;

  String _formatDate(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leadingWidth: 110,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AppLogo(width: 100, padding: EdgeInsets.zero),
          ),
        ),
        title: Text(
          'Contenido',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'ADM',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                elevation: 0,
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(
                'ATRÁS',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Cover image or type hero
          _CoverHero(
            coverImageUrl: content.coverImageUrl,
            type: content.type,
          ),
          const SizedBox(height: 20),

          // Título
          Text(
            content.title,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _Chip(
                label: content.isPublished ? 'Publicado' : 'Borrador',
                color: content.isPublished
                    ? AppColors.primary
                    : AppColors.textSecondary,
                filled: content.isPublished,
              ),
              _Chip(
                label: _typeLabel(content.type),
                color: AppColors.textSecondary,
                icon: _typeIcon(content.type),
              ),
              _Chip(
                label: _formatDate(content.createdAt),
                color: AppColors.textSecondary,
                icon: LucideIcons.calendar,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Divider entre secciones
          const Divider(color: AppColors.inputBorder, height: 1),
          const SizedBox(height: 24),

          // Introducción
          _buildSection(label: 'Introducción', text: content.description),

          // Cuerpo
          if (content.bodyText != null && content.bodyText!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildSection(label: 'Cuerpo', text: content.bodyText!),
          ],

          // URL de medio
          if (content.mediaUrl != null && content.mediaUrl!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildSection(label: 'URL de medio', text: content.mediaUrl!),
          ],

          const SizedBox(height: 32),

          // Nota de actualización
          Row(
            children: [
              const Icon(LucideIcons.clock, size: 12, color: AppColors.textHint),
              const SizedBox(width: 5),
              Text(
                'Actualizado el ${_formatDate(content.updatedAt)}',
                style: GoogleFonts.inter(
                  color: AppColors.textHint,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String label, required String text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'AUDIO':
        return 'Audio';
      case 'VIDEO':
        return 'Video';
      default:
        return 'Documento';
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'AUDIO':
        return LucideIcons.mic;
      case 'VIDEO':
        return LucideIcons.video;
      default:
        return LucideIcons.file_text;
    }
  }
}

  // Widget para mostrar la imagen de portada del contenido
class _CoverHero extends StatelessWidget {
  const _CoverHero({required this.coverImageUrl, required this.type});

  final String? coverImageUrl;
  final String type;

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
    if (coverImageUrl != null && coverImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          coverImageUrl!,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _iconHero,
        ),
      );
    }
    return _iconHero;
  }

  Widget get _iconHero => Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_icon, color: AppColors.primary, size: 48),
          ],
        ),
      );
}

// Widget para mostrar los chips de estado, tipo y fecha
class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    this.icon,
    this.filled = false,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color.withAlpha(30) : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(filled ? 180 : 80), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
