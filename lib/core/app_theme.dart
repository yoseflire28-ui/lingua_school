// ─────────────────────────────────────────────────────────────────────────────
// Lingua School — App Theme Configuration
// Applies brand colors to both light and dark ThemeData instances.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  // ─── Light Theme ─────────────────────────────────────────────────────────
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary:          AppColors.darkForestGreen,
        onPrimary:        AppColors.crispWhite,
        secondary:        AppColors.brightOrange,
        onSecondary:      AppColors.crispWhite,
        tertiary:         AppColors.vibrantGold,
        onTertiary:       AppColors.darkCharcoal,
        surface:          AppColors.crispWhite,
        onSurface:        AppColors.darkCharcoal,
        surfaceContainerHighest: AppColors.mintGreen,
        error:            AppColors.error,
        onError:          AppColors.crispWhite,
      ),

      scaffoldBackgroundColor: AppColors.mintGreen,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor:    AppColors.darkForestGreen,
        foregroundColor:    AppColors.crispWhite,
        elevation:          0,
        centerTitle:        false,
        titleTextStyle: TextStyle(
          color:      AppColors.crispWhite,
          fontSize:   20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.crispWhite),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:      AppColors.darkForestGreen,
        selectedItemColor:    AppColors.vibrantGold,
        unselectedItemColor:  AppColors.mintGreen,
        selectedLabelStyle:   TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        type:                 BottomNavigationBarType.fixed,
        elevation:            8,
      ),

      // Cards
      cardTheme: const CardThemeData(
        color:       AppColors.crispWhite,
        elevation:   2,
        shadowColor: AppColors.darkCharcoal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.brightOrange,
        foregroundColor: AppColors.crispWhite,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Elevated buttons (Save)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.vibrantGold,
          foregroundColor: AppColors.darkCharcoal,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: const Size(double.infinity, 50),
          elevation: 2,
        ),
      ),

      // Input fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.crispWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkForestGreen, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.darkForestGreen.withAlpha(100), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkForestGreen, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.darkTealGreen),
        prefixIconColor: AppColors.darkForestGreen,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.darkForestGreen;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.crispWhite),
        side: const BorderSide(color: AppColors.darkForestGreen, width: 2),
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.vibrantGold;
          return AppColors.crispWhite;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.darkForestGreen;
          return Colors.grey.shade400;
        }),
      ),

      // List tiles
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: AppColors.darkForestGreen,
        titleTextStyle: TextStyle(color: AppColors.darkCharcoal, fontSize: 15, fontWeight: FontWeight.w500),
        subtitleTextStyle: TextStyle(color: Colors.grey, fontSize: 13),
      ),

      textTheme: const TextTheme(
        headlineLarge:  TextStyle(color: AppColors.darkTealGreen,  fontWeight: FontWeight.w800, fontSize: 26),
        headlineMedium: TextStyle(color: AppColors.darkTealGreen,  fontWeight: FontWeight.w700, fontSize: 22),
        headlineSmall:  TextStyle(color: AppColors.darkTealGreen,  fontWeight: FontWeight.w600, fontSize: 18),
        titleLarge:     TextStyle(color: AppColors.darkCharcoal,   fontWeight: FontWeight.w700, fontSize: 16),
        titleMedium:    TextStyle(color: AppColors.darkCharcoal,   fontWeight: FontWeight.w600, fontSize: 14),
        bodyLarge:      TextStyle(color: AppColors.darkCharcoal,   fontSize: 15),
        bodyMedium:     TextStyle(color: AppColors.darkCharcoal,   fontSize: 13),
        bodySmall:      TextStyle(color: Colors.grey,              fontSize: 11),
      ),
    );
  }

  // ─── Dark Theme ──────────────────────────────────────────────────────────
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme.dark(
        primary:          AppColors.darkForestGreen,
        onPrimary:        AppColors.crispWhite,
        secondary:        AppColors.brightOrange,
        onSecondary:      AppColors.crispWhite,
        tertiary:         AppColors.vibrantGold,
        onTertiary:       AppColors.darkCharcoal,
        surface:          AppColors.darkTealGreen,
        onSurface:        AppColors.crispWhite,
        surfaceContainerHighest: AppColors.darkCharcoal,
        error:            AppColors.error,
        onError:          AppColors.crispWhite,
      ),

      scaffoldBackgroundColor: const Color(0xFF121212),

      // AppBar with gold bottom border accent
      appBarTheme: AppBarTheme(
        backgroundColor:  AppColors.darkForestGreen,
        foregroundColor:  AppColors.crispWhite,
        elevation:        0,
        centerTitle:      false,
        shape: const Border(
          bottom: BorderSide(color: AppColors.vibrantGold, width: 2),
        ),
        titleTextStyle: const TextStyle(
          color:      AppColors.crispWhite,
          fontSize:   20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        iconTheme: const IconThemeData(color: AppColors.crispWhite),
      ),

      // Bottom Navigation with gold accent
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor:      AppColors.darkForestGreen,
        selectedItemColor:    AppColors.vibrantGold,
        unselectedItemColor:  AppColors.mintGreen,
        selectedLabelStyle:   TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        type:                 BottomNavigationBarType.fixed,
        elevation:            8,
      ),

      // Cards — Dark Teal Green surface
      cardTheme: const CardThemeData(
        color:       AppColors.darkTealGreen,
        elevation:   4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      ),

      // FAB — Orange
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.brightOrange,
        foregroundColor: AppColors.crispWhite,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),

      // Elevated buttons (Save) — Keep gold
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.vibrantGold,
          foregroundColor: AppColors.darkCharcoal,
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          minimumSize: const Size(double.infinity, 50),
          elevation: 2,
        ),
      ),

      // Input fields — Dark teal surface
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkTealGreen,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.vibrantGold, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.vibrantGold.withAlpha(100), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.vibrantGold, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.vibrantGold),
        prefixIconColor: AppColors.vibrantGold,
        hintStyle: TextStyle(color: AppColors.crispWhite.withAlpha(180)),
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.vibrantGold.withAlpha(60),
        thickness: 1,
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.vibrantGold;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.darkCharcoal),
        side: const BorderSide(color: AppColors.vibrantGold, width: 2),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.vibrantGold;
          return AppColors.mintGreen;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.darkForestGreen;
          return Colors.grey.shade700;
        }),
      ),

      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: AppColors.vibrantGold,
        titleTextStyle: TextStyle(color: AppColors.crispWhite, fontSize: 15, fontWeight: FontWeight.w600),
        subtitleTextStyle: TextStyle(color: AppColors.vibrantGold, fontSize: 13),
      ),

      textTheme: const TextTheme(
        headlineLarge:  TextStyle(color: AppColors.crispWhite,   fontWeight: FontWeight.w800, fontSize: 26),
        headlineMedium: TextStyle(color: AppColors.crispWhite,   fontWeight: FontWeight.w700, fontSize: 22),
        headlineSmall:  TextStyle(color: AppColors.vibrantGold,   fontWeight: FontWeight.w600, fontSize: 18),
        titleLarge:     TextStyle(color: AppColors.crispWhite,   fontWeight: FontWeight.w700, fontSize: 16),
        titleMedium:    TextStyle(color: AppColors.crispWhite,   fontWeight: FontWeight.w600, fontSize: 14),
        bodyLarge:      TextStyle(color: AppColors.crispWhite,   fontSize: 15),
        bodyMedium:     TextStyle(color: AppColors.crispWhite,   fontSize: 13),
        bodySmall:      TextStyle(color: AppColors.vibrantGold,   fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}
