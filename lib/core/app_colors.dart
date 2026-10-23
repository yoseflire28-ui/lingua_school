// ─────────────────────────────────────────────────────────────────────────────
// Lingua School — Brand Color Constants
// All hex values are exact brand specifications. Do NOT modify without approval.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary brand colors
  static const Color darkForestGreen = Color(0xFF06402B); // AppBars, Main Buttons
  static const Color mintGreen       = Color(0xFFD9F5E5); // Light Scaffold / Surfaces
  static const Color vibrantGold     = Color(0xFFE1A712); // Accents / Save Buttons
  static const Color darkTealGreen   = Color(0xFF0B513A); // Headers / Titles / Dark cards
  static const Color brightOrange    = Color(0xFFEB7A10); // FABs / Highlights / Dots
  static const Color crispWhite      = Color(0xFFFFFFFF); // Card Backgrounds / Inputs
  static const Color darkCharcoal    = Color(0xFF1A1A1A); // Body Text / Dark Mode Base

  // Derived convenience colors
  static const Color success   = Color(0xFF2E7D32);
  static const Color warning   = Color(0xFFF57C00);
  static const Color error     = Color(0xFFD32F2F);
  static const Color divider   = Color(0xFFB2DFDB);

  // Payment badge colors
  static const Color paidGreen   = Color(0xFF2E7D32);
  static const Color unpaidRed   = Color(0xFFD32F2F);
}
