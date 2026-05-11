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
  FlClashV2etBridge(
    this._ref, {
    V2etPanelApi? panelApi,
    V2etSessionStore? sessionStore,
  }) : _panelApi = panelApi ?? V2etPanelApi(),
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
  Future<V2etUserInfo> fetchUserInfo() => _fetchUserInfo();

  @override
  Future<List<V2etStoreOffer>> fetchStoreOffers() => _fetchStoreOffers();

  @override
  Future<List<V2etOrder>> fetchOrders() => _fetchOrders();

  @override
  Future<List<V2etNotice>> fetchNotices() => _fetchNotices();

  @override
  Future<V2etInviteData> fetchInviteData() => _fetchInviteData();

  @override
  Future<String> generateInviteCode() => _generateInviteCode();

  @override
  Future<void> redeemGiftCard(String code) => _redeemGiftCard(code);

  @override
  Future<Uri> startCheckout({
    required int planId,
    required String period,
    int? method,
    String? couponCode,
  }) => _startCheckout(
    planId: planId,
    period: period,
    method: method,
    couponCode: couponCode,
  );

  @override
  Future<List<V2etPaymentMethod>> fetchPaymentMethods() =>
      _fetchPaymentMethods();

  @override
  Future<bool> checkOrderPaid(String tradeNo) => _checkOrderPaid(tradeNo);

  @override
  Future<V2etProxyMode> getProxyMode() async {
    final tunEnabled = _ref.read(
      patchClashConfigProvider.select((state) => state.tun.enable),
    );
    if (tunEnabled) return V2etProxyMode.tun;

    final mode = _ref.read(
      patchClashConfigProvider.select((state) => state.mode),
    );
    return switch (mode) {
      Mode.global => V2etProxyMode.global,
      _ => V2etProxyMode.smart,
    };
  }

  @override
  Future<V2etSession> login({
    required Uri baseUrl,
    required String email,
    required String password,
  }) {
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
  Future<void> sendEmailVerify({
    required Uri baseUrl,
    required String email,
    required bool isForgetPassword,
  }) async {
    await _panelApi.sendEmailVerify(
      baseUrl: baseUrl,
      email: email,
      isForgetPassword: isForgetPassword,
    );
  }

  @override
  Future<void> resetPassword({
    required Uri baseUrl,
    required String email,
    required String password,
    required String emailCode,
  }) async {
    await _panelApi.resetPassword(
      baseUrl: baseUrl,
      email: email,
      password: password,
      emailCode: emailCode,
    );
  }

  @override
  Future<void> register({
    required Uri baseUrl,
    required String email,
    required String password,
    required String emailCode,
    String? inviteCode,
  }) async {
    final token = await _panelApi.register(
      baseUrl: baseUrl,
      email: email,
      password: password,
      emailCode: emailCode,
      inviteCode: inviteCode,
    );
    await _sessionStore.save(
      V2etSession(baseUrl: baseUrl, email: email.trim(), accessToken: token),
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
        _ref
            .read(patchClashConfigProvider.notifier)
            .update(
              (state) => state.copyWith(
                mode: Mode.rule,
                tun: state.tun.copyWith(enable: true),
              ),
            );
        _ref
            .read(networkSettingProvider.notifier)
            .update((state) => state.copyWith(systemProxy: false));
        break;
      case V2etProxyMode.global:
        _ref
            .read(patchClashConfigProvider.notifier)
            .update(
              (state) => state.copyWith(
                mode: Mode.global,
                tun: state.tun.copyWith(enable: false),
              ),
            );
        _ref
            .read(networkSettingProvider.notifier)
            .update((state) => state.copyWith(systemProxy: true));
        break;
      case V2etProxyMode.smart:
        _ref
            .read(patchClashConfigProvider.notifier)
            .update(
              (state) => state.copyWith(
                mode: Mode.rule,
                tun: state.tun.copyWith(enable: false),
              ),
            );
        _ref
            .read(networkSettingProvider.notifier)
            .update((state) => state.copyWith(systemProxy: true));
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
    final token = await _panelApi.login(
      baseUrl: baseUrl,
      email: email,
      password: password,
    );
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
        (payload['subscribe_url'] ??
                payload['subscribeUrl'] ??
                payload['subscription_url'] ??
                '')
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
    final resetDay = _toInt(payload['reset_day']);
    final expiredAtTs = _toInt(payload['expired_at']);
    final expiredAt = expiredAtTs > 0
        ? DateTime.fromMillisecondsSinceEpoch(expiredAtTs * 1000)
        : null;
    final planName = _extractPlanName(payload);
    return V2etSubscription(
      subscriptionUrl: subUri,
      planName: planName,
      expiredAt: expiredAt,
      transferEnableBytes: transferEnable > 0 ? transferEnable : null,
      usedBytes: used > 0 ? used : null,
      resetDay: resetDay >= 0 ? resetDay : null,
    );
  }

  Future<V2etUserInfo> _fetchUserInfo() async {
    final session = await _sessionStore.read();
    if (session == null || !session.hasToken) {
      throw StateError('session not found');
    }
    final data = await _panelApi.fetchUserInfo(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
    );
    final payload = data['data'] is Map ? data['data'] as Map : data;
    final email = '${payload['email'] ?? session.email}'.trim();
    final balance = _normalizeCurrency(_toDouble(payload['balance']));
    final commissionBalance = _normalizeCurrency(
      _toDouble(payload['commission_balance']),
    );
    final planName = _extractPlanName(payload);
    return V2etUserInfo(
      email: email.isEmpty ? session.email : email,
      balance: balance,
      commissionBalance: commissionBalance,
      planName: planName,
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
    final plans = await _panelApi.fetchPlans(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
    );
    final offers = <V2etStoreOffer>[];
    for (final item in plans) {
      final id = _toInt(item['id']);
      if (id <= 0) continue;
      final name = '${item['name'] ?? item['title'] ?? 'Plan'}'.trim();
      final prices = <String, double>{};
      const keys = [
        'month_price',
        'quarter_price',
        'half_year_price',
        'year_price',
        'two_year_price',
        'three_year_price',
        'onetime_price',
        'reset_price',
      ];
      for (final key in keys) {
        final raw = item[key];
        if (raw == null) continue;
        final parsed = raw is num ? raw.toDouble() : double.tryParse('$raw');
        if (parsed != null && parsed > 0) {
          prices[_periodViewKey(key)] = _normalizeCurrency(parsed);
        }
      }
      final transferEnableBytes = _toInt(item['transfer_enable']);
      final deviceLimit = _toInt(item['device_limit']);
      final speedLimitMbps = _toInt(item['speed_limit']);
      final content = '${item['content'] ?? ''}'.trim();
      final show = _toInt(item['show']) == 1;
      final renew = _toInt(item['renew']) == 1;
      offers.add(
        V2etStoreOffer(
          id: id,
          name: name.isEmpty ? 'Plan #$id' : name,
          prices: prices,
          transferEnableBytes: transferEnableBytes > 0
              ? transferEnableBytes
              : 0,
          deviceLimit: deviceLimit > 0 ? deviceLimit : 0,
          speedLimitMbps: speedLimitMbps > 0 ? speedLimitMbps : 0,
          content: content,
          show: show,
          renew: renew,
        ),
      );
    }
    return offers;
  }

  Future<Uri> _startCheckout({
    required int planId,
    required String period,
    int? method,
    String? couponCode,
  }) async {
    final session = await _sessionStore.read();
    if (session == null || !session.hasToken) {
      throw StateError('session not found');
    }

    final orders = await _panelApi.fetchPendingOrders(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
    );
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
      period: _periodApiKey(period),
      couponCode: couponCode,
    );
    final payUrl = await _panelApi.checkoutOrder(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
      tradeNo: tradeNo,
      method: method ?? 1,
    );
    final uri = Uri.tryParse(payUrl);
    if (uri == null || !uri.hasScheme) {
      throw StateError('invalid pay url');
    }
    return uri;
  }

  Future<List<V2etPaymentMethod>> _fetchPaymentMethods() async {
    final session = await _sessionStore.read();
    if (session == null || !session.hasToken) {
      throw StateError('session not found');
    }
    final data = await _panelApi.fetchPaymentMethods(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
    );
    final methods = <V2etPaymentMethod>[];
    for (final item in data) {
      final id = _toInt(item['id']);
      if (id <= 0) continue;
      final name =
          '${item['name'] ?? item['payment'] ?? item['method_name'] ?? '支付方式'}'
              .trim();
      methods.add(V2etPaymentMethod(id: id, name: name));
    }
    return methods;
  }

  Future<bool> _checkOrderPaid(String tradeNo) async {
    final session = await _sessionStore.read();
    if (session == null || !session.hasToken) {
      throw StateError('session not found');
    }
    final status = await _panelApi.checkOrderPaid(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
      tradeNo: tradeNo,
    );
    return status == 1 || status == 3 || status == 4;
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
      final totalAmount = amountRaw is num
          ? amountRaw.toDouble()
          : double.tryParse('$amountRaw') ?? 0;
      final ts = _toInt(item['created_at']);
      final planName = _extractPlanName(item);
      return V2etOrder(
        tradeNo: tradeNo,
        status: status,
        totalAmount: totalAmount,
        planName: planName,
        createdAt: ts > 0
            ? DateTime.fromMillisecondsSinceEpoch(ts * 1000)
            : null,
      );
    }).toList();
  }

  String? _extractPlanName(Map payload) {
    final fromPlanName = _cleanPlanName(payload['plan_name']);
    if (fromPlanName != null) return fromPlanName;
    final plan = payload['plan'];
    if (plan is Map) {
      final fromMapName = _cleanPlanName(plan['name']);
      if (fromMapName != null) return fromMapName;
      final fromMapTitle = _cleanPlanName(plan['title']);
      if (fromMapTitle != null) return fromMapTitle;
    }
    return _cleanPlanName(plan);
  }

  String? _cleanPlanName(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    if (text.startsWith('{') || text.startsWith('[')) return null;
    if (text.contains('month_price') ||
        text.contains('quarter_price') ||
        text.contains('half_year_price') ||
        text.contains('year_price') ||
        text.contains('onetime_price') ||
        text.contains('support') ||
        text.contains('feature')) {
      return null;
    }
    return text;
  }

  Future<List<V2etNotice>> _fetchNotices() async {
    final session = await _sessionStore.read();
    if (session == null || !session.hasToken) {
      throw StateError('session not found');
    }
    final notices = await _panelApi.fetchNotices(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
    );
    return notices.map((item) {
      final id = _toInt(item['id']);
      final title = '${item['title'] ?? '公告'}'.trim();
      final content = '${item['content'] ?? item['body'] ?? ''}'.trim();
      final ts = _toInt(item['created_at']);
      return V2etNotice(
        id: id,
        title: title.isEmpty ? '公告' : title,
        content: content,
        createdAt: ts > 0
            ? DateTime.fromMillisecondsSinceEpoch(ts * 1000)
            : null,
      );
    }).toList();
  }

  Future<V2etInviteData> _fetchInviteData() async {
    final session = await _sessionStore.read();
    if (session == null || !session.hasToken) {
      throw StateError('session not found');
    }
    final raw = await _panelApi.fetchInviteData(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
    );
    final data = raw['data'] is Map ? raw['data'] as Map : raw;
    final rawCodes = data['codes'];
    final rawStat = data['stat'];
    final codes = <String>[];
    if (rawCodes is List) {
      for (final item in rawCodes) {
        if (item is Map) {
          final code = '${item['code'] ?? item['invite_code'] ?? ''}'.trim();
          if (code.isNotEmpty) codes.add(code);
        } else {
          final code = '$item'.trim();
          if (code.isNotEmpty) codes.add(code);
        }
      }
    }
    final stat = rawStat is List ? rawStat : const <dynamic>[];
    final inviteCount = stat.isNotEmpty ? _toInt(stat[0]) : 0;
    final totalCommission = stat.length > 1
        ? _normalizeCurrency(_toDouble(stat[1]))
        : 0.0;
    final commissionRate = stat.length > 3 ? _toDouble(stat[3]) : 0.0;
    return V2etInviteData(
      codes: codes,
      commissionRate: commissionRate,
      inviteCount: inviteCount,
      totalCommission: totalCommission,
    );
  }

  Future<String> _generateInviteCode() async {
    final session = await _sessionStore.read();
    if (session == null || !session.hasToken) {
      throw StateError('session not found');
    }
    return _panelApi.generateInviteCode(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
    );
  }

  Future<void> _redeemGiftCard(String code) async {
    final session = await _sessionStore.read();
    if (session == null || !session.hasToken) {
      throw StateError('session not found');
    }
    final text = code.trim();
    if (text.isEmpty) {
      throw StateError('gift card code is empty');
    }
    await _panelApi.redeemGiftCard(
      baseUrl: session.baseUrl,
      accessToken: session.accessToken,
      code: text,
    );
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? ''}') ?? 0;
  }

  double _normalizeCurrency(double amount) {
    // v2board deploys may return cents or yuan.
    // Heuristic: >= 1000 usually means cents (e.g. 3000 => ¥30.00).
    if (amount >= 1000) return amount / 100.0;
    return amount;
  }

  String _periodViewKey(String raw) {
    switch (raw) {
      case 'month_price':
        return 'month';
      case 'quarter_price':
        return 'quarter';
      case 'half_year_price':
        return 'half_year';
      case 'year_price':
        return 'year';
      case 'two_year_price':
        return 'two_year';
      case 'three_year_price':
        return 'three_year';
      case 'onetime_price':
        return 'onetime';
      case 'reset_price':
        return 'reset';
      default:
        return raw;
    }
  }

  String _periodApiKey(String period) {
    switch (period) {
      case 'month':
        return 'month_price';
      case 'quarter':
        return 'quarter_price';
      case 'half_year':
        return 'half_year_price';
      case 'year':
        return 'year_price';
      case 'two_year':
        return 'two_year_price';
      case 'three_year':
        return 'three_year_price';
      case 'onetime':
        return 'onetime_price';
      case 'reset':
        return 'reset_price';
      default:
        return period;
    }
  }
}
