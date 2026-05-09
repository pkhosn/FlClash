import 'dart:convert';

import 'package:dio/dio.dart';

class V2etRuntimeConfig {
  const V2etRuntimeConfig({
    this.apiUrl,
    this.supportProvider,
    this.supportUrl,
    this.supportScriptUrl,
    this.supportEmbedHtml,
    this.crispWebsiteId,
    this.defaultEmail = '',
    this.defaultPassword = '',
  });

  final String? apiUrl;
  final String? supportProvider;
  final String? supportUrl;
  final String? supportScriptUrl;
  final String? supportEmbedHtml;
  final String? crispWebsiteId;
  final String defaultEmail;
  final String defaultPassword;

  Uri? resolveBaseUrl() {
    final raw = (apiUrl ?? '').trim();
    if (raw.isEmpty) return null;
    return Uri.tryParse(raw);
  }

  Uri? buildSupportUri() {
    final provider = (supportProvider ?? '').trim().toLowerCase();
    final crispId = (crispWebsiteId ?? '').trim();
    if (provider.contains('crisp') && crispId.isNotEmpty) {
      return Uri.parse('https://go.crisp.chat/chat/embed/?website_id=$crispId');
    }
    final direct = _parseUri(supportUrl);
    if (direct != null) return direct;
    final script = (supportScriptUrl ?? '').trim();
    if (script.startsWith('http://') || script.startsWith('https://')) {
      return Uri.parse(script);
    }
    final html = (supportEmbedHtml ?? '').trim();
    if (html.startsWith('http://') || html.startsWith('https://')) {
      return Uri.parse(html);
    }
    if (crispId.isNotEmpty) {
      return Uri.parse('https://go.crisp.chat/chat/embed/?website_id=$crispId');
    }
    return null;
  }

  static Uri? _parseUri(String? raw) {
    final text = (raw ?? '').trim();
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    if (uri == null || !uri.hasScheme) return null;
    return uri;
  }

  factory V2etRuntimeConfig.fromJson(Map<String, dynamic> map) {
    String? read(List<String> keys) {
      for (final key in keys) {
        dynamic curr = map;
        for (final part in key.split('.')) {
          if (curr is Map && curr.containsKey(part)) {
            curr = curr[part];
          } else {
            curr = null;
            break;
          }
        }
        if (curr is String && curr.trim().isNotEmpty) return curr.trim();
      }
      return null;
    }

    return V2etRuntimeConfig(
      apiUrl: read(['api_url', 'apiUrl', 'base_url', 'baseUrl']),
      supportProvider: read(['support.provider']),
      supportUrl: read(['support.url']),
      supportScriptUrl: read(['support.script_url']),
      supportEmbedHtml: read(['support.embed_html']),
      crispWebsiteId: read(['crisp.website_id', 'support.crisp_id']),
      defaultEmail: read(['default_email']) ?? '',
      defaultPassword: read(['default_password']) ?? '',
    );
  }
}

class V2etRuntimeConfigService {
  V2etRuntimeConfigService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const defaultConfigUrl =
      String.fromEnvironment('V2ET_CONFIG_URL', defaultValue: 'https://hko-1312628321.cos.ap-guangzhou.myqcloud.com/config.json');

  Future<V2etRuntimeConfig> fetch() async {
    try {
      final response = await _dio.getUri<Object?>(
        Uri.parse(defaultConfigUrl),
        options: Options(
          headers: const {'Accept': 'application/json,text/plain,*/*'},
          responseType: ResponseType.json,
        ),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return V2etRuntimeConfig.fromJson(data);
      }
      if (data is Map) {
        return V2etRuntimeConfig.fromJson(data.map((k, v) => MapEntry(k.toString(), v)));
      }
      if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return V2etRuntimeConfig.fromJson(decoded);
        }
      }
    } catch (_) {}
    return const V2etRuntimeConfig();
  }
}
