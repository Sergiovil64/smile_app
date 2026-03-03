import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../notifiers/register_state.dart';
import '../providers/register_providers.dart';

// Página de registro de foto
// Este archivo implementa los estilos y la lógica de la página de registro de foto
// También se encarga de la navegación a la página de inicio

class RegisterPhotoPage extends ConsumerStatefulWidget {
  const RegisterPhotoPage({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.gender,
    required this.birthDate,
    this.existingUserId,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String gender;
  final DateTime birthDate;

  // Si está presente, el usuario ya existe en Auth.
  // Se llama completeProfile() en lugar de register().
  final String? existingUserId;

  @override
  ConsumerState<RegisterPhotoPage> createState() => _RegisterPhotoPageState();
}

// Estado de la página de registro de foto
class _RegisterPhotoPageState extends ConsumerState<RegisterPhotoPage> {
  XFile? _selectedImage;
  final _picker = ImagePicker();

  /// Se llena si el auth user ya fue creado pero el perfil falló.
  /// En ese caso el reintento usa completeProfile() en lugar de register().
  late String? _effectiveUserId;

  @override
  void initState() {
    super.initState();
    _effectiveUserId = widget.existingUserId;
  }

  // Método para seleccionar la foto de perfil
  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  // Método para completar el registro
  Future<void> _complete() async {
    final notifier = ref.read(registerNotifierProvider.notifier);

    if (_effectiveUserId != null) {
      await notifier.completeProfile(
        userId: _effectiveUserId!,
        email: widget.email,
        firstName: widget.firstName,
        lastName: widget.lastName,
        gender: widget.gender,
        birthDate: widget.birthDate,
        avatarLocalPath: _selectedImage?.path,
      );
    } else {
      await notifier.register(
        email: widget.email,
        password: widget.password,
        firstName: widget.firstName,
        lastName: widget.lastName,
        gender: widget.gender,
        birthDate: widget.birthDate,
        avatarLocalPath: _selectedImage?.path,
      );
    }
  }

  // Método para construir la página de registro de foto
  @override
  Widget build(BuildContext context) {
    ref.listen<RegisterState>(registerNotifierProvider, (_, state) {
      if (state is RegisterError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
        ref.read(registerNotifierProvider.notifier).reset();
      }
      if (state is RegisterPartialSuccess) {
        // Auth creado, perfil falló: guardar el userId para que el reintento
        // use completeProfile() directamente sin volver a llamar signUp().
        setState(() => _effectiveUserId = state.userId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
        ref.read(registerNotifierProvider.notifier).reset();
      }
      // RegisterSuccess: ref.listen en AuthGate detecta el cambio de sesión y hace pop al root.
    });

    final registerState = ref.watch(registerNotifierProvider);
    final isLoading = registerState is RegisterLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),

              const SizedBox(height: 8),

              const AppLogo(width: 220),

              const Spacer(),

              _AvatarPicker(
                selectedImage: _selectedImage,
                onTap: isLoading ? null : _pickImage,
              ),

              const SizedBox(height: 24),

              AppButton(
                label: 'SUBE UNA FOTO DE PERFIL',
                backgroundColor: AppColors.primary,
                showIcon: false,
                onPressed: isLoading ? null : _pickImage,
              ),

              const Spacer(),

              AppButton(
                label: 'COMPLETAR REGISTRO',
                onPressed: isLoading ? null : _complete,
                isLoading: isLoading,
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget para seleccionar la foto de perfil

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.selectedImage,
    required this.onTap,
  });

  final XFile? selectedImage;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selectedImage != null
                ? AppColors.primary
                : AppColors.inputBorder,
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: selectedImage != null
            ? Image.file(
                File(selectedImage!.path),
                fit: BoxFit.cover,
              )
            : const _AvatarPlaceholder(),
      ),
    );
  }
}

// Widget para mostrar el placeholder de la foto de perfil
class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PersonIconPainter(),
    );
  }
}

class _PersonIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const bgColor = Color(0xFFD0E4F0);
    const fgColor = Color(0xFF8AB4CC);

    final bgPaint = Paint()..color = bgColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final fgPaint = Paint()..color = fgColor;

    final headRadius = size.width * 0.18;
    final headCenter = Offset(size.width / 2, size.height * 0.35);
    canvas.drawCircle(headCenter, headRadius, fgPaint);

    final bodyRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.55,
        size.width * 0.6,
        size.height * 0.45,
      ),
      topLeft: const Radius.circular(60),
      topRight: const Radius.circular(60),
    );
    canvas.drawRRect(bodyRect, fgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
