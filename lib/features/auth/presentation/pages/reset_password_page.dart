import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/app_text_form_field.dart';
import '../notifiers/reset_password_state.dart';
import '../providers/auth_providers.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(resetPasswordNotifierProvider.notifier).updatePassword(
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ResetPasswordState>(resetPasswordNotifierProvider, (_, state) {
      if (state is ResetPasswordError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
        ref.read(resetPasswordNotifierProvider.notifier).reset();
      }
      // ResetPasswordSuccess: AuthGate detecta el evento userUpdated de Supabase
      // y hace popUntil al root, donde AuthGate muestra HomeScreen.
    });

    final rpState = ref.watch(resetPasswordNotifierProvider);
    final isLoading = rpState is ResetPasswordLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    kToolbarHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    const AppLogo(),

                    const Spacer(),

                    AppTextFormField(
                      controller: _passwordController,
                      labelText: 'Contraseña',
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresa tu nueva contraseña.';
                        if (v.length < 6) return 'Mínimo 6 caracteres.';
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    AppTextFormField(
                      controller: _confirmController,
                      labelText: 'Confirmar Contraseña',
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _changePassword(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirm = !_obscureConfirm,
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Confirma tu contraseña.';
                        if (v != _passwordController.text) {
                          return 'Las contraseñas no coinciden.';
                        }
                        return null;
                      },
                    ),

                    const Spacer(),

                    AppButton(
                      label: 'CAMBIAR CONTRASEÑA',
                      backgroundColor: AppColors.primary,
                      onPressed: isLoading ? null : _changePassword,
                      isLoading: isLoading,
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
