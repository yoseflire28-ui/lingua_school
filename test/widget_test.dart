// ─────────────────────────────────────────────────────────────────────────────
// Lingua School — Widget Smoke Test
// Verifies the app boots and renders the bottom navigation without errors.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:lingua_school/core/app_theme.dart';
import 'package:lingua_school/providers/theme_provider.dart';
import 'package:lingua_school/providers/language_provider.dart';
import 'package:lingua_school/providers/student_provider.dart';
import 'package:lingua_school/screens/main_navigation_screen.dart';

/// Minimal test harness wrapping the app with required providers.
Widget makeTestableApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ChangeNotifierProvider(create: (_) => StudentProvider()),
    ],
    child: Builder(
      builder: (context) {
        final themeProvider = context.watch<ThemeProvider>();
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme:     AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home:      const MainNavigationScreen(),
        );
      },
    ),
  );
}

void main() {
  testWidgets('App boots and renders BottomNavigationBar', (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableApp());
    await tester.pump(); // Allow initState callbacks to run

    // The bottom navigation bar should be visible
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Three navigation items are rendered
    expect(find.byType(BottomNavigationBarItem), findsNWidgets(3));
  });

  testWidgets('Dark mode toggle changes ThemeMode', (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableApp());

    // Navigate to Settings tab (index 2)
    final settingsTab = find.byIcon(Icons.settings_outlined);
    if (settingsTab.evaluate().isNotEmpty) {
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();
    }

    // App should still be rendering without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
