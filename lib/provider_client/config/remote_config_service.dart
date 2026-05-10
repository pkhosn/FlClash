import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'app_config_model.dart';

class RemoteConfigService {
  static const String configUrl =
      'https://hko-1312628321.cos.ap-guangzhou.myqcloud.com/config.json';

  static Future<AppConfig> fetchConfig() async {
    try {
      final response = await http.get(Uri.parse(configUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap =
            json.decode(response.body) as Map<String, dynamic>;
        return AppConfig.fromJson(jsonMap);
      }
      debugPrint('Failed to load remote config: ${response.statusCode}');
      return AppConfig.defaultConfig();
    } catch (e) {
      debugPrint('Error fetching remote config: $e');
      return AppConfig.defaultConfig();
    }
  }
}
