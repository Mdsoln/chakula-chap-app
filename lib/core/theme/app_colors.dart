import 'package:flutter/material.dart';


abstract class AppColors {
  // ── Brand Primary (Navy) ──────────────────────────────────
  static const Color navyDeep    = Color(0xFF0A1628); // Background deep
  static const Color navyDark    = Color(0xFF0F2044); // Card dark
  static const Color navyMedium  = Color(0xFF1A3461); // Surface medium
  static const Color navyLight   = Color(0xFF1E3F7A); // Elevated
  static const Color navyAccent  = Color(0xFF2C5282); // Subtle border

  // ── Brand Accent (Gold) ───────────────────────────────────
  static const Color goldPure    = Color(0xFFD4A017); // Core gold
  static const Color goldBright  = Color(0xFFFFBF00); // Bright gold CTA
  static const Color goldLight   = Color(0xFFFFD966); // Light gold
  static const Color goldMuted   = Color(0xFFB8860B); // Muted gold
  static const Color goldGlow    = Color(0x33FFD700); // Gold glow overlay

  // ── Semantic Colors ───────────────────────────────────────
  static const Color success     = Color(0xFF2ECC71);
  static const Color successBg   = Color(0x1A2ECC71);
  static const Color error       = Color(0xFFE53E3E);
  static const Color errorBg     = Color(0x1AE53E3E);
  static const Color warning     = Color(0xFFF6AD55);
  static const Color warningBg   = Color(0x1AF6AD55);
  static const Color info        = Color(0xFF63B3ED);

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary  = Color(0xFFF7FAFC);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textMuted    = Color(0xFF718096);
  static const Color textDisabled = Color(0xFF4A5568);

  // ── Surfaces ──────────────────────────────────────────────
  static const Color surface      = Color(0xFF132237);
  static const Color surfaceCard  = Color(0xFF1A2F4A);
  static const Color surfaceElevated = Color(0xFF1E3654);
  static const Color surfaceDivider  = Color(0xFF1E3461);

  // ── Payment Brand Colors ──────────────────────────────────
  static const Color mpesa        = Color(0xFF4CAF50);
  static const Color MixYas     = Color(0xFF00BCD4);
  static const Color airtelMoney  = Color(0xFFF44336);
  static const Color azamPesa     = Color(0xFF2196F3);
  static const Color selcom       = Color(0xFFFF9800);
  static const Color cashOnDelivery = Color(0xFF9E9E9E);

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [navyDeep, navyMedium],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldBright, goldMuted],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0A1628), Color(0xFF1A3461)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const RadialGradient goldGlowGradient = RadialGradient(
    colors: [Color(0x4DFFD700), Color(0x00FFD700)],
    radius: 0.8,
  );
}