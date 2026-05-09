import 'dart:convert';

import 'package:fl_clash/common/preferences.dart';

import 'v2et_bridge.dart';

class V2etSessionStore {
  static const _sessionKey = 'v2et.session';

  Future<void> save(V2etSession session) async {
    final shared = await preferences.sharedPreferencesCompleter.future;
    if (shared == null) return;
    await shared.setString(_sessionKey, jsonEncode(<String, Object?>{
      'base_url': session.baseUrl.toString(),
      'email': session.email,
      'access_token': session.accessToken,
    }));
  }

  Future<V2etSession?> read() async {
    final shared = await preferences.sharedPreferencesCompleter.future;
    final raw = shared?.getString(_sessionKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final data = jsonDecode(raw);
      if (data is! Map) return null;
      final baseUrl = Uri.tryParse('${data['base_url'] ?? ''}');
      final email = '${data['email'] ?? ''}'.trim();
      final token = '${data['access_token'] ?? ''}'.trim();
      if (baseUrl == null || email.isEmpty || token.isEmpty) return null;
      return V2etSession(baseUrl: baseUrl, email: email, accessToken: token);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final shared = await preferences.sharedPreferencesCompleter.future;
    await shared?.remove(_sessionKey);
  }
}

