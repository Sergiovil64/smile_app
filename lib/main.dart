import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/auth_gate.dart';

// Punto de entrada de la aplicación
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Cargar variables de entorno
  await dotenv.load();

  // Inicializar Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Ejecutar la aplicación
  runApp(
    const ProviderScope(
      child: SmileApp(),
    ),
  );
}

// Aplicación principal
class SmileApp extends StatelessWidget {
  const SmileApp({super.key});

  // Construir la aplicación
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      locale: const Locale('es'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
      ],
      home: const AuthGate(),
    );
  }
}
