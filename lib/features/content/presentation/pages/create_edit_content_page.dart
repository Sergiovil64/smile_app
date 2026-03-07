import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../domain/entities/content_entity.dart';
import '../notifiers/content_state.dart';
import '../providers/content_providers.dart';

class CreateEditContentPage extends ConsumerStatefulWidget {
  const CreateEditContentPage({super.key, this.content});

  final ContentEntity? content;

  @override
  ConsumerState<CreateEditContentPage> createState() =>
      _CreateEditContentPageState();
}

class _CreateEditContentPageState
    extends ConsumerState<CreateEditContentPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _bodyController;

  String? _selectedType;

  String? _mediaFilePath;
  String? _mediaFileName;
  String? _coverImagePath;

  bool _isPickingMedia = false;
  bool _isPickingCover = false;

  bool get _isEditing => widget.content != null;

  @override
  void initState() {
    super.initState();
    final c = widget.content;
    _titleController = TextEditingController(text: c?.title ?? '');
    _descriptionController =
        TextEditingController(text: c?.description ?? '');
    _bodyController = TextEditingController(text: c?.bodyText ?? '');
    _selectedType = c?.type;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _bodyController.dispose();
    super.dispose();
  }


  Future<void> _pickMedia(String type) async {
    if (_isPickingMedia) return;
    setState(() => _isPickingMedia = true);

    try {
      FileType fileType;
      List<String>? extensions;

      switch (type) {
        case 'AUDIO':
          fileType = FileType.audio;
        case 'VIDEO':
          fileType = FileType.video;
        default:
          fileType = FileType.custom;
          extensions = ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx'];
      }

      final result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: extensions,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedType = type;
          _mediaFilePath = result.files.single.path;
          _mediaFileName = result.files.single.name;
        });
      }
    } finally {
      if (mounted) setState(() => _isPickingMedia = false);
    }
  }

  Future<void> _pickCoverImage() async {
    if (_isPickingCover) return;
    setState(() => _isPickingCover = true);

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() => _coverImagePath = image.path);
      }
    } finally {
      if (mounted) setState(() => _isPickingCover = false);
    }
  }

  void _clearMedia() => setState(() {
        _selectedType = null;
        _mediaFilePath = null;
        _mediaFileName = null;
      });

  void _clearCover() => setState(() => _coverImagePath = null);


  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      _showSnack('Título e introducción son obligatorios.');
      return;
    }

    final type = _selectedType ?? (widget.content?.type);
    if (type == null) {
      _showSnack('Selecciona al menos un tipo de medio.');
      return;
    }

    await ref.read(saveContentNotifierProvider.notifier).save(
          id: widget.content?.id,
          title: title,
          description: description,
          type: type,
          bodyText: _bodyController.text.trim().isEmpty
              ? null
              : _bodyController.text.trim(),
          mediaFilePath: _mediaFilePath,
          coverImagePath: _coverImagePath,
        );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SaveContentState>(saveContentNotifierProvider, (_, next) {
      if (next is SaveContentSuccess) {
        ref.invalidate(contentsProvider);
        ref.read(saveContentNotifierProvider.notifier).reset();
        Navigator.of(context).pop();
      } else if (next is SaveContentError) {
        _showSnack(next.message);
        ref.read(saveContentNotifierProvider.notifier).reset();
      }
    });

    final state = ref.watch(saveContentNotifierProvider);
    final isLoading = state is SaveContentLoading;

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
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                disabledBackgroundColor: AppColors.primary.withAlpha(160),
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

          // Imagen de portada del contenido
          _buildLabel('Portada'),
          const SizedBox(height: 8),
          _CoverPicker(
            localPath: _coverImagePath,
            existingUrl:
                _coverImagePath == null ? widget.content?.coverImageUrl : null,
            isLoading: _isPickingCover || isLoading,
            onPick: isLoading ? null : _pickCoverImage,
            onClear: isLoading ? null : _clearCover,
          ),
          const SizedBox(height: 20),

          // Campos de texto
          _buildLabel('Título'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _titleController,
            hint: 'En busca de una meta',
          ),
          const SizedBox(height: 20),
          _buildLabel('Introducción'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _descriptionController,
            hint: 'Un artículo para reflexionar...',
          ),
          const SizedBox(height: 20),
          _buildLabel('Cuerpo'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _bodyController,
            hint:
                'Ha oído hablar de los objetivos y metas a largo plazo...',
            maxLines: 6,
            maxLength: 1000,
          ),
          const SizedBox(height: 28),

          // Archivo multimedia
          _buildLabel('Archivo multimedia'),
          const SizedBox(height: 8),
          _MediaPicker(
            selectedType: _selectedType,
            fileName: _mediaFileName,
            existingMediaUrl: _mediaFilePath == null
                ? widget.content?.mediaUrl
                : null,
            isLoading: _isPickingMedia || isLoading,
            onPick: isLoading ? null : _pickMedia,
            onClear: isLoading ? null : _clearMedia,
          ),
          const SizedBox(height: 24),

          // Botón de publicación
          _PublishToggle(
            value: _isEditing
                ? (widget.content?.isPublished ?? false)
                : false,
            onChanged: isLoading ? null : (_) {},
          ),
          const SizedBox(height: 40),

          AppButton(
            label: _isEditing ? 'GUARDAR CAMBIOS' : 'GUARDAR',
            isLoading: isLoading,
            onPressed: isLoading ? null : _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.inter(color: AppColors.textHint, fontSize: 14),
        filled: true,
        fillColor: AppColors.surface,
        counterStyle:
            const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    );
  }
}

