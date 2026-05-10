import 'package:flutter/material.dart';

class V2ETTokens {
  const V2ETTokens._();

  static const String brandName = 'v2et';

  // Do not hard-code runtime colors forever. These are only local defaults.
  // Later they should be overridden by object-storage remote JSON config.
  static const Color primary = Color(0xFF2D6CDF);
  static const Color primaryDark = Color(0xFF1F5CC3);
  static const Color primarySoft = Color(0xFFEAF2FF);
  static const Color background = Color(0xFFF3F7FC);
  static const Color authBackground = Color(0xFFFFFFFF);
  static const Color authTop = Color(0xFF36A3D1);
  static const Color authBottom = Color(0xFF1E57C8);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardSoft = Color(0xFFF7F9FC);
  static const Color input = Color(0xFFEFF4FA);
  static const Color border = Color(0xFFE4E9F1);
  static const Color textPrimary = Color(0xFF1D2433);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF98A2B3);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color teal = Color(0xFF24A39A);
  static const Color darkButton = Color(0xFF1F2937);
  static const Color sidebarIcon = Color(0xFF767B82);

  // Font policy:
  // 1. Preview/dev can rely on system CJK fonts when available.
  // 2. For release, bundle a CJK font yourself and declare it as V2ETSans
  //    in pubspec.yaml. Do not leave Chinese rendering to chance on Linux.
  // 3. Keep this list here so every TextStyle inherits the same fallback.
  static const String fontFamily = 'V2ETSans';
  static const List<String> fontFallback = <String>[
    'V2ETSans',
    '.AppleSystemUIFont',
    'PingFang SC',
    'PingFang TC',
    'Microsoft YaHei UI',
    'Microsoft YaHei',
    'SimHei',
    'Noto Sans CJK SC',
    'Noto Sans SC',
    'Source Han Sans SC',
    'WenQuanYi Micro Hei',
    'Roboto',
    'Arial',
    'sans-serif',
  ];

  static const double sidebarWidth = 120;
  static const double titleBarHeight = 30;
  static const double pagePadding = 24;
  static const double radiusXS = 8;
  static const double radiusS = 10;
  static const double radiusM = 14;
  static const double radiusL = 18;
  static const double radiusXL = 24;
  static const double radiusXXL = 34;

  static const BoxShadow softShadow = BoxShadow(
    color: Color(0x16000000),
    blurRadius: 24,
    offset: Offset(0, 12),
  );

  static const BoxShadow tinyShadow = BoxShadow(
    color: Color(0x10000000),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 24,
    height: 1.2,
    fontWeight: FontWeight.w800,
    color: textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w800,
    color: textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w800,
    color: textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 14,
    height: 1.45,
    color: textPrimary,
  );

  static const TextStyle small = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 12,
    height: 1.35,
    color: textSecondary,
  );

  static const TextStyle mini = TextStyle(
    fontFamily: fontFamily,
    fontFamilyFallback: fontFallback,
    fontSize: 10,
    height: 1.35,
    color: textMuted,
  );

  static TextStyle text({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
    Color color = textPrimary,
    double height = 1.35,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontFamilyFallback: fontFallback,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
    );
  }
}
