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
    return _V2etMainView(
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
      text: widget.runtime.apiUrl?.trim().isNotEmpty == true
          ? widget.runtime.apiUrl
          : 'https://v2et-board.xizdj.com',
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
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FD),
      floatingActionButton: FloatingActionButton.small(
        onPressed: () async {
          final support = widget.runtime.buildSupportUri();
          if (support == null) return;
          await launchUrl(support, mode: LaunchMode.externalApplication);
        },
        child: const Icon(Icons.support_agent_rounded),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('V2ET Login', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
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
                        child: Text(_submitting ? 'Logging in...' : 'Login'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _V2etMainView extends ConsumerStatefulWidget {
  const _V2etMainView({
    required this.runtime,
    required this.session,
    required this.onLogout,
  });

  final V2etRuntimeConfig runtime;
  final V2etSession session;
  final Future<void> Function() onLogout;

  @override
  ConsumerState<_V2etMainView> createState() => _V2etMainViewState();
}

class _V2etMainViewState extends ConsumerState<_V2etMainView> {
  bool _busy = false;
  bool _subLoading = false;
  V2etProxyMode _mode = V2etProxyMode.smart;
  String _status = 'Disconnected';
  V2etSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _syncMode();
    _loadSubscription();
  }

  Future<void> _syncMode() async {
    final mode = await ref.read(v2etBridgeProvider).getProxyMode();
    if (!mounted) return;
    setState(() {
      _mode = mode;
    });
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

  @override
  Widget build(BuildContext context) {
    final supportUri = widget.runtime.buildSupportUri();
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FD),
      floatingActionButton: supportUri == null
          ? null
          : FloatingActionButton.small(
              onPressed: () async {
                await launchUrl(supportUri, mode: LaunchMode.externalApplication);
              },
              child: const Icon(Icons.support_agent_rounded),
            ),
      appBar: AppBar(
        title: Text('V2ET • ${widget.session.email}'),
        actions: [
          IconButton(
            onPressed: _busy
                ? null
                : () async {
                    await widget.onLogout();
                  },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: $_status'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Smart'),
                  selected: _mode == V2etProxyMode.smart,
                  onSelected: _busy ? null : (_) => _setMode(V2etProxyMode.smart),
                ),
                ChoiceChip(
                  label: const Text('Global'),
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
                FilledButton(onPressed: _busy ? null : _connect, child: const Text('Connect')),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: _busy ? null : _disconnect, child: const Text('Disconnect')),
                const SizedBox(width: 8),
                TextButton(onPressed: _subLoading ? null : _loadSubscription, child: const Text('Refresh Sub')),
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
                          Text('Plan: ${_subscription?.planName ?? '-'}'),
                          const SizedBox(height: 4),
                          Text('Expire: ${_subscription?.expiredAt?.toString() ?? '-'}'),
                          const SizedBox(height: 4),
                          Text('Usage: ${_formatBytes(_subscription?.usedBytes)} / ${_formatBytes(_subscription?.transferEnableBytes)}'),
                          const SizedBox(height: 4),
                          Text('Sub URL: ${_subscription?.subscriptionUrl.toString() ?? '-'}'),
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
