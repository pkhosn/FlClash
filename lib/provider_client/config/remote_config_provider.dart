import 'app_config_model.dart';
import 'default_app_config.dart';

/// 不依赖 Riverpod 的最小配置持有器，方便先塞进半成品项目。
/// 后续可以替换成 Riverpod Provider / Notifier。
class RemoteConfigStore {
  RemoteConfigStore._();
  static final RemoteConfigStore instance = RemoteConfigStore._();

  AppConfig _config = defaultAppConfig;
  AppConfig get config => _config;

  void update(AppConfig config) {
    _config = config;
  }
}
