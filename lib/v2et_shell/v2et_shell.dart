import 'dart:math' as math;

import 'package:fl_clash/v2et_bridge/v2et_bridge_export.dart';
import 'package:fl_clash/v2et_shell/v2et_runtime_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

const _kPrimary = Color(0xFF0665D0);
const _kAppBg = Colors.white;
const _kSidebarBg = Colors.white;
const _kFallbackApiUrl = 'http://v2et-board.xizdj.com';

class V2etShellPage extends ConsumerStatefulWidget {
  const V2etShellPage({super.key});

  @override
  ConsumerState<V2etShellPage> createState() => _V2etShellPageState();
}

class _V2etShellPageState extends ConsumerState<V2etShellPage> {
  V2etSession? _session;
  V2etRuntimeConfig _runtime = const V2etRuntimeConfig();
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _runtime = await V2etRuntimeConfigService().fetch();
      _session = await ref.read(v2etBridgeProvider).restoreSession();
    } catch (e) {
      _error = '$e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_session == null) {
      return _AuthShell(
        runtime: _runtime,
        error: _error,
        onLogin: (s) => setState(() {
          _session = s;
          _error = null;
        }),
      );
    }
    return _MainShell(
      runtime: _runtime,
      session: _session!,
      onLogout: () async {
        await ref.read(v2etBridgeProvider).logout();
        if (!mounted) return;
        setState(() => _session = null);
      },
    );
  }
}

enum _AuthTab { login, register, forgot }

class _AuthShell extends ConsumerStatefulWidget {
  const _AuthShell({required this.runtime, required this.onLogin, this.error});

  final V2etRuntimeConfig runtime;
  final String? error;
  final ValueChanged<V2etSession> onLogin;

  @override
  ConsumerState<_AuthShell> createState() => _AuthShellState();
}

