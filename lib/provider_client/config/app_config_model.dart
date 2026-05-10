import 'package:flutter/material.dart';

class AppConfig {
  const AppConfig({
    required this.brandName,
    required this.windowTitle,
    required this.versionText,
    required this.apiBaseUrl,
    required this.apiPrefix,
    required this.panelType,
    required this.crispWebsiteId,
    required this.enableRegister,
    required this.enableStore,
    required this.enableInvite,
    required this.enableConnectionPage,
    required this.enableCrisp,
    required this.enableNoticePopup,
    required this.enablePaymentInApp,
    required this.primaryColor,
    required this.backgroundColor,
    required this.loginBackgroundUrl,
    required this.useMockAuthBackground,
  });

  final String brandName;
  final String windowTitle;
  final String versionText;
  final String apiBaseUrl;
  final String apiPrefix;
  final String panelType;
  final String crispWebsiteId;
  final bool enableRegister;
  final bool enableStore;
  final bool enableInvite;
  final bool enableConnectionPage;
  final bool enableCrisp;
  final bool enableNoticePopup;
  final bool enablePaymentInApp;
  final Color primaryColor;
  final Color backgroundColor;
  final String loginBackgroundUrl;
  final bool useMockAuthBackground;

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final app = (json['app'] as Map?) ?? const {};
    final api = (json['api'] as Map?) ?? const {};
    final features = (json['features'] as Map?) ?? const {};
    final customerService = (json['customerService'] as Map?) ?? const {};
    final theme = (json['theme'] as Map?) ?? const {};
    final assets = (json['assets'] as Map?) ?? const {};
    return AppConfig(
      brandName: app['brandName']?.toString() ?? 'v2et',
      windowTitle: app['windowTitle']?.toString() ?? 'v2et',
      versionText: app['versionText']?.toString() ?? 'v1.0.0',
      apiBaseUrl: api['baseUrl']?.toString() ?? '',
      apiPrefix: api['apiPrefix']?.toString() ?? '',
      panelType: api['panelType']?.toString() ?? 'v2board',
      crispWebsiteId: customerService['crispWebsiteId']?.toString() ?? '',
      enableRegister: features['enableRegister'] != false,
      enableStore: features['enableStore'] != false,
      enableInvite: features['enableInvite'] != false,
      enableConnectionPage: features['enableConnectionPage'] == true,
      enableCrisp: features['enableCrisp'] != false,
      enableNoticePopup: features['enableNoticePopup'] != false,
      enablePaymentInApp: features['enablePaymentInApp'] != false,
      primaryColor: _color(theme['primaryColor'], const Color(0xFF2D6CDF)),
      backgroundColor: _color(theme['backgroundColor'], const Color(0xFFF3F7FC)),
      loginBackgroundUrl: assets['loginBackgroundUrl']?.toString() ?? '',
      useMockAuthBackground: assets['useMockAuthBackground'] == true,
    );
  }

  static Color _color(dynamic value, Color fallback) {
    if (value is! String || value.isEmpty) return fallback;
    final normalized = value.replaceAll('#', '');
    final parsed = int.tryParse('FF$normalized', radix: 16);
    return parsed == null ? fallback : Color(parsed);
  }
}
