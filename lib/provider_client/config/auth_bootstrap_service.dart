import 'package:dio/dio.dart';

class AuthBootstrapData {
  const AuthBootstrapData({
    required this.emailSuffixes,
    required this.languages,
  });

  final List<String> emailSuffixes;
  final List<String> languages;
}

class AuthBootstrapService {
  AuthBootstrapService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  Future<AuthBootstrapData> fetch(Uri baseUrl) async {
    final map = await _fetchConfigMap(baseUrl);
    final data = _extractData(map);
    final suffixes = _extractSuffixes(data);
    final langs = _extractLanguages(data);
    return AuthBootstrapData(
      emailSuffixes: suffixes.isEmpty ? const ['qq.com'] : suffixes,
      languages: langs.isEmpty ? const ['zh-CN', 'en-US'] : langs,
    );
  }

  Future<Map<String, dynamic>> _fetchConfigMap(Uri baseUrl) async {
    const paths = [
      '/api/v1/guest/comm/config',
      '/api/v1/passport/comm/config',
      '/api/v1/user/comm/config',
    ];
    for (final path in paths) {
      try {
        final response = await _dio.getUri<Map<String, dynamic>>(
          _join(baseUrl, path),
          options: Options(
            headers: const {'Accept': 'application/json,text/plain,*/*'},
            responseType: ResponseType.json,
          ),
        );
        final body = response.data;
        if (body != null && body.isNotEmpty) return body;
      } catch (_) {}
    }
    return const <String, dynamic>{};
  }

  Map _extractData(Map<String, dynamic> map) {
    final data = map['data'];
    if (data is Map) return data;
    return map;
  }

  List<String> _extractSuffixes(Map data) {
    final raw =
        data['email_whitelist_suffix'] ??
        data['emailSuffix'] ??
        data['email_suffix'];
    if (raw is List) {
      return raw
          .map((e) => '$e'.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }
    if (raw is String) {
      return raw
          .split(RegExp(r'[,|\s]+'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  List<String> _extractLanguages(Map data) {
    final candidates = [
      data['languages'],
      data['language'],
      data['langs'],
      data['i18n'],
    ];
    for (final c in candidates) {
      if (c is List) {
        final list = c
            .map((e) {
              if (e is Map) {
                return '${e['code'] ?? e['locale'] ?? e['lang'] ?? ''}'.trim();
              }
              return '$e'.trim();
            })
            .where((e) => e.isNotEmpty)
            .toList(growable: false);
        if (list.isNotEmpty) return list;
      } else if (c is String && c.trim().isNotEmpty) {
        final list = c
            .split(RegExp(r'[,|\s]+'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(growable: false);
        if (list.isNotEmpty) return list;
      }
    }
    return const [];
  }

  Uri _join(Uri base, String path) {
    final normalized = base.toString().endsWith('/')
        ? base.toString().substring(0, base.toString().length - 1)
        : base.toString();
    return Uri.parse('$normalized$path');
  }
}

