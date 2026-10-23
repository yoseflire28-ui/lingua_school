// ─────────────────────────────────────────────────────────────────────────────
// Lingua School — Main Navigation Screen
// BottomNavigationBar host connecting Home, Add Student, and Settings tabs.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../providers/student_provider.dart';
import 'home_screen.dart';
import 'add_edit_student_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Screens are kept in memory to preserve scroll state
  static const List<Widget> _screens = [
    HomeScreen(),
    AddEditStudentScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load students on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().loadStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap:        (i) => setState(() => _currentIndex = i),
        items: [
          BottomNavigationBarItem(
            icon:       const Icon(Icons.people_alt_outlined),
            activeIcon: const Icon(Icons.people_alt),
            label:      lang.t('students'),
          ),
          BottomNavigationBarItem(
            icon:       const Icon(Icons.person_add_outlined),
            activeIcon: const Icon(Icons.person_add),
            label:      lang.t('add_student'),
          ),
          BottomNavigationBarItem(
            icon:       const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label:      lang.t('settings'),
          ),
        ],
      ),
    );
  }
}