class _AuthShellState extends ConsumerState<_AuthShell> {
  _AuthTab _tab = _AuthTab.login;
  final _email = TextEditingController();
  final _password = TextEditingController();
  Uri? _runtimeBaseUri;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runtimeBaseUri =
        widget.runtime.resolveBaseUrl() ?? Uri.tryParse(_kFallbackApiUrl);
    _email.text = widget.runtime.defaultEmail;
    _password.text = widget.runtime.defaultPassword;
    _error = widget.error;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (_loading) return;
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      setState(() => _error = '请完整填写登录信息');
      return;
    }
    final baseUri = _runtimeBaseUri;
    if (baseUri == null || !baseUri.hasScheme) {
      setState(() => _error = '配置错误：未找到可用 API 地址');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final session = await ref
          .read(v2etBridgeProvider)
          .login(
            baseUrl: baseUri,
            email: _email.text.trim(),
            password: _password.text,
          );
      if (!mounted) return;
      widget.onLogin(session);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final support = widget.runtime.buildSupportUri();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: Colors.white)),
          Center(
            child: Container(
              width: 460,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFF),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE0E8F2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _themeLangBar(),
                  const SizedBox(height: 20),
                  Icon(
                    _tab == _AuthTab.login
                        ? Icons.shield_rounded
                        : (_tab == _AuthTab.register
                              ? Icons.person_add_alt_1_rounded
                              : Icons.lock_reset_rounded),
                    size: 42,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _tab == _AuthTab.login
                        ? '登录您的账户'
                        : (_tab == _AuthTab.register ? '创建账户' : '重置密码'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 38 / 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_tab == _AuthTab.login) ...[
                    _input(_email, '邮箱', Icons.mail_outline_rounded),
                    const SizedBox(height: 10),
                    _input(
                      _password,
                      '密码',
                      Icons.lock_outline_rounded,
                      obscure: true,
                    ),
                    const SizedBox(height: 14),
                    _solidBtn(
                      _loading ? '登录中...' : '登录',
                      _loading ? null : _submitLogin,
                    ),
                    const SizedBox(height: 10),
                    _switchRow(
                      '没有账户? 立即注册',
                      () => setState(() => _tab = _AuthTab.register),
                      '忘记密码',
                      () => setState(() => _tab = _AuthTab.forgot),
                    ),
                  ] else if (_tab == _AuthTab.register) ...[
                    _input(_email, '邮箱用户名前缀', Icons.person_outline_rounded),
                    const SizedBox(height: 10),
                    _input(
                      _password,
                      '请输入密码',
                      Icons.lock_outline_rounded,
                      obscure: true,
                    ),
                    const SizedBox(height: 10),
                    _solidBtn('注册（待接入后端）', () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('当前后端未接入注册接口')),
                      );
                    }),
                    const SizedBox(height: 10),
                    _switchRow(
                      '已有账户? 立即登录',
                      () => setState(() => _tab = _AuthTab.login),
                      null,
                      null,
                    ),
                  ] else ...[
                    _input(_email, '请输入邮箱地址', Icons.mail_outline_rounded),
                    const SizedBox(height: 10),
                    _solidBtn('发送验证码（待接入后端）', () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('当前后端未接入忘记密码接口')),
                      );
                    }),
                    const SizedBox(height: 10),
                    _switchRow(
                      '记起密码了？ 返回登录',
                      () => setState(() => _tab = _AuthTab.login),
                      null,
                      null,
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (support != null)
            Positioned(
              right: 26,
              bottom: 22,
              child: _supportFab(
                () => launchUrl(support, mode: LaunchMode.externalApplication),
              ),
            ),
        ],
      ),
    );
  }

  Widget _themeLangBar() => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      _iconBox(Icons.light_mode_rounded),
      const SizedBox(width: 8),
      const _MiniBox(text: '中'),
    ],
  );

  Widget _iconBox(IconData icon) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: const Color(0xFFDDE4EF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: const Color(0xFF4B525E)),
  );

  Widget _switchRow(
    String left,
    VoidCallback leftTap,
    String? right,
    VoidCallback? rightTap,
  ) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      InkWell(
        onTap: leftTap,
        child: Text(
          left,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF1A4FA6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      if (right != null)
        InkWell(
          onTap: rightTap,
          child: Text(
            right,
            style: const TextStyle(fontSize: 13, color: Color(0xFF2D3540)),
          ),
        ),
    ],
  );

  Widget _input(
    TextEditingController c,
    String hint,
    IconData icon, {
    bool obscure = false,
  }) => TextField(
    controller: c,
    obscureText: obscure,
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );

  Widget _solidBtn(String text, VoidCallback? onTap) => SizedBox(
    width: double.infinity,
    height: 42,
    child: FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF1D4EA8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
    ),
  );
}

enum _MainTab { dashboard, store, invite, status, me, settings }

class _MainShell extends ConsumerStatefulWidget {
  const _MainShell({
    required this.runtime,
    required this.session,
    required this.onLogout,
  });
  final V2etRuntimeConfig runtime;
  final V2etSession session;
  final Future<void> Function() onLogout;

