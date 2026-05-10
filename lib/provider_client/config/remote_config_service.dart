import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'app_config_model.dart';
import 'default_app_config.dart';

class RemoteConfigService {
  const RemoteConfigService();

  /// 第一阶段仅提供结构。后续接对象存储时，把 bundleConfigPath 换成网络 URL 拉取逻辑。
  Future<AppConfig> load({String? bundleConfigPath}) async {
    if (bundleConfigPath == null || bundleConfigPath.isEmpty) {
      return defaultAppConfig;
    }
    try {
      final raw = await rootBundle.loadString(bundleConfigPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AppConfig.fromJson(json);
    } catch (e) {
      debugPrint('RemoteConfig fallback: $e');
      return defaultAppConfig;
    }
  }
}
