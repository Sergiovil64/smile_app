import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/home/presentation/pages/admin_home_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/home/presentation/providers/home_providers.dart';
import '../constants/app_colors.dart';

/// Decide qué pantalla mostrar según si existe sesión activa en Supabase.
/// Supabase persiste la sesión localmente, por lo que el primer evento del
/// stream llega en milisegundos con la sesión restaurada (o null si no hay).
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(supabaseSessionProvider, (_, next) {
      next.whenData((authState) {
        final navigator = Navigator.of(context);

        if (authState.event == AuthChangeEvent.passwordRecovery) {
          // El usuario abrió el deep link de recuperación de contraseña.
          // Se navega a la pantalla de cambio de contraseña.
          navigator.push(
            MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
          );
          return;
        }

        // Para cualquier otro evento con sesión activa (signedIn, userUpdated, etc.)
        // se limpia el stack y AuthGate muestra HomeScreen.
        if (authState.session != null && navigator.canPop()) {
          navigator.popUntil((route) => route.isFirst);
        }
      });
    });

    final sessionAsync = ref.watch(supabaseSessionProvider);

    return sessionAsync.when(
      data: (authState) {
        if (authState.session != null &&
            authState.event != AuthChangeEvent.passwordRecovery) {
          return const _RoleGate();
        }
        return const LoginPage();
      },
      loading: () => const _SplashScreen(),
      error: (_, __) => const LoginPage(),
    );
  }
}

class _RoleGate extends ConsumerWidget {
  const _RoleGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    return profileAsync.when(
      data: (profile) {
        log('profile: ${profile?.role}');
        if (profile != null && profile.isAdmin) {
          return const AdminHomeScreen();
        }
        return const HomeScreen();
      },
      loading: () => const _SplashScreen(),
      error: (_, __) => const HomeScreen(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
