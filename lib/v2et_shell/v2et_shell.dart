import 'package:fl_clash/v2et_bridge/v2et_bridge_export.dart';
import 'package:fl_clash/v2et_shell/v2et_runtime_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_session == null) {
      return _V2etLoginView(
        runtime: _runtime,
        error: _error,
        onLogin: (session) {
          setState(() {
            _session = session;
            _error = null;
          });
        },
      );
    }
    return _V2etAppFrame(
      runtime: _runtime,
      session: _session!,
      onLogout: () async {
        await ref.read(v2etBridgeProvider).logout();
        if (!mounted) return;
        setState(() {
          _session = null;
        });
      },
    );
  }
}

class _V2etLoginView extends ConsumerStatefulWidget {
  const _V2etLoginView({required this.onLogin, required this.runtime, this.error});

  final ValueChanged<V2etSession> onLogin;
  final V2etRuntimeConfig runtime;
  final String? error;

  @override
  ConsumerState<_V2etLoginView> createState() => _V2etLoginViewState();
}

class _V2etLoginViewState extends ConsumerState<_V2etLoginView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _baseUrlController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _baseUrlController = TextEditingController(
      text: widget.runtime.apiUrl?.trim().isNotEmpty == true ? widget.runtime.apiUrl : 'https://v2et-board.xizdj.com',
    );
    _emailController = TextEditingController(text: widget.runtime.defaultEmail);
    _passwordController = TextEditingController(text: widget.runtime.defaultPassword);
    _error = widget.error;
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final uri = Uri.parse(_baseUrlController.text.trim());
      final session = await ref.read(v2etBridgeProvider).login(
        baseUrl: uri,
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      widget.onLogin(session);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final support = widget.runtime.buildSupportUri();
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FD),
      floatingActionButton: support == null
          ? null
          : FloatingActionButton.small(
              onPressed: () async => launchUrl(support, mode: LaunchMode.externalApplication),
              child: const Icon(Icons.support_agent_rounded),
            ),
      body: Row(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0A3A77), Color(0xFF0665D0)],
                ),
              ),
              child: const Center(
                child: Text(
                  'V2ET',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 56),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  margin: const EdgeInsets.all(20),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('登录', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _baseUrlController,
                            decoration: const InputDecoration(labelText: 'Base URL'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                          ),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(labelText: 'Email'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                          ),
                          TextFormField(
                            controller: _passwordController,
                            decoration: const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 10),
                            Text(_error!, style: TextStyle(color: scheme.error, fontSize: 12)),
                          ],
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _submitting ? null : _submit,
                              child: Text(_submitting ? '登录中...' : '登录'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _V2etTab { dashboard, store, me }

class _V2etAppFrame extends ConsumerStatefulWidget {
  const _V2etAppFrame({required this.runtime, required this.session, required this.onLogout});

  final V2etRuntimeConfig runtime;
  final V2etSession session;
  final Future<void> Function() onLogout;

  @override
  ConsumerState<_V2etAppFrame> createState() => _V2etAppFrameState();
}

class _V2etAppFrameState extends ConsumerState<_V2etAppFrame> {
  _V2etTab _tab = _V2etTab.dashboard;
  bool _busy = false;
  bool _subLoading = false;
  V2etProxyMode _mode = V2etProxyMode.smart;
  String _status = 'Disconnected';
  V2etSubscription? _subscription;
  List<V2etStoreOffer> _offers = const [];
  bool _offersLoading = false;

  @override
  void initState() {
    super.initState();
    _syncMode();
    _loadSubscription();
    _loadOffers();
  }

  Future<void> _syncMode() async {
    final mode = await ref.read(v2etBridgeProvider).getProxyMode();
    if (!mounted) return;
    setState(() => _mode = mode);
  }

  Future<void> _loadSubscription() async {
    setState(() => _subLoading = true);
    try {
      final sub = await ref.read(v2etBridgeProvider).fetchSubscription();
      if (!mounted) return;
      setState(() => _subscription = sub);
    } catch (_) {
      if (!mounted) return;
      setState(() => _subscription = null);
    } finally {
      if (mounted) setState(() => _subLoading = false);
    }
  }

  Future<void> _loadOffers() async {
    setState(() => _offersLoading = true);
    try {
      final offers = await ref.read(v2etBridgeProvider).fetchStoreOffers();
      if (!mounted) return;
      setState(() => _offers = offers);
    } catch (_) {
      if (!mounted) return;
      setState(() => _offers = const []);
    } finally {
      if (mounted) setState(() => _offersLoading = false);
    }
  }

  Future<void> _connect() async {
    setState(() => _busy = true);
    try {
      await ref.read(v2etBridgeProvider).connect();
      if (!mounted) return;
      setState(() => _status = 'Connected');
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Connect failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disconnect() async {
    setState(() => _busy = true);
    try {
      await ref.read(v2etBridgeProvider).disconnect();
      if (!mounted) return;
      setState(() => _status = 'Disconnected');
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Disconnect failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setMode(V2etProxyMode mode) async {
    setState(() => _busy = true);
    try {
      await ref.read(v2etBridgeProvider).setProxyMode(mode);
      if (!mounted) return;
      setState(() => _mode = mode);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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

  Future<void> _openUrl(String? raw) async {
    final text = (raw ?? '').trim();
    if (text.isEmpty) return;
    final uri = Uri.tryParse(text);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _buy(V2etStoreOffer offer) async {
    final period = offer.prices.keys.isNotEmpty ? offer.prices.keys.first : 'month';
    try {
      final payUri = await ref.read(v2etBridgeProvider).startCheckout(
        planId: offer.id,
        period: period,
      );
      await launchUrl(payUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('打开支付失败: $e')),
      );
    }
  }

  Widget _buildStorePanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('商店', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _offersLoading ? null : _loadOffers,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('刷新'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_offersLoading) const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: 10),
              if (_offers.isEmpty)
                const Text('暂无套餐数据')
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: _offers.length,
                    separatorBuilder: (_, s) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final offer = _offers[i];
                      final first = offer.prices.entries.isNotEmpty ? offer.prices.entries.first : null;
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0x220665D0)),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(offer.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(first == null ? '-' : '${first.key} ¥${first.value.toStringAsFixed(2)}'),
                                ],
                              ),
                            ),
                            FilledButton(
                              onPressed: () => _buy(offer),
                              child: const Text('立即订阅'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _openUrl(widget.runtime.officialSiteUrl),
                    icon: const Icon(Icons.public_rounded),
                    label: const Text('官网'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _openUrl(widget.runtime.groupUrl),
                    icon: const Icon(Icons.groups_rounded),
                    label: const Text('群组'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMePanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('我的', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('账号：${widget.session.email}'),
              const SizedBox(height: 6),
              Text('状态：$_status'),
              const SizedBox(height: 6),
              Text('套餐：${_subscription?.planName ?? '-'}'),
              const SizedBox(height: 6),
              Text('流量：${_formatBytes(_subscription?.usedBytes)} / ${_formatBytes(_subscription?.transferEnableBytes)}'),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _openUrl(widget.runtime.inviteManageUrl),
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: const Text('邀请管理'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _openUrl(widget.runtime.giftCardHelpUrl),
                    icon: const Icon(Icons.card_giftcard_rounded),
                    label: const Text('礼品卡帮助'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _subLoading ? null : _loadSubscription,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('刷新订阅'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardPanel() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('状态：$_status', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('智能'),
              selected: _mode == V2etProxyMode.smart,
              onSelected: _busy ? null : (_) => _setMode(V2etProxyMode.smart),
            ),
            ChoiceChip(
              label: const Text('全局'),
              selected: _mode == V2etProxyMode.global,
              onSelected: _busy ? null : (_) => _setMode(V2etProxyMode.global),
            ),
            ChoiceChip(
              label: const Text('TUN'),
              selected: _mode == V2etProxyMode.tun,
              onSelected: _busy ? null : (_) => _setMode(V2etProxyMode.tun),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton(onPressed: _busy ? null : _connect, child: const Text('连接')),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: _busy ? null : _disconnect, child: const Text('断开')),
            const SizedBox(width: 8),
            TextButton(onPressed: _subLoading ? null : _loadSubscription, child: const Text('刷新订阅')),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _subLoading
                ? const LinearProgressIndicator(minHeight: 2)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('套餐：${_subscription?.planName ?? '-'}'),
                      const SizedBox(height: 4),
                      Text('到期：${_subscription?.expiredAt?.toString() ?? '-'}'),
                      const SizedBox(height: 4),
                      Text('流量：${_formatBytes(_subscription?.usedBytes)} / ${_formatBytes(_subscription?.transferEnableBytes)}'),
                      const SizedBox(height: 4),
                      Text('订阅：${_subscription?.subscriptionUrl.toString() ?? '-'}'),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainPanel() {
    return switch (_tab) {
      _V2etTab.dashboard => _buildDashboardPanel(),
      _V2etTab.store => _buildStorePanel(),
      _V2etTab.me => _buildMePanel(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final support = widget.runtime.buildSupportUri();
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FD),
      floatingActionButton: support == null
          ? null
          : FloatingActionButton.small(
              onPressed: () async => launchUrl(support, mode: LaunchMode.externalApplication),
              child: const Icon(Icons.support_agent_rounded),
            ),
      body: SafeArea(
        child: Row(
          children: [
            Container(
              width: 82,
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _SideItem(icon: Icons.dashboard_customize_rounded, text: '仪表盘', selected: _tab == _V2etTab.dashboard, onTap: () => setState(() => _tab = _V2etTab.dashboard)),
                  _SideItem(icon: Icons.shopping_bag_rounded, text: '商店', selected: _tab == _V2etTab.store, onTap: () => setState(() => _tab = _V2etTab.store)),
                  _SideItem(icon: Icons.account_circle_rounded, text: '我的', selected: _tab == _V2etTab.me, onTap: () => setState(() => _tab = _V2etTab.me)),
                  const Spacer(),
                  IconButton(
                    onPressed: _busy
                        ? null
                        : () async {
                            await widget.onLogout();
                          },
                    icon: const Icon(Icons.logout_rounded),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            Expanded(child: _buildMainPanel()),
          ],
        ),
      ),
    );
  }
}

class _SideItem extends StatelessWidget {
  const _SideItem({required this.icon, required this.text, required this.selected, required this.onTap});

  final IconData icon;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 74,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? const Color(0xFF0665D0) : const Color(0xFF656D7A)),
            const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: selected ? const Color(0xFF0665D0) : const Color(0xFF656D7A),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
