import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../auth/domain/entities/user_profile_entity.dart';
import '../providers/home_providers.dart';

// Página de inicio para el administrador
// Este archivo implementa los estilos y la lógica de la página de inicio para el administrador
// También se encarga de la navegación a las páginas de gestión de usuarios y contenido

class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  int _currentIndex = 0;

  static const _titleStyle = TextStyle(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  Widget _buildTitle(AsyncValue<UserProfileEntity?> profileAsync) {
    if (_currentIndex == 0) {
      return profileAsync.maybeWhen(
        data: (profile) => Text(
          profile != null ? '¡Hola ${profile.firstName}!' : '¡Hola Admin!',
          style: _titleStyle,
        ),
        orElse: () => const Text('¡Hola Admin!', style: _titleStyle),
      );
    }
    const titles = ['', 'Usuarios', 'Contenido'];
    return Text(titles[_currentIndex], style: _titleStyle);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);

    final tabs = [
      _AdminDashboardTab(onGestionUsuarios: () => setState(() => _currentIndex = 1),
          onGestionContenido: () => setState(() => _currentIndex = 2)),
      const _AdminUsuariosTab(),
      const _AdminContenidoTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 110,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AppLogo(width: 100, padding: EdgeInsets.zero),
          ),
        ),
        title: _buildTitle(profileAsync),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.user),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.users),
            label: 'Usuarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.table_of_contents),
            label: 'Contenido',
          ),
        ],
      ),
    );
  }
}

class _AdminDashboardTab extends StatelessWidget {
  const _AdminDashboardTab({
    required this.onGestionUsuarios,
    required this.onGestionContenido,
  });

  final VoidCallback onGestionUsuarios;
  final VoidCallback onGestionContenido;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(width: 200, padding: EdgeInsets.zero),
            const SizedBox(height: 64),
            _AdminActionButton(
              label: 'GESTIÓN USUARIOS',
              onTap: onGestionUsuarios,
            ),
            const SizedBox(height: 24),
            _AdminActionButton(
              label: 'GESTIÓN CONTENIDO',
              onTap: onGestionContenido,
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminActionButton extends StatelessWidget {
  const _AdminActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 24),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 1.2,
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 22),
          ],
        ),
      ),
    );
  }
}

class _AdminUsuariosTab extends StatelessWidget {
  const _AdminUsuariosTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Gestión de Usuarios',
        style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
      ),
    );
  }
}

class _AdminContenidoTab extends StatelessWidget {
  const _AdminContenidoTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Gestión de Contenido',
        style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
      ),
    );
  }
}
