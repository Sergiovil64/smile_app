import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../constants/app_colors.dart';

/// Decide qué pantalla mostrar según si existe sesión activa en Supabase.
/// Supabase persiste la sesión localmente, por lo que el primer evento del
/// stream llega en milisegundos con la sesión restaurada (o null si no hay).
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(supabaseSessionProvider, (_, next) {
      next.whenData((_) {
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.popUntil((route) => route.isFirst);
        }
      });
    });

    final sessionAsync = ref.watch(supabaseSessionProvider);

    return sessionAsync.when(
      data: (authState) {
        if (authState.session != null) return const HomeScreen();
        return const LoginPage();
      },
      loading: () => const _SplashScreen(),
      error: (_, __) => const LoginPage(),
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
