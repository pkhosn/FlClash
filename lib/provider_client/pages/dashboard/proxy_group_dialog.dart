import 'package:fl_clash/controller.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/views/proxies/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/provider_tokens.dart';
import '../../widgets/app_button.dart';

Future<void> showV2ETProxyGroupDialog(
  BuildContext context, {
  String title = 'v2et',
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'close-proxy-dialog',
    barrierColor: Colors.black.withValues(alpha: 0.50),
    transitionDuration: const Duration(milliseconds: 140),
    pageBuilder: (context, animation, secondaryAnimation) => Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () => Navigator.of(context, rootNavigator: true).pop(),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: V2ETProxyGroupDialog(title: title),
            ),
          ),
        ),
      ),
    ),
    transitionBuilder: (context, animation, _, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class V2ETProxyGroupDialog extends ConsumerStatefulWidget {
  const V2ETProxyGroupDialog({super.key, required this.title});
  final String title;

  @override
  ConsumerState<V2ETProxyGroupDialog> createState() =>
      _V2ETProxyGroupDialogState();
}

class _V2ETProxyGroupDialogState extends ConsumerState<V2ETProxyGroupDialog> {
  String? selectedGroup;
  bool testingAll = false;
  final Set<String> testingProxyNames = <String>{};

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(currentGroupsStateProvider).value;
    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }
    selectedGroup ??= groups.first.name;
    final current = groups.firstWhere(
      (g) => g.name == selectedGroup,
      orElse: () => groups.first,
    );
    final selectedProxyName = ref.watch(getSelectedProxyNameProvider(current.name));
    final testUrl = ref.watch(realTestUrlProvider(current.testUrl));

    return Center(
      child: Container(
        width: 700,
        height: 540,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF84D8D1), width: 1.3),
          boxShadow: const [V2ETTokens.softShadow],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 250,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 16, 14),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.settings_input_component_rounded,
                          color: V2ETTokens.teal,
                        ),
                        const SizedBox(width: 8),
                        const Text('分流组', style: V2ETTokens.h3),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: V2ETTokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 8, 10, 12),
                      itemCount: groups.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 7),
                      itemBuilder: (_, i) {
                        final group = groups[i];
                        final active = group.name == current.name;
                        return _GroupTile(
                          title: group.name,
                          subtitle: group.now ?? '',
                          active: active,
                          onTap: () => setState(() => selectedGroup = group.name),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1, color: V2ETTokens.border),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                    child: Row(
                      children: [
                        Text(widget.title, style: V2ETTokens.h3),
                        const Spacer(),
                        V2ETButton(
                          label: '全部测速',
                          icon: Icons.speed_rounded,
                          tone: V2ETButtonTone.soft,
                          height: 30,
                          onPressed: testingAll
                              ? null
                              : () async {
                                  setState(() => testingAll = true);
                                  try {
                                    await delayTest(current.all, current.testUrl);
                                    await appController.updateGroups();
                                  } finally {
                                    if (mounted) {
                                      setState(() => testingAll = false);
                                    }
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                      itemCount: current.all.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (_, i) {
                        final proxy = current.all[i];
                        final active = proxy.name == selectedProxyName;
                        return _NodeTile(
                          name: proxy.name,
                          delay: _formatDelay(ref, proxy.name, testUrl),
                          timeout: _isTimeout(ref, proxy.name, testUrl),
                          delayColor: _delayColor(ref, proxy.name, testUrl),
                          active: active,
                          testing: testingProxyNames.contains(proxy.name),
                          onTest: () async {
                            setState(() => testingProxyNames.add(proxy.name));
                            try {
                              await proxyDelayTest(proxy, current.testUrl);
                              await appController.updateGroups();
                            } finally {
                              if (mounted) {
                                setState(
                                  () => testingProxyNames.remove(proxy.name),
                                );
                              }
                            }
                          },
                          onTap: () async {
                            final navigator = Navigator.of(context);
                            await appController.changeProxy(
                              groupName: current.name,
                              proxyName: proxy.name,
                            );
                            await appController.updateGroups();
                            if (!mounted) return;
                            navigator.pop();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDelay(WidgetRef ref, String proxyName, String? testUrl) {
    final delay = ref.watch(getDelayProvider(proxyName: proxyName, testUrl: testUrl));
    if (delay == null) return '--';
    if (delay <= 0) return '测试中';
    return '${delay}ms';
  }

  bool _isTimeout(WidgetRef ref, String proxyName, String? testUrl) {
    final delay = ref.watch(getDelayProvider(proxyName: proxyName, testUrl: testUrl));
    return (delay ?? 0) < 0;
  }

  Color _delayColor(WidgetRef ref, String proxyName, String? testUrl) {
    final delay = ref.watch(getDelayProvider(proxyName: proxyName, testUrl: testUrl));
    if (delay == null || delay == 0) return V2ETTokens.textMuted;
    if (delay < 0) return const Color(0xFFEF4444);
    if (delay < 100) return const Color(0xFF22C55E);
    if (delay < 500) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFDDF2EF) : const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(9),
          border: active ? Border.all(color: const Color(0xFF85D6D0)) : null,
        ),
        child: Row(
          children: [
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: V2ETTokens.small,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: active ? V2ETTokens.teal : V2ETTokens.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _NodeTile extends StatelessWidget {
  const _NodeTile({
    required this.name,
    required this.delay,
    required this.timeout,
    required this.delayColor,
    required this.active,
    required this.testing,
    required this.onTest,
    required this.onTap,
  });

  final String name;
  final String delay;
  final bool timeout;
  final Color delayColor;
  final bool active;
  final bool testing;
  final VoidCallback onTest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final flag = _flagForNodeName(name);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFDDF2EF) : Colors.white,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FB),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE3E8F0)),
              ),
              child: Text(flag, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              timeout ? '超时' : delay,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: delayColor,
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: testing ? null : onTest,
              borderRadius: BorderRadius.circular(7),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: testing
                    ? const Padding(
                        padding: EdgeInsets.all(6),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.speed_rounded,
                        size: 15,
                        color: V2ETTokens.primary,
                      ),
              ),
            ),
            if (active) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: V2ETTokens.teal,
              ),
            ],
          ],
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
}
