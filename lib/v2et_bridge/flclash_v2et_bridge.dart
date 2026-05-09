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
  Future<List<V2etStoreOffer>> fetchStoreOffers() => _fetchStoreOffers();

  @override
  Future<List<V2etOrder>> fetchOrders() => _fetchOrders();

  @override
  Future<Uri> startCheckout({
    required int planId,
    required String period,
    String? couponCode,
  }) =>
      _startCheckout(planId: planId, period: period, couponCode: couponCode);

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
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final session = await _sessionStore.read();
    if (session == null || !session.hasToken) {
      throw StateError('session not found');
    }
    await _panelApi.changePassword(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
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

  Future<List<V2etStoreOffer>> _fetchStoreOffers() async {
    final session = await _sessionStore.read();
    if (session == null || !session.hasToken) {
      throw StateError('session not found');
    }
    final plans = await _panelApi.fetchPlans(baseUrl: session.baseUrl, accessToken: session.accessToken);
    final offers = <V2etStoreOffer>[];
    for (final item in plans) {
      final id = _toInt(item['id']);
      if (id <= 0) continue;
      final name = '${item['name'] ?? item['title'] ?? 'Plan'}'.trim();
      final prices = <String, double>{};
      const keys = ['month', 'quarter', 'half_year', 'year', 'two_year', 'three_year', 'onetime', 'reset'];
      for (final key in keys) {
        final raw = item[key];
        if (raw == null) continue;
        final value = raw is num ? raw.toDouble() : double.tryParse('$raw');
        if (value != null && value > 0) prices[key] = value;
      }
      offers.add(V2etStoreOffer(id: id, name: name.isEmpty ? 'Plan #$id' : name, prices: prices));
    }
    return offers;
  }

  Future<Uri> _startCheckout({
    required int planId,
    required String period,
    String? couponCode,
  }) async {
    final session = await _sessionStore.read();
    if (session == null || !session.hasToken) {
      throw StateError('session not found');
    }

    final orders = await _panelApi.fetchPendingOrders(baseUrl: session.baseUrl, accessToken: session.accessToken);
    for (final order in orders) {
      final status = _toInt(order['status']);
      final tradeNo = '${order['trade_no'] ?? ''}'.trim();
      if (status == 0 && tradeNo.isNotEmpty) {
        try {
          await _panelApi.cancelOrder(
            baseUrl: session.baseUrl,
            accessToken: session.accessToken,
            tradeNo: tradeNo,
          );
        } catch (_) {}
      }
    }

    final tradeNo = await _panelApi.saveOrder(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
      planId: planId,
      period: period,
      couponCode: couponCode,
    );
    final payUrl = await _panelApi.checkoutOrder(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
      tradeNo: tradeNo,
    );
    final uri = Uri.tryParse(payUrl);
    if (uri == null || !uri.hasScheme) {
      throw StateError('invalid pay url');
    }
    return uri;
  }

  Future<List<V2etOrder>> _fetchOrders() async {
    final session = await _sessionStore.read();
    if (session == null || !session.hasToken) {
      throw StateError('session not found');
    }
    final orders = await _panelApi.fetchPendingOrders(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
    );
    return orders.map((item) {
      final tradeNo = '${item['trade_no'] ?? ''}'.trim();
      final status = _toInt(item['status']);
      final amountRaw = item['total_amount'] ?? item['totalAmount'] ?? 0;
      final totalAmount = amountRaw is num ? amountRaw.toDouble() : double.tryParse('$amountRaw') ?? 0;
      final ts = _toInt(item['created_at']);
      return V2etOrder(
        tradeNo: tradeNo,
        status: status,
        totalAmount: totalAmount,
        planName: item['plan_name']?.toString() ?? item['plan']?.toString(),
        createdAt: ts > 0 ? DateTime.fromMillisecondsSinceEpoch(ts * 1000) : null,
      );
    }).toList();
  }
}
