import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_config_model.dart';
import 'remote_config_service.dart';

final appConfigProvider = NotifierProvider<AppConfigNotifier, AppConfig>(() {
  return AppConfigNotifier();
});

class AppConfigNotifier extends Notifier<AppConfig> {
  @override
  AppConfig build() => AppConfig.defaultConfig();

  Future<void> loadConfig() async {
    final config = await RemoteConfigService.fetchConfig();
    state = config;
  }
}
