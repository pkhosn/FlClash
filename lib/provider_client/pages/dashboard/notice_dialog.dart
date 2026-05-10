import 'package:flutter/material.dart';
import '../../theme/provider_tokens.dart';
import '../../widgets/app_button.dart';

Future<void> showV2ETNoticeDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withOpacity(0.52),
    builder: (_) => const Dialog(backgroundColor: Colors.transparent, insetPadding: EdgeInsets.all(24), child: V2ETNoticeDialog()),
  );
}

class V2ETNoticeDialog extends StatelessWidget {
  const V2ETNoticeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 520,
        height: 560,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: const [V2ETTokens.softShadow]),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
              child: Row(
                children: [
                  Container(width: 36, height: 36, decoration: BoxDecoration(color: V2ETTokens.primary, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 20)),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('重要更新通知', style: V2ETTokens.h3), SizedBox(height: 2), Text('第 1 条，共 5 条', style: V2ETTokens.small)]),
                  const Spacer(),
                  IconButton(style: IconButton.styleFrom(backgroundColor: const Color(0xFFF0F0F0)), onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: V2ETTokens.textSecondary)),
                ],
              ),
            ),
            const Divider(height: 1, color: V2ETTokens.border),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(children: [Icon(Icons.access_time_rounded, size: 16, color: V2ETTokens.textMuted), SizedBox(width: 8), Text('2026-04-03 07:58', style: TextStyle(fontSize: 13, color: V2ETTokens.textSecondary, fontWeight: FontWeight.w700))]),
                    SizedBox(height: 22),
                    Text('您好 v2et 已经上线全新客户端, Windows 和安卓 没有收到自动更新提示的, 进入官网下载 shizi.pro 自行下载更新, 如果 mac 需要更新可以联系客服发送安装包. 已更新请忽略.', style: TextStyle(fontSize: 14, height: 1.8, color: V2ETTokens.textPrimary, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, color: V2ETTokens.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  V2ETButton(label: '上一条', icon: Icons.chevron_left_rounded, tone: V2ETButtonTone.ghost, onPressed: () {}),
                  const Spacer(),
                  Row(children: [
                    Container(width: 20, height: 6, decoration: BoxDecoration(color: V2ETTokens.primary, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(width: 7),
                    for (int i = 0; i < 4; i++) ...[Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFD6D8DE), shape: BoxShape.circle)), const SizedBox(width: 7)],
                  ]),
                  const Spacer(),
                  V2ETButton(label: '下一条', icon: Icons.chevron_right_rounded, tone: V2ETButtonTone.soft, onPressed: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