  @override
  ConsumerState<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<_MainShell> {
  _MainTab _tab = _MainTab.dashboard;
  V2etProxyMode _mode = V2etProxyMode.smart;
  V2etSubscription? _subscription;
  List<V2etStoreOffer> _offers = const [];
  List<V2etOrder> _orders = const [];
  bool _busy = false;
  bool _connected = false;
  bool _showSupport = false;
  bool _showNodePicker = false;
  int _activeGroupIndex = 0;
  String _activeNodeName = '自动选择';
  String? _loadError;
  bool _loadingData = false;
  final GlobalKey _supportKey = GlobalKey();
  final List<_NodeGroup> _nodeGroups = const [
    _NodeGroup('主策略', '自动选择', [
      _NodeItem('节点tu', 990),
      _NodeItem('新加坡A', -1),
      _NodeItem('新加坡B', 1771),
      _NodeItem('德国', 667),
      _NodeItem('老古董', 237),
    ]),
    _NodeGroup('自动选择', '应急2号线', [
      _NodeItem('特殊v4-v6网络A', 501),
      _NodeItem('特殊v4-v6网络B', 493),
      _NodeItem('特殊v4-v6网络C', -1),
      _NodeItem('土耳其', -1),
    ]),
    _NodeGroup('故障转移', '平时别用', [
      _NodeItem('土耳其-国内使用', -1),
      _NodeItem('香港3-转发', 148),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _loadingData = true;
      _loadError = null;
    });
    try {
      await _syncMode();
      await _loadSubscription();
      await _loadOffers();
      await _loadOrders();
    } catch (e) {
      _loadError = '$e';
    } finally {
      if (mounted) setState(() => _loadingData = false);
    }
  }

  Future<void> _syncMode() async {
    _mode = await ref.read(v2etBridgeProvider).getProxyMode();
    if (mounted) setState(() {});
  }

  Future<void> _loadSubscription() async {
    try {
      _subscription = await ref.read(v2etBridgeProvider).fetchSubscription();
      if (mounted) setState(() {});
    } catch (e) {
      _loadError = '$e';
    }
  }

  Future<void> _loadOffers() async {
    try {
      _offers = await ref.read(v2etBridgeProvider).fetchStoreOffers();
      if (mounted) setState(() {});
    } catch (e) {
      _loadError = '$e';
    }
  }

  Future<void> _loadOrders() async {
    try {
      _orders = await ref.read(v2etBridgeProvider).fetchOrders();
      if (mounted) setState(() {});
    } catch (e) {
      _loadError = '$e';
    }
  }

  Future<void> _connectToggle() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (_connected) {
        await ref.read(v2etBridgeProvider).disconnect();
        _connected = false;
      } else {
        await ref.read(v2etBridgeProvider).connect();
        _connected = true;
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setMode(V2etProxyMode m) async {
    setState(() => _busy = true);
    try {
      await ref.read(v2etBridgeProvider).setProxyMode(m);
      _mode = m;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _buy(V2etStoreOffer offer) async {
    try {
      final period = offer.prices.keys.isNotEmpty
          ? offer.prices.keys.first
          : 'month';
      final payUri = await ref
          .read(v2etBridgeProvider)
          .startCheckout(planId: offer.id, period: period);
      await launchUrl(payUri, mode: LaunchMode.externalApplication);
      await _loadSubscription();
      await _loadOrders();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('打开支付失败: $e')));
    }
  }

  Future<void> _changePassword(String oldPwd, String newPwd) async {
    await ref
        .read(v2etBridgeProvider)
        .changePassword(oldPassword: oldPwd, newPassword: newPwd);
  }

  String _formatBytes(int? value) {
    if (value == null || value <= 0) return '-';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double size = value.toDouble();
    var idx = 0;
    while (size >= 1024 && idx < units.length - 1) {
      size /= 1024;
      idx++;
    }
    return '${size.toStringAsFixed(idx == 0 ? 0 : 2)} ${units[idx]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kAppBg,
      body: Stack(
        children: [
          Row(
            children: [
              _sidebar(),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      '狮子云',
                      style: TextStyle(
                        fontSize: 28 / 1.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 14, 14),
                        child: Column(
                          children: [
                            if (_loadError != null)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF2F2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFFFD1D1),
                                  ),
                                ),
                                child: Text(
                                  _loadError!,
                                  style: const TextStyle(
                                    color: Color(0xFFB91C1C),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            if (_loadingData)
                              const LinearProgressIndicator(minHeight: 2),
                            Expanded(child: _body()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 52,
            bottom: 242,
            child: Container(
              key: _supportKey,
              child: IconButton(
                onPressed: () => setState(() => _showSupport = !_showSupport),
                icon: const Icon(Icons.support_agent_rounded),
              ),
            ),
          ),
          if (_showSupport) _supportPopup(),
          if (_showNodePicker) _nodePickerPopup(),
        ],
      ),
    );
  }

  Widget _sidebar() {
    Widget item(_MainTab t, IconData icon, String label) {
      final selected = _tab == t;
      return InkWell(
        onTap: () => setState(() => _tab = t),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE7EFFA) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              if (selected) Container(width: 3, height: 18, color: _kPrimary),
              if (selected) const SizedBox(width: 8),
              Icon(
                icon,
                color: selected ? _kPrimary : const Color(0xFF7C7C7C),
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: selected
                      ? const Color(0xFF111827)
                      : const Color(0xFF4B5563),
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: 170,
      color: _kSidebarBg,
      child: Column(
        children: [
          const SizedBox(height: 30),
          item(_MainTab.dashboard, Icons.dashboard_rounded, '首页面板'),
          item(_MainTab.store, Icons.shopping_cart_rounded, '购买套餐'),
          item(_MainTab.invite, Icons.card_giftcard_rounded, '邀请推广'),
          item(_MainTab.status, Icons.compare_arrows_rounded, '连接状态'),
          const Spacer(),
          item(_MainTab.me, Icons.person_rounded, '个人中心'),
          item(_MainTab.settings, Icons.settings_rounded, '设置'),
          InkWell(
            onTap: () async => widget.onLogout(),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Icon(Icons.logout_rounded, color: Color(0xFF7C7C7C)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    switch (_tab) {
      case _MainTab.dashboard:
        return _dashboardPage();
      case _MainTab.store:
        return _storePage();
      case _MainTab.invite:
        return _invitePage();
      case _MainTab.status:
        return _statusPage();
      case _MainTab.me:
        return _mePage();
      case _MainTab.settings:
        return _settingsPage();
    }
  }

  Widget _dashboardPage() {
    final total = (_subscription?.transferEnableBytes ?? 0).toDouble();
    final used = (_subscription?.usedBytes ?? 0).toDouble();
    final p = total <= 0 ? 0.0 : (used / total).clamp(0, 1).toDouble();
    return ListView(
      children: [
        _card(
          child: Column(
            children: [
              Row(
                children: [
                  _metric('剩余流量', _formatBytes((total - used).toInt())),
                  const SizedBox(width: 24),
                  _metric(
                    '有效期',
                    _subscription?.expiredAt == null
                        ? '-'
                        : '${_subscription!.expiredAt!.difference(DateTime.now()).inDays} 天',
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _init,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: p,
                minHeight: 12,
                borderRadius: BorderRadius.circular(6),
                color: _kPrimary,
                backgroundColor: const Color(0xFFDCDCDC),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: _busy ? null : _connectToggle,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFFE4E9F0),
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 16,
                    color: Color(0x26000000),
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.power_settings_new_rounded,
                size: 86,
                color: _connected ? Colors.green : const Color(0xFF8A8A8A),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(child: Chip(label: Text(_connected ? '已连接' : '未连接'))),
        const SizedBox(height: 22),
        _card(
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.tune_rounded, size: 18),
                  SizedBox(width: 8),
                  Text(
                    '代理模式',
                    style: TextStyle(
                      fontSize: 20 / 1.6,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Spacer(),
                  Text('根据规则自动选择直连或代理'),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _modeBtn(
                    '规则',
                    _mode == V2etProxyMode.smart,
                    () => _setMode(V2etProxyMode.smart),
                  ),
                  const SizedBox(width: 10),
                  _modeBtn(
                    '全局',
                    _mode == V2etProxyMode.global,
                    () => _setMode(V2etProxyMode.global),
                  ),
                  const SizedBox(width: 10),
                  _modeBtn(
                    'TUN',
                    _mode == V2etProxyMode.tun,
                    () => _setMode(V2etProxyMode.tun),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: () => setState(() => _showNodePicker = true),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDDE2EA)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F1FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.public_rounded, color: _kPrimary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _activeNodeName,
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Text(
                  '103ms',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.expand_less_rounded, color: Color(0xFF6B7280)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _nodePickerPopup() {
    final group = _nodeGroups[_activeGroupIndex];
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showNodePicker = false),
        child: Container(
          color: const Color(0x66000000),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 740,
              height: 540,
              decoration: BoxDecoration(
                color: const Color(0xFFFBFEFF),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF9EDBD8)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 270,
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: Color(0xFFE5EAF0)),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '分流组',
                              style: TextStyle(
                                fontSize: 30 / 1.6,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () =>
                                  setState(() => _showNodePicker = false),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(_nodeGroups.length, (i) {
                          final g = _nodeGroups[i];
                          final sel = i == _activeGroupIndex;
                          return InkWell(
                            onTap: () => setState(() => _activeGroupIndex = i),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: sel
                                    ? const Color(0xFFD9F1EF)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: sel
                                      ? const Color(0xFF85D3CF)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.route_rounded,
                                    size: 18,
                                    color: Color(0xFF0E8E87),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          g.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                        Text(
                                          g.desc,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                '狮子云shizi.pro',
                                style: TextStyle(
                                  fontSize: 32 / 1.6,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const Spacer(),
                              FilledButton.tonal(
                                onPressed: () {},
                                child: const Text('全部测速'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.separated(
                              itemBuilder: (_, i) {
                                final n = group.nodes[i];
                                final timeout = n.delay < 0;
                                return Row(
                                  children: [
                                    const Icon(
                                      Icons.public_rounded,
                                      color: Color(0xFF35A6E0),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _activeNodeName = n.name;
                                            _showNodePicker = false;
                                          });
                                        },
                                        child: Text(
                                          n.name,
                                          style: const TextStyle(
                                            color: Color(0xFF111827),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      timeout ? '超时' : '${n.delay}ms',
                                      style: TextStyle(
                                        color: timeout
                                            ? Colors.red
                                            : (n.delay > 500
                                                  ? Colors.red
                                                  : (n.delay > 250
                                                        ? Colors.orange
                                                        : Colors.green)),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                );
                              },
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 18),
                              itemCount: group.nodes.length,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _metric(String label, String value) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF787878), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22 / 1.6,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  Widget _modeBtn(String text, bool selected, VoidCallback onTap) => Expanded(
    child: InkWell(
      onTap: _busy ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD2D7DE)),
          color: selected ? const Color(0xFFCAE5E1) : Colors.white,
        ),
        child: Text(
          selected ? '✓ $text' : text,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    ),
  );

  Widget _storePage() {
    return ListView(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _offers.map((e) {
            final price = e.prices.values.isNotEmpty
                ? e.prices.values.first
                : 0;
            return SizedBox(
              width: 420,
              child: _card(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.name,
                            style: const TextStyle(
                              fontSize: 36 / 1.6,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '¥${price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 56 / 1.6,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: FilledButton(
                              onPressed: () => _buy(e),
                              style: FilledButton.styleFrom(
                                backgroundColor: _kPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('立即订阅'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 1, color: const Color(0xFFE5E5E5)),
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        '支持Win、Mac、iOS、安卓\n高速访问，全球节点分布',
                        style: TextStyle(color: Color(0xFF374151), height: 1.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _invitePage() {
    return ListView(
      children: [
        _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '邀请链接',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 38 / 1.6,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F1FD),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF8CB8F2)),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'L6C9jvcG',
                        style: TextStyle(
                          fontSize: 42 / 1.6,
                          fontWeight: FontWeight.w800,
                          color: _kPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.copy_rounded, color: _kPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _card(
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem('总邀请数', '0'),
              _StatItem('佣金比例', '10.0%'),
              _StatItem('累计佣金', '¥0.00'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusPage() {
    final rows = _nodeGroups.expand((e) => e.nodes).take(10).toList();
    return ListView(
      children: [
        _card(
          child: Column(
            children: List.generate(math.max(rows.length, 1), (i) {
              if (rows.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '暂无连接记录',
                      style: TextStyle(color: Color(0xFF7A7A7A)),
                    ),
                  ),
                );
              }
              final n = rows[i];
              final timeout = n.delay < 0;
              return Container(
                margin: EdgeInsets.only(bottom: i == rows.length - 1 ? 0 : 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E6EE)),
                ),
                child: Row(
                  children: [
                    const Chip(label: Text('TCP')),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        n.name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      timeout ? '超时' : '${n.delay}ms',
                      style: TextStyle(
                        color: timeout
                            ? Colors.red
                            : (n.delay > 500
                                  ? Colors.red
                                  : (n.delay > 250
                                        ? Colors.orange
                                        : Colors.green)),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _mePage() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF3F7EE0), Color(0xFF5AA1F4)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              const CircleAvatar(radius: 26, child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.session.email,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34 / 1.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ChangePasswordPanel(onSubmit: _changePassword),
      ],
    ),
  );

  Widget _settingsPage() => ListView(
    children: [
      _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '代理设置',
              style: TextStyle(fontSize: 34 / 1.6, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const _SettingRow(
              title: '混合端口',
              subtitle: 'HTTP & SOCKS5 共用端口',
              trailing: Text(
                '7890',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const Divider(height: 20),
            const _SettingRow(
              title: '允许局域网',
              subtitle: '允许其他设备连接',
              trailing: Switch(value: false, onChanged: null),
            ),
            const Divider(height: 20),
            _SettingRow(
              title: '客服系统',
              subtitle: '原位弹出客服窗口',
              trailing: Switch(
                value: _showSupport,
                onChanged: (v) => setState(() => _showSupport = v),
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _card({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: const Color(0xFFF7F9FC),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFDDE2EA)),
    ),
    child: child,
  );

  Widget _supportPopup() {
    final box = _supportKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    final p = (box != null && overlay != null)
        ? box.localToGlobal(Offset.zero, ancestor: overlay)
        : const Offset(40, 40);
    return Positioned(
      left: p.dx + 40,
      bottom: 64,
      child: Container(
        width: 380,
        height: 518,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              height: 48,
              color: _kPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  const Icon(
                    Icons.support_agent_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '在线客服',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _showSupport = false),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: widget.runtime.buildSupportUri() == null
                  ? const Center(child: Text('未配置客服地址'))
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const Expanded(
                            child: Center(
                              child: Text(
                                '客服窗口已内嵌占位\n（当前版本保持稳定，点击下方按钮打开）',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () async {
                                final uri = widget.runtime.buildSupportUri();
                                if (uri == null) return;
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              },
                              child: const Text('打开客服'),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChangePasswordPanel extends StatefulWidget {
  const _ChangePasswordPanel({required this.onSubmit});
  final Future<void> Function(String oldPwd, String newPwd) onSubmit;

  @override
  State<_ChangePasswordPanel> createState() => _ChangePasswordPanelState();
}

class _ChangePasswordPanelState extends State<_ChangePasswordPanel> {
  final _old = TextEditingController();
  final _new1 = TextEditingController();
  final _new2 = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _old.dispose();
    _new1.dispose();
    _new2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.shield_rounded),
            SizedBox(width: 8),
            Text(
              '账户与安全',
              style: TextStyle(fontSize: 36 / 1.6, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _lineInput(_old, '当前密码'),
        const SizedBox(height: 10),
        _lineInput(_new1, '新密码'),
        const SizedBox(height: 10),
        _lineInput(_new2, '确认密码'),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: FilledButton(
            onPressed: _submitting
                ? null
                : () async {
                    if (_old.text.isEmpty ||
                        _new1.text.isEmpty ||
                        _new2.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请完整填写密码字段')),
                      );
                      return;
                    }
                    if (_new1.text != _new2.text) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('两次新密码不一致')));
                      return;
                    }
                    setState(() => _submitting = true);
                    try {
                      await widget.onSubmit(_old.text, _new1.text);
                      if (!mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('密码修改成功')));
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('$e')));
                    } finally {
                      if (mounted) setState(() => _submitting = false);
                    }
                  },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF5B8FEA),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _submitting ? '提交中...' : '确认修改',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _lineInput(TextEditingController c, String hint) => TextField(
    controller: c,
    obscureText: true,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF0F3F8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF7A7A7A), fontSize: 12),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 32 / 1.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Color(0xFF666666))),
      ],
    );
  }
}

class _MiniBox extends StatelessWidget {
  const _MiniBox({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFDDE4EF),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: Color(0xFF3F4652),
        ),
      ),
    );
  }
}

class _NodeGroup {
  const _NodeGroup(this.name, this.desc, this.nodes);
  final String name;
  final String desc;
  final List<_NodeItem> nodes;
}

class _NodeItem {
  const _NodeItem(this.name, this.delay);
  final String name;
  final int delay;
}

Widget _supportFab(VoidCallback onTap) => InkWell(
  onTap: onTap,
  borderRadius: BorderRadius.circular(999),
  child: Container(
    width: 52,
    height: 52,
    decoration: const BoxDecoration(
      color: _kPrimary,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Color(0x44000000),
          blurRadius: 12,
          offset: Offset(0, 6),
        ),
      ],
    ),
    child: const Icon(Icons.support_agent_rounded, color: Colors.white),
  ),
);
