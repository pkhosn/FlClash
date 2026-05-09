import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'v2et_bridge.dart';

/// Stage-1 placeholder implementation.
///
/// In Stage-2 this will be bound to FlClash managers/providers
/// and V2ET panel APIs.
class FlClashV2etBridge implements V2etBridge {
  FlClashV2etBridge(this._ref);

  final Ref _ref;

  @override
  Future<void> connect() async {
    _requireAppControllerAttached();
    await appController.updateStatus(true);
  }

  @override
  Future<void> disconnect() async {
    _requireAppControllerAttached();
    await appController.updateStatus(false);
  }

  @override
  Future<V2etSubscription> fetchSubscription() {
    throw UnimplementedError('Stage-2: bind V2ET subscription to FlClash backend');
  }

  @override
  Future<V2etProxyMode> getProxyMode() async {
    final tunEnabled = _ref.read(
      patchClashConfigProvider.select((state) => state.tun.enable),
    );
    if (tunEnabled) return V2etProxyMode.tun;

    final mode = _ref.read(patchClashConfigProvider.select((state) => state.mode));
    return switch (mode) {
      Mode.global => V2etProxyMode.global,
      _ => V2etProxyMode.smart,
    };
  }

  @override
  Future<V2etSession> login({required Uri baseUrl, required String email, required String password}) {
    throw UnimplementedError('Stage-2: bind V2ET login to FlClash backend');
  }

  @override
  Future<void> logout() async {}

  @override
  Future<V2etSession?> restoreSession() async => null;

  @override
  Future<void> setProxyMode(V2etProxyMode mode) async {
    switch (mode) {
      case V2etProxyMode.tun:
        _ref.read(patchClashConfigProvider.notifier).update(
          (state) => state.copyWith(
            mode: Mode.rule,
            tun: state.tun.copyWith(enable: true),
          ),
        );
        _ref.read(networkSettingProvider.notifier).update((state) => state.copyWith(systemProxy: false));
        break;
      case V2etProxyMode.global:
        _ref.read(patchClashConfigProvider.notifier).update(
          (state) => state.copyWith(
            mode: Mode.global,
            tun: state.tun.copyWith(enable: false),
          ),
        );
        _ref.read(networkSettingProvider.notifier).update((state) => state.copyWith(systemProxy: true));
        break;
      case V2etProxyMode.smart:
        _ref.read(patchClashConfigProvider.notifier).update(
          (state) => state.copyWith(
            mode: Mode.rule,
            tun: state.tun.copyWith(enable: false),
          ),
        );
        _ref.read(networkSettingProvider.notifier).update((state) => state.copyWith(systemProxy: true));
        break;
    }

    if (appController.isAttach) {
      appController.addCheckIp();
      appController.applyProfileDebounce(force: true, silence: true);
    }
  }

  void _requireAppControllerAttached() {
    if (!appController.isAttach) {
      throw StateError('FlClash app controller is not ready');
    }
  }
}
