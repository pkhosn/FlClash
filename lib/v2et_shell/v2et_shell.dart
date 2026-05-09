import 'package:fl_clash/v2et_bridge/v2et_bridge_export.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class V2etShellPage extends ConsumerStatefulWidget {
  const V2etShellPage({super.key});

  @override
  ConsumerState<V2etShellPage> createState() => _V2etShellPageState();
}

class _V2etShellPageState extends ConsumerState<V2etShellPage> {
  V2etSession? _session;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
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
  const _V2etLoginView({required this.onLogin, this.error});

  final ValueChanged<V2etSession> onLogin;
  final String? error;

  @override
  ConsumerState<_V2etLoginView> createState() => _V2etLoginViewState();
}

class _V2etLoginViewState extends ConsumerState<_V2etLoginView> {
  final _formKey = GlobalKey<FormState>();
  final _baseUrlController = TextEditingController(text: 'https://v2et-board.xizdj.com');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
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
  const _V2etMainView({required this.session, required this.onLogout});

  final V2etSession session;
  final Future<void> Function() onLogout;

  @override
  ConsumerState<_V2etMainView> createState() => _V2etMainViewState();
}

class _V2etMainViewState extends ConsumerState<_V2etMainView> {
  bool _busy = false;
  V2etProxyMode _mode = V2etProxyMode.smart;
  String _status = 'Disconnected';

  @override
  void initState() {
    super.initState();
    _syncMode();
  }

  Future<void> _syncMode() async {
    final mode = await ref.read(v2etBridgeProvider).getProxyMode();
    if (!mounted) return;
    setState(() {
      _mode = mode;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
