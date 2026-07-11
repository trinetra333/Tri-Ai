import 'package:flutter/material.dart';

/// Tri Ai premium palette — deep violet/indigo surfaces with a warm gold accent,
/// echoing the brand mark's three-triangle motif.
class AppColors {
  AppColors._();

  // ── Brand Accents ──
  static const Color primary = Color(0xFF7B2FF7); // rich violet
  static const Color primaryDim = Color(0xFF9B4DFF); // lighter violet (dark-mode)
  static const Color secondary = Color(0xFFF2B33D); // warm gold (matches logo)
  static const Color secondaryDeep = Color(0xFFC77B1E); // deep amber

  // Semantic
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFF2B33D);
  static const Color error = Color(0xFFFF453A);
  static const Color info = Color(0xFF64D2FF);

  // Text (dark mode defaults — theme overrides for light)
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8AFD9);
  static const Color textMuted = Color(0xFF7A7291);

  // Backgrounds (dark mode) — deep indigo-black instead of flat black
  static const Color bg = Color(0xFF0E0A1F);
  static const Color surface = Color(0xFF1B1533);
  static const Color surfaceLight = Color(0xFF29213F);
  static const Color card = Color(0xFF1B1533);

  // Chat Bubbles
  static const Color userBubble = Color(0xFF7B2FF7);
  static const Color aiBubble = Color(0xFF1B1533);
  static const Color cmdBubble = Color(0xFF2E2414);

  // Border
  static const Color border = Color(0xFF352C52);
  static const Color borderLight = Color(0xFF433A63);
}
