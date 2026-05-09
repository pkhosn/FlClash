import 'package:fl_clash/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'v2et_panel_api.dart';
import 'v2et_bridge.dart';
import 'v2et_session_store.dart';

/// Stage-1 placeholder implementation.
///
/// In Stage-2 this will be bound to FlClash managers/providers
/// and V2ET panel APIs.
class FlClashV2etBridge implements V2etBridge {
  FlClashV2etBridge(this._ref, {V2etPanelApi? panelApi, V2etSessionStore? sessionStore})
    : _panelApi = panelApi ?? V2etPanelApi(),
      _sessionStore = sessionStore ?? V2etSessionStore();

  final Ref _ref;
  final V2etPanelApi _panelApi;
  final V2etSessionStore _sessionStore;

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
    return _fetchSubscription();
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
    return _login(baseUrl: baseUrl, email: email, password: password);
  }

  @override
  Future<void> logout() async {
    await _sessionStore.clear();
  }

  @override
  Future<V2etSession?> restoreSession() async => _sessionStore.read();

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

  Future<V2etSession> _login({
    required Uri baseUrl,
    required String email,
    required String password,
  }) async {
    final token = await _panelApi.login(baseUrl: baseUrl, email: email, password: password);
    final session = V2etSession(
      baseUrl: baseUrl,
      email: email.trim(),
      accessToken: token,
    );
    await _sessionStore.save(session);
    return session;
  }

  Future<V2etSubscription> _fetchSubscription() async {
    final session = await _sessionStore.read();
    if (session == null || !session.hasToken) {
      throw StateError('session not found');
    }

    final data = await _panelApi.fetchSubscription(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
    );

    final payload = data['data'] is Map ? data['data'] as Map : data;
    final subscribeUrl =
        (payload['subscribe_url'] ?? payload['subscribeUrl'] ?? payload['subscription_url'] ?? '')
            .toString()
            .trim();
    if (subscribeUrl.isEmpty) {
      throw StateError('subscription url not found');
    }
    final subUri = Uri.tryParse(subscribeUrl);
    if (subUri == null) {
      throw StateError('invalid subscription url');
    }

    final transferEnable = _toInt(payload['transfer_enable']);
    final used = _toInt(payload['u']) + _toInt(payload['d']);
    final expiredAtTs = _toInt(payload['expired_at']);
    final expiredAt = expiredAtTs > 0 ? DateTime.fromMillisecondsSinceEpoch(expiredAtTs * 1000) : null;
    return V2etSubscription(
      subscriptionUrl: subUri,
      planName: payload['plan_name']?.toString() ?? payload['plan']?.toString(),
      expiredAt: expiredAt,
      transferEnableBytes: transferEnable > 0 ? transferEnable : null,
      usedBytes: used > 0 ? used : null,
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('${value ?? ''}') ?? 0;
  }
}
