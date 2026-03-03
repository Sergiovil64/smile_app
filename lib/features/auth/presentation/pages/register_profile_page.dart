import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                      if (!_PasswordCriteria.allMet(v)) {
                        return 'La contraseña no cumple los requisitos.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _passwordController,
                    builder: (_, value, __) =>
                        _PasswordStrengthIndicator(password: value.text),
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

                _GenderDropdown(
                  value: _selectedGender,
                  items: _genders,
                  onChanged: (v) => setState(() => _selectedGender = v!),
                ),

                const SizedBox(height: 14),

                _BirthDateField(
                  date: _birthDate,
                  onDateChanged: (d) => setState(() => _birthDate = d),
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

// Criterios de contraseña requeridos por el backend
abstract class _PasswordCriteria {
  static bool hasLength(String v) => v.length >= 12;
  static bool hasLowercase(String v) => v.contains(RegExp(r'[a-z]'));
  static bool hasUppercase(String v) => v.contains(RegExp(r'[A-Z]'));
  static bool hasDigit(String v) => v.contains(RegExp(r'[0-9]'));
  static bool hasSpecial(String v) =>
      v.contains(RegExp(r'''[!@#$%^&*()\-_=+\[\]{};':"\\|,.<>?/`~]'''));

  static bool allMet(String v) =>
      hasLength(v) &&
      hasLowercase(v) &&
      hasUppercase(v) &&
      hasDigit(v) &&
      hasSpecial(v);
}

// Indicador visual de fortaleza de contraseña
class _PasswordStrengthIndicator extends StatelessWidget {
  const _PasswordStrengthIndicator({required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    final metCount = [
      _PasswordCriteria.hasLength(password),
      _PasswordCriteria.hasLowercase(password),
      _PasswordCriteria.hasUppercase(password),
      _PasswordCriteria.hasDigit(password),
      _PasswordCriteria.hasSpecial(password),
    ].where((c) => c).length;

    final Color barColor = switch (metCount) {
      0 || 1 => AppColors.error,
      2 || 3 => const Color(0xFFFF9F0A),
      4 => AppColors.primary,
      _ => const Color(0xFF30D158),
    };

    final String strengthLabel = switch (metCount) {
      0 || 1 => 'Muy débil',
      2 || 3 => 'Débil',
      4 => 'Casi lista',
      _ => 'Segura',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: metCount / 5,
                    minHeight: 4,
                    backgroundColor: AppColors.inputBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                strengthLabel,
                style: GoogleFonts.inter(
                  color: barColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _CriteriaRow(
            met: _PasswordCriteria.hasLength(password),
            label: 'Mínimo 12 caracteres',
          ),
          _CriteriaRow(
            met: _PasswordCriteria.hasUppercase(password),
            label: 'Una letra mayúscula (A-Z)',
          ),
          _CriteriaRow(
            met: _PasswordCriteria.hasLowercase(password),
            label: 'Una letra minúscula (a-z)',
          ),
          _CriteriaRow(
            met: _PasswordCriteria.hasDigit(password),
            label: 'Un número (0-9)',
          ),
          _CriteriaRow(
            met: _PasswordCriteria.hasSpecial(password),
            label: 'Un carácter especial (!@#\$...)',
          ),
        ],
      ),
    );
  }
}

class _CriteriaRow extends StatelessWidget {
  const _CriteriaRow({required this.met, required this.label});

  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = met ? const Color(0xFF30D158) : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// Formatea la entrada numérica automáticamente como DD/MM/AAAA.
class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();

    final buf = StringBuffer();
    for (int i = 0; i < digits.length && i < 8; i++) {
      if (i == 2 || i == 4) buf.write('/');
      buf.write(digits[i]);
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Widget para ingresar la fecha de nacimiento (texto libre + calendario).
class _BirthDateField extends StatefulWidget {
  const _BirthDateField({
    required this.date,
    required this.onDateChanged,
  });

  final DateTime? date;
  final ValueChanged<DateTime?> onDateChanged;

  @override
  State<_BirthDateField> createState() => _BirthDateFieldState();
}

class _BirthDateFieldState extends State<_BirthDateField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.date != null ? _fmt(widget.date!) : '',
    );
  }

  @override
  void didUpdateWidget(_BirthDateField old) {
    super.didUpdateWidget(old);
    if (widget.date != old.date && widget.date != null) {
      final text = _fmt(widget.date!);
      if (_controller.text != text) _controller.text = text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  DateTime? _parse(String text) {
    if (text.length != 10) return null;
    try {
      final p = text.split('/');
      if (p.length != 3) return null;
      final day = int.parse(p[0]);
      final month = int.parse(p[1]);
      final year = int.parse(p[2]);
      final date = DateTime(year, month, day);
      if (date.day != day || date.month != month || date.year != year) {
        return null;
      }
      return date;
    } catch (_) {
      return null;
    }
  }

  Future<void> _openPicker() async {
    final now = DateTime.now();
    final current = _parse(_controller.text);
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? widget.date ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 5, now.month, now.day),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: AppColors.onPrimary,
            surface: AppColors.surface,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _controller.text = _fmt(picked);
      widget.onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: [_DateInputFormatter()],
      style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 16),
      decoration: InputDecoration(
        labelText: 'Fecha de Nacimiento',
        hintText: 'DD/MM/AAAA',
        hintStyle: GoogleFonts.inter(color: AppColors.textSecondary),
        suffixIcon: IconButton(
          icon: const Icon(
            Icons.calendar_today_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
          onPressed: _openPicker,
        ),
      ),
      onChanged: (value) => widget.onDateChanged(_parse(value)),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ingresa tu fecha de nacimiento.';
        }
        final date = _parse(value);
        if (date == null) return 'Fecha no válida. Usa DD/MM/AAAA.';
        final now = DateTime.now();
        if (date.isBefore(DateTime(1920))) return 'Fecha no válida.';
        if (date.isAfter(DateTime(now.year - 10, now.month, now.day))) {
          return 'Debes tener al menos 10 años.';
        }
        return null;
      },
    );
  }
}
