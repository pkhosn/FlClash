import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/v2et_bridge/v2et_bridge.dart';
import 'package:fl_clash/v2et_bridge/v2et_bridge_provider.dart';
import '../../theme/provider_tokens.dart';
import '../../widgets/app_card.dart';
import '../../data/v2et_runtime_providers.dart';
import 'notice_dialog.dart';
import 'proxy_group_dialog.dart';

class V2ETProviderHomePage extends ConsumerWidget {
  const V2ETProviderHomePage({super.key, this.showNoticePopup = true});

  final bool showNoticePopup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subAsync = ref.watch(v2etSubscriptionProvider);
    final modeAsync = ref.watch(v2etProxyModeProvider);
    final isStart = ref.watch(isStartProvider);
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

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 34, 24, 26),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              _UsageCard(
                onNotice: () => showV2ETNoticeDialog(context),
                showNoticePopup: showNoticePopup,
                remainText: _fmtBytes(remain.toInt()),
                usedText: _fmtBytes(used.toInt()),
                totalText: _fmtBytes(total.toInt()),
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
                  await ref.read(v2etBridgeProvider).setProxyMode(m);
                  ref.invalidate(v2etProxyModeProvider);
                },
              ),
              const SizedBox(height: 18),
              _CurrentNodeCard(onOpen: () => showV2ETProxyGroupDialog(context)),
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
}

class _UsageCard extends StatelessWidget {
  const _UsageCard({
    required this.onNotice,
    required this.showNoticePopup,
    required this.remainText,
    required this.usedText,
    required this.totalText,
    required this.progress,
  });
  final VoidCallback onNotice;
  final bool showNoticePopup;
  final String remainText;
  final String usedText;
  final String totalText;
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
                  value: '21 天',
                  align: CrossAxisAlignment.end,
                ),
              ),
              if (showNoticePopup)
                Row(
                  children: [
                    _ActionIcon(icon: Icons.refresh_rounded, onTap: () {}),
                    const SizedBox(width: 8),
                    _ActionIcon(icon: Icons.public_rounded, onTap: () {}),
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
              const Text('预计重置日期 2026-06-01', style: V2ETTokens.mini),
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

class _PowerButton extends StatelessWidget {
  const _PowerButton({required this.started, required this.onTap});
  final bool started;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(88),
          child: Container(
            width: 176,
            height: 176,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF2F5F8), Color(0xFFE7ECF1)],
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
              ],
            ),
            child: Icon(
              Icons.power_settings_new_rounded,
              size: 72,
              color: started ? V2ETTokens.success : Colors.grey.shade600,
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
                color: started ? V2ETTokens.success : V2ETTokens.textSecondary,
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

class _CurrentNodeCard extends StatelessWidget {
  const _CurrentNodeCard({required this.onOpen});
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) {
    return V2ETCard(
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
            child: const Center(child: Text('🇭🇰')),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '自动选择',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text('香港3-Gemini', style: V2ETTokens.small),
              ],
            ),
          ),
          const Text(
            '83ms',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: V2ETTokens.success,
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
    );
  }
}
