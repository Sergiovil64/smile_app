import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../auth/domain/entities/user_profile_entity.dart';
import '../../../content/presentation/providers/content_providers.dart';
import '../providers/home_providers.dart';
import 'tabs/perfil_tab.dart';
import 'tabs/historial_tab.dart';
import 'tabs/actividades_tab.dart';
import 'tabs/contenido_tab.dart';

/// Pantalla principal para usuarios adolescentes tras iniciar sesión.
///
/// Muestra una barra de navegación inferior con 4 tabs: Perfil, Historial,
/// Actividades y Contenido. El título del AppBar cambia según el tab activo.
/// Al cambiar a Contenido se invalida [contentsProvider] para refrescar datos.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const PerfilTab(),
    const HistorialTab(),
    const ActividadesTab(),
    const ContenidoTab(),
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

  /// Construye el título del AppBar: saludo con nombre en Perfil, nombre del tab en el resto.
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
        onTap: (index) {
          if (index == 3) ref.invalidate(contentsProvider);
          setState(() => _currentIndex = index);
        },
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
