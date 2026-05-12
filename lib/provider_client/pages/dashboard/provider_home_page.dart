import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/common/preferences.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/v2et_bridge/v2et_bridge.dart';
import 'package:fl_clash/v2et_bridge/v2et_bridge_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fl_clash/views/proxies/common.dart';
import '../../config/remote_config_provider.dart';
import '../../theme/provider_tokens.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_dialog.dart';
import '../../data/v2et_runtime_providers.dart';
import 'notice_dialog.dart';
import 'proxy_group_dialog.dart';

class V2ETProviderHomePage extends ConsumerStatefulWidget {
  const V2ETProviderHomePage({
    super.key,
    this.showNoticePopup = true,
    this.siteName = '',
  });

  final bool showNoticePopup;
  final String siteName;

  @override
  ConsumerState<V2ETProviderHomePage> createState() =>
      _V2ETProviderHomePageState();
}

class _V2ETProviderHomePageState extends ConsumerState<V2ETProviderHomePage>
    with WidgetsBindingObserver {
  static const _skipGlobalWarnKey = 'v2et_skip_global_mode_warning';
  Timer? _ticker;
  bool _didAutoDelayTest = false;
  bool _autoDelayTesting = false;
  ProviderSubscription<bool>? _isStartSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _isStartSub = ref.listenManual<bool>(isStartProvider, (prev, next) {
      if (next) {
        _scheduleAutoDelayTest();
      }
    });
    _ticker = Timer.periodic(const Duration(seconds: 20), (_) {
      if (mounted) ref.invalidate(v2etSubscriptionProvider);
    });
    if (ref.read(isStartProvider)) {
      _scheduleAutoDelayTest();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _isStartSub?.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(v2etSubscriptionProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subAsync = ref.watch(v2etSubscriptionProvider);
    final modeAsync = ref.watch(v2etProxyModeProvider);
    final isStart = ref.watch(isStartProvider);
    final appConfig = ref.watch(appConfigProvider);
    final sub = subAsync.when(
      data: (d) => d,
      loading: () => null,
      error: (_, _) => null,
    );
    final mode = modeAsync.when(
      data: (d) => d,
      loading: () => V2etProxyMode.smart,
      error: (_, _) => V2etProxyMode.smart,
    );
    final total = (sub?.transferEnableBytes ?? 0).toDouble();
    final used = (sub?.usedBytes ?? 0).toDouble();
    final remain = (total - used).clamp(0, double.infinity).toDouble();
    final ratio = total > 0 ? (used / total).clamp(0, 1).toDouble() : 0.0;
    final expiryText = _expiryText(sub?.expiredAt);
    final resetDateText = _resetDateText(sub?.resetDay);

    if (isStart && !_didAutoDelayTest && !_autoDelayTesting) {
      _scheduleAutoDelayTest();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 34, 24, 26),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              _UsageCard(
                onNotice: () => showV2ETNoticeDialog(context),
                onRefresh: () => ref.invalidate(v2etSubscriptionProvider),
                onOpenWebsite: () =>
                    _openOfficialWebsite(appConfig.officialWebsite),
                showNoticePopup: widget.showNoticePopup,
                remainText: _fmtBytes(remain.toInt()),
                usedText: _fmtBytes(used.toInt()),
                totalText: _fmtBytes(total.toInt()),
                expiryText: expiryText,
                resetDateText: resetDateText,
                progress: ratio,
              ),
              const SizedBox(height: 58),
              _PowerButton(
                started: isStart,
                onTap: () async {
                  await appController.updateStatus(!isStart);
                },
              ),
              const SizedBox(height: 30),
              _ModeCard(
                mode: mode,
                onMode: (m) async {
                  if (m == V2etProxyMode.global &&
                      mode != V2etProxyMode.global) {
                    final confirmed = await _confirmGlobalMode();
                    if (!confirmed) return;
                  }
                  await ref.read(v2etBridgeProvider).setProxyMode(m);
                  ref.invalidate(v2etProxyModeProvider);
                },
              ),
              const SizedBox(height: 18),
              _CurrentNodeCard(
                onOpen: () => showV2ETProxyGroupDialog(
                  context,
                  title: _nodeDialogTitle(widget.siteName, appConfig.brandName),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _fmtBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const unit = ['B', 'KB', 'MB', 'GB', 'TB'];
    double value = bytes.toDouble();
    int idx = 0;
    while (value >= 1024 && idx < unit.length - 1) {
      value /= 1024;
      idx++;
    }
    return '${value.toStringAsFixed(idx == 0 ? 0 : 1)} ${unit[idx]}';
  }

  String _expiryText(DateTime? expiredAt) {
    if (expiredAt == null) return '--';
    final now = DateTime.now();
    final days = expiredAt.difference(now).inDays;
    if (days <= 0) return '已到期';
    return '$days 天';
  }

  String _resetDateText(int? resetDay) {
    if (resetDay == null) return '--';
    if (resetDay < 0) return '--';
    final target = DateTime.now().add(Duration(days: resetDay));
    final y = target.year.toString().padLeft(4, '0');
    final m = target.month.toString().padLeft(2, '0');
    final d = target.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _openOfficialWebsite(String url) async {
    final text = url.trim();
    if (text.isEmpty) return;
    final uri = Uri.tryParse(text);
    if (uri == null || !uri.hasScheme) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _runAutoDelayTestOnce() async {
    if (_didAutoDelayTest || _autoDelayTesting) return;
    _autoDelayTesting = true;
    try {
      await appController.updateGroups();
      final groups = ref.read(currentGroupsStateProvider).value;
      if (groups.isEmpty) return;
      for (final group in groups) {
        await delayTest(group.all, group.testUrl);
      }
      await appController.updateGroups();
      _didAutoDelayTest = true;
    } catch (_) {
      // Keep silent as requested: background behavior without popup/tips.
    } finally {
      _autoDelayTesting = false;
      if (!_didAutoDelayTest && mounted && ref.read(isStartProvider)) {
        Future<void>.delayed(const Duration(seconds: 2), _scheduleAutoDelayTest);
      }
    }
  }

  void _scheduleAutoDelayTest() {
    if (!mounted || _didAutoDelayTest || _autoDelayTesting) return;
    Future.microtask(_runAutoDelayTestOnce);
  }

  String _nodeDialogTitle(String siteName, String brandName) {
    final fromSite = siteName.trim();
    if (fromSite.isNotEmpty) return fromSite;
    final fromBrand = brandName.trim();
    return fromBrand.isEmpty ? 'v2et' : fromBrand;
  }

  Future<bool> _confirmGlobalMode() async {
    final sp = await preferences.sharedPreferencesCompleter.future;
    final skip = sp?.getBool(_skipGlobalWarnKey) ?? false;
    if (skip) return true;
    if (!mounted) return false;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => const _GlobalModeWarningDialog(),
    );
    return result == true;
  }
}

class _GlobalModeWarningDialog extends StatefulWidget {
  const _GlobalModeWarningDialog();

  @override
  State<_GlobalModeWarningDialog> createState() =>
      _GlobalModeWarningDialogState();
}

class _GlobalModeWarningDialogState extends State<_GlobalModeWarningDialog> {
  bool dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return V2ETDialogShell(
      title: '全局模式警告',
      icon: Icons.warning_amber_rounded,
      width: 420,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '全局模式会将所有流量通过代理服务器转发，可能会导致部分国内网站访问缓慢。建议使用规则模式以获得更好的体验。',
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_rounded, color: Color(0xFF3B82F6), size: 18),
                    SizedBox(width: 8),
                    Text(
                      '使用提示',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '建议使用规则模式以获得更好的体验',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '请确保已选择代理节点（非 DIRECT 直连）',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => setState(() => dontShowAgain = !dontShowAgain),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: dontShowAgain,
                      activeColor: const Color(0xFFF59E0B),
                      side: const BorderSide(color: Color(0xFF9CA3AF)),
                      onChanged: (v) => setState(() => dontShowAgain = v ?? false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '不再提示',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, false),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFF1F1F1),
                foregroundColor: const Color(0xFF4B5563),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                '取消',
                style: TextStyle(fontSize: 25 / 2, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: () async {
                if (dontShowAgain) {
                  final sp = await preferences.sharedPreferencesCompleter.future;
                  await sp?.setBool(
                    _V2ETProviderHomePageState._skipGlobalWarnKey,
                    true,
                  );
                }
                if (!context.mounted) return;
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                '确定',
                style: TextStyle(fontSize: 25 / 2, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UsageCard extends StatelessWidget {
  const _UsageCard({
    required this.onNotice,
    required this.onRefresh,
    required this.onOpenWebsite,
    required this.showNoticePopup,
    required this.remainText,
    required this.usedText,
    required this.totalText,
    required this.expiryText,
    required this.resetDateText,
    required this.progress,
  });
  final VoidCallback onNotice;
  final VoidCallback onRefresh;
  final VoidCallback onOpenWebsite;
  final bool showNoticePopup;
  final String remainText;
  final String usedText;
  final String totalText;
  final String expiryText;
  final String resetDateText;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return V2ETCard(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      radius: 16,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _UsageStat(
                  label: '剩余流量',
                  value: remainText,
                  align: CrossAxisAlignment.start,
                ),
              ),
              Expanded(
                child: _UsageStat(
                  label: '有效期',
                  value: expiryText,
                  align: CrossAxisAlignment.end,
                ),
              ),
              if (showNoticePopup)
                Row(
                  children: [
                    _ActionIcon(icon: Icons.refresh_rounded, onTap: onRefresh),
                    const SizedBox(width: 8),
                    _ActionIcon(
                      icon: Icons.public_rounded,
                      onTap: onOpenWebsite,
                    ),
                    const SizedBox(width: 8),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _ActionIcon(
                          icon: Icons.campaign_rounded,
                          onTap: onNotice,
                        ),
                        Positioned(
                          right: -4,
                          top: -6,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: V2ETTokens.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '5',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E4E9),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: V2ETTokens.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: V2ETTokens.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Text('已用 $usedText', style: V2ETTokens.mini),
              const Spacer(),
              Text('共 $totalText', style: V2ETTokens.mini),
              const Spacer(),
              Text('预计重置日期 $resetDateText', style: V2ETTokens.mini),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsageStat extends StatelessWidget {
  const _UsageStat({
    required this.label,
    required this.value,
    required this.align,
  });
  final String label;
  final String value;
  final CrossAxisAlignment align;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(label, style: V2ETTokens.mini),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: V2ETTokens.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: V2ETTokens.primarySoft,
    borderRadius: BorderRadius.circular(11),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, size: 20, color: V2ETTokens.primary),
      ),
    ),
  );
}

class _PowerButton extends StatefulWidget {
  const _PowerButton({required this.started, required this.onTap});
  final bool started;
  final VoidCallback onTap;

  @override
  State<_PowerButton> createState() => _PowerButtonState();
}

class _PowerButtonState extends State<_PowerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final started = widget.started;
    final onTap = widget.onTap;
    final primary = V2ETTokens.primary;
    final darkPrimary = Color.lerp(primary, Colors.black, 0.14) ?? primary;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final breath = _hovering
            ? (0.75 + (_controller.value * 0.25))
            : (0.92 + (_controller.value * 0.08));
        final glow = started ? 0.28 + (_controller.value * 0.22) : 0.10;

        return Column(
          children: [
            MouseRegion(
              onEnter: (_) => setState(() => _hovering = true),
              onExit: (_) => setState(() => _hovering = false),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 180),
                scale: _hovering ? 1.03 : 1.0,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(88),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    width: 176,
                    height: 176,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.08),
                        radius: 0.92,
                        colors: started
                            ? [
                                Color.lerp(primary, Colors.white, 0.64)!,
                                Color.lerp(primary, Colors.white, 0.20)!,
                                darkPrimary,
                              ]
                            : [
                                const Color(0xFFF3F6FA),
                                const Color(0xFFEAF0F6),
                                const Color(0xFFE1E8F0),
                              ],
                        stops: const [0.0, 0.56, 1.0],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                        const BoxShadow(
                          color: Colors.white,
                          blurRadius: 20,
                          offset: Offset(-8, -8),
                        ),
                        if (started || _hovering)
                          BoxShadow(
                            color: primary.withValues(
                              alpha: breath * (_hovering ? 0.34 : glow),
                            ),
                            blurRadius: _hovering ? 42 : 30,
                            spreadRadius: _hovering ? 4 : 2,
                          ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: IgnorePointer(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: started || _hovering ? 164 : 148,
                              height: started || _hovering ? 164 : 148,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    primary.withValues(
                                      alpha: started ? 0.30 : 0.14,
                                    ),
                                    primary.withValues(alpha: 0.0),
                                  ],
                                  stops: const [0.05, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 22,
                          child: IgnorePointer(
                            child: Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Color.lerp(
                                      primary,
                                      Colors.white,
                                      0.78,
                                    )!.withValues(
                                      alpha: _hovering ? 0.40 : 0.30,
                                    ),
                                    Colors.white.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Icon(
                            Icons.power_settings_new_rounded,
                            size: 72,
                            color: started
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFC8CDD4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle_outlined,
                    size: 16,
                    color: started
                        ? V2ETTokens.success
                        : V2ETTokens.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    started ? '已连接' : '未连接',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: started
                          ? V2ETTokens.success
                          : V2ETTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({required this.mode, required this.onMode});
  final V2etProxyMode mode;
  final ValueChanged<V2etProxyMode> onMode;
  @override
  Widget build(BuildContext context) {
    return V2ETCard(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.tune_rounded, color: V2ETTokens.textSecondary),
              SizedBox(width: 8),
              Text(
                '代理模式',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              Spacer(),
              Text('根据规则自动选择直连或代理', style: V2ETTokens.small),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ModeButton(
                  label: '规则',
                  selected: mode == V2etProxyMode.smart,
                  onTap: () => onMode(V2etProxyMode.smart),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ModeButton(
                  label: '全局',
                  selected: mode == V2etProxyMode.global,
                  onTap: () => onMode(V2etProxyMode.global),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ModeButton(
                  label: 'TUN',
                  selected: mode == V2etProxyMode.tun,
                  onTap: () => onMode(V2etProxyMode.tun),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    this.selected = false,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      height: 46,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFD9EFEA) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? const Color(0xFF8FD0C5) : V2ETTokens.border,
        ),
        boxShadow: selected ? const [V2ETTokens.tinyShadow] : null,
      ),
      child: Center(
        child: Text(
          selected ? '✓ $label' : label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: selected ? const Color(0xFF0B8B7D) : V2ETTokens.textPrimary,
          ),
        ),
      ),
    ),
  );
}

class _CurrentNodeCard extends ConsumerWidget {
  const _CurrentNodeCard({required this.onOpen});
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(currentGroupsStateProvider).value;
    final currentGroup = groups.isEmpty ? null : groups.first;
    final groupName = currentGroup?.name ?? '自动选择';
    final selectedProxy = currentGroup == null
        ? '--'
        : (ref.watch(getSelectedProxyNameProvider(groupName)) ?? '--');
    final mainName = selectedProxy.trim().isEmpty || selectedProxy == '--'
        ? groupName
        : selectedProxy;
    final delay = currentGroup == null
        ? null
        : ref.watch(
            getDelayProvider(
              proxyName: selectedProxy,
              testUrl: currentGroup.testUrl,
            ),
          );
    final delayText = delay == null
        ? '--'
        : (delay <= 0 ? '测试中' : '${delay}ms');
    final delayColor = _delayColor(delay);
    final nodeFlag = _flagForNodeName(mainName);

    return V2ETCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 36,
                decoration: BoxDecoration(
                  color: V2ETTokens.cardSoft,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE3E8F0)),
                ),
                child: Center(child: Text(nodeFlag)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mainName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                delayText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: delayColor,
                ),
              ),
              const SizedBox(width: 14),
              Material(
                color: const Color(0xFFECE7FF),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: onOpen,
                  borderRadius: BorderRadius.circular(8),
                  child: const SizedBox(
                    width: 32,
                    height: 32,
                    child: Icon(
                      Icons.live_tv_rounded,
                      color: Color(0xFF7357C8),
                      size: 18,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onOpen,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: V2ETTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _flagForNodeName(String name) {
    final n = name.toLowerCase();
    if (n.contains('香港') || n.contains('hk') || n.contains('hong kong')) {
      return '🇭🇰';
    }
    if (n.contains('台湾') || n.contains('台灣') || n.contains('tw')) {
      return '🇹🇼';
    }
    if (n.contains('日本') || n.contains('jp') || n.contains('japan')) {
      return '🇯🇵';
    }
    if (n.contains('新加坡') || n.contains('sg') || n.contains('singapore')) {
      return '🇸🇬';
    }
    if (n.contains('美国') || n.contains('美國') || n.contains('us')) {
      return '🇺🇸';
    }
    if (n.contains('韩国') || n.contains('韓國') || n.contains('kr')) {
      return '🇰🇷';
    }
    if (n.contains('英国') || n.contains('英國') || n.contains('uk')) {
      return '🇬🇧';
    }
    if (n.contains('德国') || n.contains('德國') || n.contains('de')) {
      return '🇩🇪';
    }
    if (n.contains('法国') || n.contains('法國') || n.contains('fr')) {
      return '🇫🇷';
    }
    if (n.contains('加拿大') || n.contains('ca') || n.contains('canada')) {
      return '🇨🇦';
    }
    if (n.contains('澳大利亚') || n.contains('澳洲') || n.contains('au')) {
      return '🇦🇺';
    }
    return '🌐';
  }

  Color _delayColor(int? delay) {
    if (delay == null || delay == 0) return V2ETTokens.textMuted;
    if (delay < 0) return const Color(0xFFEF4444);
    if (delay < 100) return const Color(0xFF22C55E);
    if (delay < 500) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
