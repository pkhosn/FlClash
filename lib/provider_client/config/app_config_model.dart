class AppConfig {
  final String apiUrl;
  final List<String> apiUrls;
  final String brandName;
  final String versionText;
  final String logoUrl;
  final String authBackgroundUrl;
  final String crispWebsiteId;
  final bool showNoticePopup;

  AppConfig({
    required this.apiUrl,
    required this.apiUrls,
    required this.brandName,
    required this.versionText,
    required this.logoUrl,
    required this.authBackgroundUrl,
    required this.crispWebsiteId,
    required this.showNoticePopup,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final primaryApi = (json['api_url'] ?? '').toString().trim();
    final apiUrls = _parseApiUrls(json, primaryApi);
    return AppConfig(
      apiUrl: primaryApi,
      apiUrls: apiUrls,
      brandName: (json['brand_name'] ?? 'v2et').toString(),
      versionText: (json['version_text'] ?? json['app']?['versionText'] ?? '')
          .toString(),
      logoUrl: (json['assets']?['logo'] ?? '').toString(),
      authBackgroundUrl: (json['assets']?['auth_background'] ?? '').toString(),
      crispWebsiteId: (json['crisp']?['website_id'] ?? '').toString(),
      showNoticePopup: json['features']?['show_notice_popup'] != false,
    );
  }

  factory AppConfig.defaultConfig() => AppConfig(
    apiUrl: 'https://v2et-board.xizdj.com',
    apiUrls: const ['https://v2et-board.xizdj.com'],
    brandName: 'v2et',
    versionText: '',
    logoUrl: '',
    authBackgroundUrl: '',
    crispWebsiteId: '',
    showNoticePopup: true,
  );

  static List<String> _parseApiUrls(
    Map<String, dynamic> json,
    String primaryApi,
  ) {
    final urls = <String>{};
    if (primaryApi.isNotEmpty) urls.add(primaryApi);
    final raw = json['api_urls'] ?? json['apiUrlList'] ?? json['apis'];
    if (raw is List) {
      for (final item in raw) {
        final text = '$item'.trim();
        if (text.isNotEmpty) urls.add(text);
      }
    } else if (raw is String && raw.trim().isNotEmpty) {
      for (final item in raw.split(RegExp(r'[,|\s]+'))) {
        final text = item.trim();
        if (text.isNotEmpty) urls.add(text);
      }
    }
    return urls.isEmpty ? <String>[primaryApi] : urls.toList(growable: false);
  }
}
