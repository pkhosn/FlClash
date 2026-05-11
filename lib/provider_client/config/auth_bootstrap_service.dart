import 'package:dio/dio.dart';

class AuthBootstrapData {
  const AuthBootstrapData({
    required this.emailSuffixes,
    required this.languages,
    required this.requireEmailVerify,
    required this.requireInviteCode,
    required this.whitelistEnabled,
  });

  final List<String> emailSuffixes;
  final List<String> languages;
  final bool requireEmailVerify;
  final bool requireInviteCode;
  final bool whitelistEnabled;
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
      emailSuffixes: suffixes,
      languages: langs.isEmpty ? const ['zh-CN', 'en-US'] : langs,
      requireEmailVerify: _toBool(data['is_email_verify'] ?? data['email_verify']),
      requireInviteCode: _toBool(data['is_invite_force'] ?? data['invite_force']),
      whitelistEnabled: suffixes.isNotEmpty,
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
    final whiteListRaw = data['email_whitelist_suffix'];
    // v2board: when whitelist disabled this value is usually 0
    if (whiteListRaw == 0 || whiteListRaw == '0' || whiteListRaw == false) {
      return const <String>[];
    }
    final candidates = [
      whiteListRaw,
      data['emailSuffix'],
      data['email_suffix'],
      data['email_domain'],
      data['email_domains'],
      data['emailDomain'],
      data['emailDomainWhitelist'],
      data['email_white_list_suffix'],
    ];
    for (final raw in candidates) {
      final list = _normalizeSuffixList(raw);
      if (list.isNotEmpty) return list;
    }
    return const <String>[];
  }

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final s = '$value'.trim().toLowerCase();
    return s == '1' || s == 'true' || s == 'yes';
  }

  List<String> _normalizeSuffixList(dynamic raw) {
    List<String> list = const [];
    if (raw is List) {
      list = raw.map((e) => '$e'.trim()).toList(growable: false);
    } else if (raw is String && raw.trim().isNotEmpty) {
      list = raw
          .split(RegExp(r'[,|\s;]+'))
          .map((e) => e.trim())
          .toList(growable: false);
    } else {
      return const [];
    }
    final normalized = list
        .map((e) => e.startsWith('@') ? e.substring(1).trim() : e.trim())
        .where((e) => e.isNotEmpty && e.contains('.'))
        .toSet()
        .toList(growable: false);
    return normalized;
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
