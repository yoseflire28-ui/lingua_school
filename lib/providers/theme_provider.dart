// ─────────────────────────────────────────────────────────────────────────────
// Lingua School — Theme Provider
// Controls light / dark mode via Provider state management.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  /// Whether dark mode is currently active.
  bool get isDarkMode => _isDarkMode;

  /// Toggles between light and dark theme and notifies listeners.
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  /// Sets dark mode explicitly (useful for persistence restoration).
  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      notifyListeners();
    }
  }
}
