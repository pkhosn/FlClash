import 'package:flutter/material.dart';
import 'provider_tokens.dart';

class V2ETTheme {
  const V2ETTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: V2ETTokens.primary,
      brightness: Brightness.light,
      primary: V2ETTokens.primary,
      surface: V2ETTokens.card,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: V2ETTokens.background,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: V2ETTokens.primarySoft.withValues(alpha: 0.5),
      fontFamily: V2ETTokens.fontFamily,
      fontFamilyFallback: V2ETTokens.fontFallback,
    );

    return base.copyWith(
      textTheme: _withV2ETFont(base.textTheme).copyWith(
        titleLarge: V2ETTokens.h1,
        titleMedium: V2ETTokens.h2,
        titleSmall: V2ETTokens.h3,
        bodyMedium: V2ETTokens.body,
        bodySmall: V2ETTokens.small,
      ),
      primaryTextTheme: _withV2ETFont(base.primaryTextTheme),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: V2ETTokens.input,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(V2ETTokens.radiusM),
          borderSide: const BorderSide(color: V2ETTokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(V2ETTokens.radiusM),
          borderSide: const BorderSide(color: V2ETTokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(V2ETTokens.radiusM),
          borderSide: const BorderSide(color: V2ETTokens.primary, width: 1.2),
        ),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: V2ETTokens.primary,
      brightness: Brightness.dark,
      primary: V2ETTokens.primary,
      surface: V2ETTokens.darkCard,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: V2ETTokens.darkBackground,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: V2ETTokens.primarySoft.withValues(alpha: 0.35),
      fontFamily: V2ETTokens.fontFamily,
      fontFamilyFallback: V2ETTokens.fontFallback,
    );

    return base.copyWith(
      textTheme: _withV2ETFont(base.textTheme),
      primaryTextTheme: _withV2ETFont(base.primaryTextTheme),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: V2ETTokens.darkInput,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(V2ETTokens.radiusM),
          borderSide: const BorderSide(color: V2ETTokens.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(V2ETTokens.radiusM),
          borderSide: const BorderSide(color: V2ETTokens.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(V2ETTokens.radiusM),
          borderSide: const BorderSide(color: V2ETTokens.primary, width: 1.2),
        ),
      ),
    );
  }

  static TextTheme _withV2ETFont(TextTheme theme) {
    return theme.copyWith(
      displayLarge: _font(theme.displayLarge),
      displayMedium: _font(theme.displayMedium),
      displaySmall: _font(theme.displaySmall),
      headlineLarge: _font(theme.headlineLarge),
      headlineMedium: _font(theme.headlineMedium),
      headlineSmall: _font(theme.headlineSmall),
      titleLarge: _font(theme.titleLarge),
      titleMedium: _font(theme.titleMedium),
      titleSmall: _font(theme.titleSmall),
      bodyLarge: _font(theme.bodyLarge),
      bodyMedium: _font(theme.bodyMedium),
      bodySmall: _font(theme.bodySmall),
      labelLarge: _font(theme.labelLarge),
      labelMedium: _font(theme.labelMedium),
      labelSmall: _font(theme.labelSmall),
    );
  }

  static TextStyle? _font(TextStyle? style) {
    return style?.copyWith(
      fontFamily: V2ETTokens.fontFamily,
      fontFamilyFallback: V2ETTokens.fontFallback,
    );
  }
}