// ── Publish toggle ────────────────────────────────────────────────────────────

class _PublishToggle extends StatefulWidget {
  const _PublishToggle({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  State<_PublishToggle> createState() => _PublishToggleState();
}

class _PublishToggleState extends State<_PublishToggle> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Publicar contenido',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: _value,
            onChanged: widget.onChanged == null
                ? null
                : (v) {
                    setState(() => _value = v);
                    widget.onChanged!(v);
                  },
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withAlpha(80),
            inactiveThumbColor: AppColors.textSecondary,
            inactiveTrackColor: AppColors.inputBorder,
          ),
        ],
      ),
    );
  }
}

// Widget para mostrar el selector de imagen de portada

class _CoverPicker extends StatelessWidget {
  const _CoverPicker({
    required this.localPath,
    required this.existingUrl,
    required this.isLoading,
    required this.onPick,
    required this.onClear,
  });

  final String? localPath;
  final String? existingUrl;
  final bool isLoading;
  final VoidCallback? onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final hasImage = localPath != null || existingUrl != null;

    return GestureDetector(
      onTap: hasImage ? null : onPick,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              height: 160,
              color: AppColors.surface,
              child: _imageContent,
            ),
          ),
          if (hasImage)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onClear,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.background.withAlpha(200),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.x,
                      size: 16, color: AppColors.textPrimary),
                ),
              ),
            ),
          if (!hasImage)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Toca para agregar portada',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget get _imageContent {
    if (localPath != null) {
      return Image.file(File(localPath!), fit: BoxFit.cover,
          width: double.infinity, height: 160);
    }
    if (existingUrl != null) {
      return Image.network(existingUrl!, fit: BoxFit.cover,
          width: double.infinity, height: 160,
          errorBuilder: (_, __, ___) => _placeholder);
    }
    return _placeholder;
  }

  Widget get _placeholder => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.image, color: AppColors.textHint, size: 36),
          const SizedBox(height: 8),
        ],
      );
}

// ── Media picker ──────────────────────────────────────────────────────────────

class _TypeOption {
  final String value;
  final IconData icon;
  final String label;
  const _TypeOption(this.value, this.icon, this.label);
}

const _mediaTypes = [
  _TypeOption('AUDIO', LucideIcons.mic, 'Audio'),
  _TypeOption('VIDEO', LucideIcons.video, 'Video'),
  _TypeOption('TEXT', LucideIcons.file_text, 'Documento'),
];

// Widget para mostrar el selector de archivo multimedia

class _MediaPicker extends StatelessWidget {
  const _MediaPicker({
    required this.selectedType,
    required this.fileName,
    required this.existingMediaUrl,
    required this.isLoading,
    required this.onPick,
    required this.onClear,
  });

  final String? selectedType;
  final String? fileName;
  final String? existingMediaUrl;
  final bool isLoading;
  final void Function(String type)? onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tile row
        Row(
          children: List.generate(_mediaTypes.length, (i) {
            final opt = _mediaTypes[i];
            final isSelected = selectedType == opt.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? 0 : 6,
                  right: i == _mediaTypes.length - 1 ? 0 : 6,
                ),
                child: _MediaTile(
                  icon: opt.icon,
                  label: opt.label,
                  isSelected: isSelected,
                  isLoading: isLoading,
                  onTap: onPick != null ? () => onPick!(opt.value) : null,
                ),
              ),
            );
          }),
        ),

        // File preview
        if (fileName != null) ...[
          const SizedBox(height: 10),
          _FilePreview(name: fileName!, onDelete: onClear),
        ] else if (existingMediaUrl != null) ...[
          const SizedBox(height: 10),
          _FilePreview(
            name: _shortenUrl(existingMediaUrl!),
            onDelete: null,
            isExisting: true,
          ),
        ],
      ],
    );
  }

  String _shortenUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return url;
    final segments = uri.pathSegments;
    return segments.isNotEmpty ? segments.last : url;
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isLoading,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(20)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.inputBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para mostrar el preview del archivo multimedia

class _FilePreview extends StatelessWidget {
  const _FilePreview({
    required this.name,
    required this.onDelete,
    this.isExisting = false,
  });

  final String name;
  final VoidCallback? onDelete;
  final bool isExisting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withAlpha(isExisting ? 50 : 100),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isExisting ? LucideIcons.link : LucideIcons.paperclip,
            color: AppColors.primary,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: const Icon(LucideIcons.x,
                  color: AppColors.textSecondary, size: 16),
            ),
        ],
      ),
    );
  }
}
