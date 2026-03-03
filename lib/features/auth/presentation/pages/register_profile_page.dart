import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/app_text_form_field.dart';
import 'register_photo_page.dart';

// Página de registro de perfil
// Este archivo implementa los estilos y la lógica de la página de registro de perfil
// También se encarga de la navegación a la página de registro de foto
// y la navegación a la página de inicio

class RegisterProfilePage extends StatefulWidget {
  const RegisterProfilePage({
    super.key,
    this.lockedUserId,
    this.lockedEmail,
  });

  final String? lockedUserId;
  final String? lockedEmail;

  bool get isCompletingRegistration => lockedUserId != null;

  @override
  State<RegisterProfilePage> createState() => _RegisterProfilePageState();
}

// Estado de la página de registro de perfil
class _RegisterProfilePageState extends State<RegisterProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedGender = 'Masculino';
  DateTime? _birthDate;

  static const List<String> _genders = ['Masculino', 'Femenino', 'Otro'];

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.lockedEmail ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Método para seleccionar la fecha de nacimiento
  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 5, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: AppColors.onPrimary,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  // Método para continuar con el registro
  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona tu fecha de nacimiento.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RegisterPhotoPage(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          gender: _selectedGender,
          birthDate: _birthDate!,
          existingUserId: widget.lockedUserId,
        ),
      ),
    );
  }

  // Método para formatear la fecha de nacimiento
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$day/$month/$year';
  }

  // Método para construir la página de registro de perfil
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                const AppLogo(width: 220),

                const SizedBox(height: 32),

                AppTextFormField(
                  controller: _firstNameController,
                  labelText: 'Nombres',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Ingresa tus nombres.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                AppTextFormField(
                  controller: _lastNameController,
                  labelText: 'Apellidos',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Ingresa tus apellidos.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                AppTextFormField(
                  controller: _emailController,
                  labelText: 'Correo Electrónico',
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  readOnly: widget.isCompletingRegistration,
                  suffixIcon: widget.isCompletingRegistration
                      ? const Icon(
                          Icons.lock_outline,
                          color: AppColors.textSecondary,
                          size: 20,
                        )
                      : null,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Ingresa tu correo.';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                      return 'Correo no válido.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                if (!widget.isCompletingRegistration) ...[
                  AppTextFormField(
                    controller: _passwordController,
                    labelText: 'Contraseña',
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Ingresa tu contraseña.';
                      }
                      if (v.length < 6) return 'Mínimo 6 caracteres.';
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  AppTextFormField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirmar Contraseña',
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Confirma tu contraseña.';
                      }
                      if (v != _passwordController.text) {
                        return 'Las contraseñas no coinciden.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),
                ],

                const SizedBox(height: 14),

                _GenderDropdown(
                  value: _selectedGender,
                  items: _genders,
                  onChanged: (v) => setState(() => _selectedGender = v!),
                ),

                const SizedBox(height: 14),

                _BirthDateField(
                  date: _birthDate,
                  onTap: _pickBirthDate,
                  formatDate: _formatDate,
                ),

                const SizedBox(height: 32),

                AppButton(
                  label: 'CONTINUAR',
                  onPressed: _continue,
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget para seleccionar el género
class _GenderDropdown extends StatelessWidget {
  const _GenderDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      dropdownColor: AppColors.surface,
      iconEnabledColor: AppColors.textSecondary,
      style: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontSize: 16,
      ),
      decoration: const InputDecoration(labelText: 'Sexo'),
      items: items
          .map(
            (g) => DropdownMenuItem(
              value: g,
              child: Text(g),
            ),
          )
          .toList(),
    );
  }
}

// Widget para seleccionar la fecha de nacimiento
class _BirthDateField extends StatelessWidget {
  const _BirthDateField({
    required this.date,
    required this.onTap,
    required this.formatDate,
  });

  final DateTime? date;
  final VoidCallback onTap;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          controller: TextEditingController(
            text: date != null ? formatDate(date!) : '',
          ),
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: 'Fecha de Nacimiento',
            suffixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            hintText: 'DD/MM/AAAA',
            hintStyle: GoogleFonts.inter(
              color: AppColors.textSecondary,
            ),
          ),
          validator: (_) =>
              date == null ? 'Selecciona tu fecha de nacimiento.' : null,
        ),
      ),
    );
  }
}
