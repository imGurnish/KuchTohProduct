import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Mindspace Typography System
///
/// Uses Inter font family for a clean, modern look.
/// Consistent sizing and weight scale across the app.
abstract class AppTypography {
  /// Base text style with Inter font
  static TextStyle get _baseTextStyle => GoogleFonts.inter();

  // ============================================
  // DISPLAY STYLES (Large Headlines)
  // ============================================

  /// Display Large - 57px, used for hero sections
  static TextStyle displayLarge({Color? color}) => _baseTextStyle.copyWith(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.12,
    color: color,
  );

  /// Display Medium - 45px
  static TextStyle displayMedium({Color? color}) => _baseTextStyle.copyWith(
    fontSize: 45,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.16,
    color: color,
  );

  /// Display Small - 36px
  static TextStyle displaySmall({Color? color}) => _baseTextStyle.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.22,
    color: color,
  );

  // ============================================
  // HEADLINE STYLES
  // ============================================

  /// Headline Large - 32px, main screen titles
  static TextStyle headlineLarge({Color? color}) => _baseTextStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.25,
    color: color,
  );

  /// Headline Medium - 28px, "Mindspace" branding
  static TextStyle headlineMedium({Color? color}) => _baseTextStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.29,
    color: color,
  );

  /// Headline Small - 24px
  static TextStyle headlineSmall({Color? color}) => _baseTextStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
    color: color,
  );

  // ============================================
  // TITLE STYLES
  // ============================================

  /// Title Large - 22px, section headers
  static TextStyle titleLarge({Color? color}) => _baseTextStyle.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
    color: color,
  );

  /// Title Medium - 16px, card titles
  static TextStyle titleMedium({Color? color}) => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
    color: color,
  );

  /// Title Small - 14px
  static TextStyle titleSmall({Color? color}) => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
    color: color,
  );

  // ============================================
  // BODY STYLES
  // ============================================

  /// Body Large - 16px, main content
  static TextStyle bodyLarge({Color? color}) => _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
    color: color,
  );

  /// Body Medium - 14px, secondary content
  static TextStyle bodyMedium({Color? color}) => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
    color: color,
  );

  /// Body Small - 12px, captions and hints
  static TextStyle bodySmall({Color? color}) => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: color,
  );

  // ============================================
  // LABEL STYLES
  // ============================================

  /// Label Large - 14px, button text
  static TextStyle labelLarge({Color? color}) => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
    color: color,
  );

  /// Label Medium - 12px, smaller buttons
  static TextStyle labelMedium({Color? color}) => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
    color: color,
  );

  /// Label Small - 11px, badges
  static TextStyle labelSmall({Color? color}) => _baseTextStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.45,
    color: color,
  );

  // ============================================
  // SPECIAL STYLES
  // ============================================

  /// Tagline - for "Capture everything, remember all"
  static TextStyle tagline({Color? color}) => _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
    color: color,
  );

  /// Footer links - "TERMS OF USE", "PRIVACY POLICY"
  static TextStyle footerLink({Color? color}) => _baseTextStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    height: 1.45,
    color: color,
  );

  /// Badge text - "Privacy-Focused Architecture"
  static TextStyle badge({Color? color}) => _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    height: 1.33,
    color: color,
  );
}
