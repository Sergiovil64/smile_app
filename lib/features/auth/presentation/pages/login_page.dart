import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/app_text_form_field.dart';
import '../../../../shared/widgets/app_text_link.dart';
import '../notifiers/auth_state.dart';
import '../providers/auth_providers.dart';
import 'forgot_password_page.dart';
import 'register_profile_page.dart';

// Página de inicio de sesión
// Este archivo implementa los estilos y la lógica de la página de inicio de sesión
// También se encarga de la navegación a la página de registro de perfil
// y la navegación a la página de inicio

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

// Estado de la página de inicio de sesión
class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Método para iniciar sesión
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  // Método para ir a la página de registro
  void _goToRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterProfilePage()),
    );
  }

  // Método para construir la página de inicio de sesión
  @override
  Widget build(BuildContext context) {
    ref.listen<LoginState>(authNotifierProvider, (_, state) {
      // Si ocurre un error, se muestra un mensaje de error
      if (state is LoginError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
        ref.read(authNotifierProvider.notifier).reset();
      }
      // LoginSuccess: ref.listen en AuthGate detecta el cambio de sesión y hace pop al root.
      // Si el inicio de sesión es exitoso pero el perfil no está completo, se muestra un mensaje de perfil incompleto
      if (state is LoginProfileIncomplete) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Completa tu perfil para continuar.'),
          ),
        );
        // Se navega a la página de registro de perfil
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RegisterProfilePage(
              lockedUserId: state.user.id,
              lockedEmail: state.user.email,
            ),
          ),
        );
        ref.read(authNotifierProvider.notifier).reset();
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is LoginLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
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

                    const SizedBox(height: 16),

                    Text(
                      'Tu espacio a tu ritmo',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const Spacer(),

                    AppTextFormField(
                      controller: _emailController,
                      labelText: 'Correo electrónico',
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
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

                    AppTextFormField(
                      controller: _passwordController,
                      labelText: 'Contraseña',
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _signIn(),
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
                        if (v == null || v.isEmpty) return 'Ingresa tu contraseña.';
                        if (v.length < 6) return 'Mínimo 6 caracteres.';
                        return null;
                      },
                    ),

                    const Spacer(),

                    AppButton(
                      label: 'INGRESAR',
                      backgroundColor: AppColors.primary,
                      onPressed: isLoading ? null : _signIn,
                      isLoading: isLoading,
                    ),

                    const SizedBox(height: 16),

                    AppButton(
                      label: 'CREAR CUENTA',
                      backgroundColor: AppColors.primaryLight,
                      onPressed: isLoading ? null : _goToRegister,
                    ),

                    const SizedBox(height: 28),

                    AppTextLink(
                      label: '¿Problemas para entrar?',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ForgotPasswordPage(),
                          ),
                        );
                      },
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
