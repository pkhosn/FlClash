import 'package:flutter/material.dart';
import '../../mock/mock_provider_data.dart';
import '../../theme/provider_tokens.dart';
import '../../widgets/app_button.dart';

Future<void> showV2ETProxyGroupDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.50),
    builder: (_) => const Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(24),
      child: V2ETProxyGroupDialog(),
    ),
  );
}

class V2ETProxyGroupDialog extends StatelessWidget {
  const V2ETProxyGroupDialog({super.key});

  @override
  Widget build(BuildContext context) {
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
                      itemCount: mockGroups.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 7),
                      itemBuilder: (_, i) => _GroupTile(group: mockGroups[i]),
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
                        const Text('v2et', style: V2ETTokens.h3),
                        const Spacer(),
                        V2ETButton(
                          label: '全部测速',
                          icon: Icons.speed_rounded,
                          tone: V2ETButtonTone.soft,
                          height: 30,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                      itemCount: mockNodes.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (_, i) => _NodeTile(node: mockNodes[i]),
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
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group});
  final V2ETProxyGroupMock group;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: group.active ? const Color(0xFFDDF2EF) : const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(9),
        border: group.active
            ? Border.all(color: const Color(0xFF85D6D0))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: group.active
                  ? const Color(0xFFE4E5C8)
                  : const Color(0xFFE4F2F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(group.icon, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  group.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: V2ETTokens.small,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: group.active ? V2ETTokens.teal : V2ETTokens.textMuted,
          ),
        ],
      ),
    );
  }
}

class _NodeTile extends StatelessWidget {
  const _NodeTile({required this.node});
  final V2ETNodeMock node;
  @override
  Widget build(BuildContext context) {
    final delayColor = node.delay.startsWith('1') || node.delay.startsWith('8')
        ? V2ETTokens.success
        : V2ETTokens.warning;
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: node.active ? const Color(0xFFDDF2EF) : Colors.white,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 28,
            decoration: BoxDecoration(
              color: V2ETTokens.cardSoft,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(child: Text(node.flag)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (node.subtitle.isNotEmpty)
                  Text(
                    node.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: V2ETTokens.small,
                  ),
              ],
            ),
          ),
          Text(
            node.delay,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: delayColor,
            ),
          ),
          if (node.active) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: V2ETTokens.teal,
            ),
          ],
        ],
      ),
    );
  }
}
