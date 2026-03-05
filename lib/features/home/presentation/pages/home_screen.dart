import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../auth/domain/entities/user_profile_entity.dart';
import '../providers/home_providers.dart';
import 'tabs/perfil_tab.dart';
import 'tabs/historial_tab.dart';
import 'tabs/actividades_tab.dart';
import 'tabs/contenido_tab.dart';

// Página de inicio
// Este archivo implementa los estilos y la lógica de la página de inicio
// Una vez que se ha iniciado sesión por parte del adolescente, se muestra esta página
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  static const List<Widget> _tabs = [
    PerfilTab(),
    HistorialTab(),
    ActividadesTab(),
    ContenidoTab(),
  ];

  static const List<String> _tabTitles = [
    '',
    'Historial',
    'Actividades',
    'Contenido',
  ];

  static const _titleStyle = TextStyle(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

// Función para construir el título de la página dinamicamente
  Widget _buildTitle(AsyncValue<UserProfileEntity?> profileAsync) {
    if (_currentIndex == 0) {
      return profileAsync.maybeWhen(
        data: (profile) => Text(
          profile != null ? '¡Hola ${profile.firstName}!' : '¡Hola!',
          style: _titleStyle,
        ),
        orElse: () => const SizedBox.shrink(),
      );
    }
    return Text(_tabTitles[_currentIndex], style: _titleStyle);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);

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
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.textSecondary,
            ),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
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
            icon: Icon(LucideIcons.notebook),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.brain),
            label: 'Actividades',
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
