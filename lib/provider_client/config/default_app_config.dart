import 'app_config_model.dart';

const Map<String, dynamic> defaultAppConfigJson = {
  'app': {
    'brandName': 'v2et',
    'windowTitle': 'v2et',
    'versionText': 'v1.0.0',
    'officialWebsite': '',
    'privacyUrl': '',
    'termsUrl': '',
  },
  'api': {
    'baseUrl': 'https://example.com',
    'apiPrefix': '',
    'panelType': 'v2board',
    'timeoutSeconds': 15,
  },
  'assets': {
    'logoUrl': '',
    'loginBackgroundUrl': '',
    'loginIllustrationUrl': '',
    'brandIconUrl': '',
    'useMockAuthBackground': false,
  },
  'theme': {
    'primaryColor': '#2D6CDF',
    'backgroundColor': '#F3F7FC',
    'cardColor': '#FFFFFF',
    'textPrimaryColor': '#1D2433',
    'textSecondaryColor': '#6B7280',
  },
  'features': {
    'enableRegister': true,
    'enableInviteCode': true,
    'enableStore': true,
    'enableInvite': true,
    'enableConnectionPage': false,
    'enableCrisp': true,
    'enableTicket': false,
    'enableNoticePopup': true,
    'enablePaymentInApp': true,
  },
  'customerService': {
    'type': 'crisp',
    'crispWebsiteId': '',
    'fallbackUrl': '',
  },
  'payment': {
    'mode': 'webview',
    'pollIntervalSeconds': 3,
    'pollMaxSeconds': 180,
  },
  'mock': {'enabled': true},
};

final AppConfig defaultAppConfig = AppConfig.fromJson(defaultAppConfigJson);
