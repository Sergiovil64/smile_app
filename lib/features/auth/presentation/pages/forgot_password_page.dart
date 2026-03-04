import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/app_text_form_field.dart';
import '../../../../shared/widgets/app_text_link.dart';
import '../notifiers/forgot_password_state.dart';
import '../providers/auth_providers.dart';

// Página de recuperación de contraseña
// Este archivo implementa los estilos y la lógica de la página de recuperación de contraseña

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(forgotPasswordNotifierProvider.notifier).sendResetEmail(
          email: _emailController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ForgotPasswordState>(forgotPasswordNotifierProvider, (_, state) {
      if (state is ForgotPasswordError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
        ref.read(forgotPasswordNotifierProvider.notifier).reset();
      }
      if (state is ForgotPasswordSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Correo enviado a ${state.email}'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    });

    final fpState = ref.watch(forgotPasswordNotifierProvider);
    final isLoading = fpState is ForgotPasswordLoading;
    final emailSent = fpState is ForgotPasswordSuccess;

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
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 72),

                    const AppLogo(),

                    const Spacer(),

                    AppTextFormField(
                      controller: _emailController,
                      labelText: 'Correo electrónico',
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      readOnly: emailSent,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _sendResetEmail(),
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

                    const SizedBox(height: 20),

                    AppButton(
                      label: 'ENVIAR CORREO',
                      backgroundColor: AppColors.primary,
                      onPressed: (isLoading || emailSent) ? null : _sendResetEmail,
                      isLoading: isLoading,
                    ),

                    const Spacer(),

                    AppTextLink(
                      label: '¿No recibiste el correo?, envía de nuevo',
                      onPressed: emailSent
                          ? () {
                              ref
                                  .read(forgotPasswordNotifierProvider.notifier)
                                  .reset();
                            }
                          : null,
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
