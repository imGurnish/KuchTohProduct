import 'package:flutter/material.dart';

/// Mindspace App Color Palette
///
/// Based on the premium authentication design with light/dark mode support.
/// Colors extracted from the provided theme mockup.
abstract class AppColors {
  // ============================================
  // LIGHT MODE COLORS
  // ============================================

  /// Light mode background - soft light gray
  static const Color lightBackground = Color(0xFFF5F5F5);

  /// Light mode surface - pure white for cards
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Light mode primary - dark navy for buttons and text
  static const Color lightPrimary = Color(0xFF1E1E2E);

  /// Light mode primary text
  static const Color lightTextPrimary = Color(0xFF1E1E2E);

  /// Light mode secondary text
  static const Color lightTextSecondary = Color(0xFF6B7280);

  /// Light mode border/divider
  static const Color lightBorder = Color(0xFFE5E7EB);

  /// Light mode subtle background for inputs
  static const Color lightInputBackground = Color(0xFFF9FAFB);

  // ============================================
  // DARK MODE COLORS
  // ============================================

  /// Dark mode background - very deep navy
  static const Color darkBackground = Color(0xFF0F0F1A);

  /// Dark mode surface - slightly lighter navy for cards
  static const Color darkSurface = Color(0xFF1A1A2E);

  /// Dark mode elevated surface - for elevated cards/modals
  static const Color darkSurfaceElevated = Color(0xFF252542);

  /// Dark mode primary - white for buttons
  static const Color darkPrimary = Color(0xFFFFFFFF);

  /// Dark mode accent - purple for badges and highlights
  static const Color darkAccent = Color(0xFF7C3AED);

  /// Dark mode accent variant - lighter purple
  static const Color darkAccentLight = Color(0xFF8B5CF6);

  /// Dark mode primary text
  static const Color darkTextPrimary = Color(0xFFFFFFFF);

  /// Dark mode secondary text
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  /// Dark mode muted text
  static const Color darkTextMuted = Color(0xFF6B7280);

  /// Dark mode border/divider
  static const Color darkBorder = Color(0xFF374151);

  /// Dark mode input background
  static const Color darkInputBackground = Color(0xFF1F1F35);

  // ============================================
  // SHARED / SEMANTIC COLORS
  // ============================================

  /// Success green
  static const Color success = Color(0xFF10B981);

  /// Error red
  static const Color error = Color(0xFFEF4444);

  /// Warning amber
  static const Color warning = Color(0xFFF59E0B);

  /// Info blue
  static const Color info = Color(0xFF3B82F6);

  /// Google brand red
  static const Color googleRed = Color(0xFFDB4437);

  /// Gradient colors for dark mode accents
  static const Color gradientStart = Color(0xFF7C3AED);
  static const Color gradientEnd = Color(0xFF4F46E5);

  // ============================================
  // TRANSPARENCY VARIANTS
  // ============================================

  /// White with 10% opacity - for subtle highlights
  static const Color white10 = Color(0x1AFFFFFF);

  /// White with 20% opacity
  static const Color white20 = Color(0x33FFFFFF);

  /// Black with 10% opacity - for subtle shadows
  static const Color black10 = Color(0x1A000000);

  /// Black with 20% opacity
  static const Color black20 = Color(0x33000000);

  /// Purple with 20% opacity - for badge backgrounds
  static const Color purple20 = Color(0x337C3AED);
}
