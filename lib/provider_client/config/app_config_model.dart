class AppConfig {
  final String apiUrl;
  final String brandName;
  final String logoUrl;
  final String authBackgroundUrl;
  final String crispWebsiteId;
  final bool showNoticePopup;

  AppConfig({
    required this.apiUrl,
    required this.brandName,
    required this.logoUrl,
    required this.authBackgroundUrl,
    required this.crispWebsiteId,
    required this.showNoticePopup,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      apiUrl: (json['api_url'] ?? '').toString(),
      brandName: (json['brand_name'] ?? 'v2et').toString(),
      logoUrl: (json['assets']?['logo'] ?? '').toString(),
      authBackgroundUrl: (json['assets']?['auth_background'] ?? '').toString(),
      crispWebsiteId: (json['crisp']?['website_id'] ?? '').toString(),
      showNoticePopup: json['features']?['show_notice_popup'] != false,
    );
  }

  factory AppConfig.defaultConfig() => AppConfig(
    apiUrl: 'https://v2et-board.xizdj.com',
    brandName: 'v2et',
    logoUrl: '',
    authBackgroundUrl: '',
    crispWebsiteId: '',
    showNoticePopup: true,
  );
}
