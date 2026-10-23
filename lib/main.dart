// ─────────────────────────────────────────────────────────────────────────────
// Lingua School — App Entry Point
// Bootstraps providers and applies brand themes for light and dark modes.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/student_provider.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for a consistent mobile experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set the status bar appearance to match the Dark Forest Green AppBar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:            Colors.transparent,
    statusBarIconBrightness:   Brightness.light,
    systemNavigationBarColor:  Color(0xFF06402B), // darkForestGreen
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(
    // Register all providers at the root so they are accessible app-wide
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
      ],
      child: const LinguaSchoolApp(),
    ),
  );
}

class LinguaSchoolApp extends StatelessWidget {
  const LinguaSchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title:        'Lingua School',
      debugShowCheckedModeBanner: false,

      // ── Branded Light / Dark themes ──────────────────────────────────────
      theme:      AppTheme.light,
      darkTheme:  AppTheme.dark,
      themeMode:  themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      home: const MainNavigationScreen(),
    );
  }
}
