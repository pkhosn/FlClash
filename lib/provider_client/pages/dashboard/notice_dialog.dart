import 'package:flutter/material.dart';
import 'package:fl_clash/v2et_bridge/v2et_bridge.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/v2et_runtime_providers.dart';
import '../../theme/provider_tokens.dart';
import '../../widgets/app_button.dart';

Future<void> showV2ETNoticeDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.52),
    builder: (_) => const Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(24),
      child: V2ETNoticeDialog(),
    ),
  );
}

class V2ETNoticeDialog extends ConsumerStatefulWidget {
  const V2ETNoticeDialog({super.key});

  @override
  ConsumerState<V2ETNoticeDialog> createState() => _V2ETNoticeDialogState();
}

class _V2ETNoticeDialogState extends ConsumerState<V2ETNoticeDialog> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final noticesAsync = ref.watch(v2etNoticesProvider);
    final notices = noticesAsync.when(
      data: (data) => data,
      loading: () => const <V2etNotice>[],
      error: (_, _) => const <V2etNotice>[],
    );
    if (index >= notices.length && notices.isNotEmpty) index = notices.length - 1;
    final current = notices.isEmpty ? null : notices[index];
    final title = current?.title ?? '暂无公告';
    final content = current?.content ?? '暂无公告内容';
    final countText = notices.isEmpty ? '第 0 条，共 0 条' : '第 ${index + 1} 条，共 ${notices.length} 条';
    final created = current?.createdAt;
    final dateText = created == null
        ? '--'
        : '${created.year.toString().padLeft(4, '0')}-${created.month.toString().padLeft(2, '0')}-${created.day.toString().padLeft(2, '0')} ${created.hour.toString().padLeft(2, '0')}:${created.minute.toString().padLeft(2, '0')}';
    return Center(
      child: Container(
        width: 528,
        height: 548,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [V2ETTokens.softShadow],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: V2ETTokens.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: V2ETTokens.h3),
                      const SizedBox(height: 2),
                      Text(countText, style: V2ETTokens.small),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFF0F0F0),
                    ),
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: V2ETTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: V2ETTokens.border),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: V2ETTokens.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateText,
                          style: const TextStyle(
                            fontSize: 13,
                            color: V2ETTokens.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      content,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.9,
                        color: V2ETTokens.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: V2ETTokens.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
              child: Row(
                children: [
                  V2ETButton(
                    label: '上一条',
                    icon: Icons.chevron_left_rounded,
                    tone: V2ETButtonTone.ghost,
                    onPressed: notices.isEmpty || index <= 0
                        ? null
                        : () => setState(() => index--),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      for (int i = 0; i < (notices.isEmpty ? 1 : notices.length.clamp(1, 6)); i++) ...[
                        Container(
                          width: i == index ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == index ? V2ETTokens.primary : const Color(0xFFD6D8DE),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 7),
                      ],
                    ],
                  ),
                  const Spacer(),
                  V2ETButton(
                    label: '下一条',
                    icon: Icons.chevron_right_rounded,
                    tone: V2ETButtonTone.soft,
                    onPressed: notices.isEmpty || index >= notices.length - 1
                        ? null
                        : () => setState(() => index++),
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
