import 'package:flutter/material.dart';
import '../../mock/mock_provider_data.dart';
import '../../theme/provider_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_input.dart';

class V2ETConnectionStatusPage extends StatelessWidget {
  const V2ETConnectionStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(V2ETTokens.pagePadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              Row(children: [const Expanded(child: V2ETInput(hintText: '搜索连接...', prefixIcon: Icons.search_rounded, height: 44)), const SizedBox(width: 12), V2ETButton(label: '10', tone: V2ETButtonTone.soft, width: 44, height: 40, onPressed: () {}), const SizedBox(width: 8), IconButton(onPressed: () {}, icon: const Icon(Icons.cleaning_services_rounded, color: V2ETTokens.textSecondary))]),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [V2ETSegmentButton(label: '时间 ↓', selected: true, onTap: () {}), const SizedBox(width: 8), V2ETSegmentButton(label: '上传流量', selected: false, onTap: () {}), const SizedBox(width: 8), V2ETSegmentButton(label: '下载流量', selected: false, onTap: () {}), const SizedBox(width: 8), V2ETSegmentButton(label: '上传速度', selected: false, onTap: () {}), const SizedBox(width: 8), V2ETSegmentButton(label: '下载速度', selected: false, onTap: () {})]),
              const SizedBox(height: 16),
              for (final item in mockConnections) ...[_ConnectionCard(item: item), const SizedBox(height: 10)],
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  const _ConnectionCard({required this.item});
  final V2ETConnectionMock item;

  @override
  Widget build(BuildContext context) {
    return V2ETCard(
      padding: const EdgeInsets.all(14),
      radius: 12,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFDFF5F1), borderRadius: BorderRadius.circular(5)), child: const Text('TCP', style: TextStyle(fontSize: 11, color: Color(0xFF088C79), fontWeight: FontWeight.w900))), const SizedBox(width: 10), Expanded(child: Text(item.host, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: V2ETTokens.textPrimary))), IconButton(onPressed: () {}, icon: const Icon(Icons.close_rounded, color: V2ETTokens.textSecondary))]),
        Text(item.time, style: V2ETTokens.small),
        const SizedBox(height: 10),
        Row(children: [for (final c in item.chain) Padding(padding: const EdgeInsets.only(right: 6), child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: c == 'DIRECT' ? const Color(0xFFE2F8E7) : V2ETTokens.primarySoft, borderRadius: BorderRadius.circular(6)), child: Text(c, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: c == 'DIRECT' ? const Color(0xFF2DA44E) : V2ETTokens.primary)))), const Spacer(), Text('↑ ${item.up}', style: const TextStyle(fontSize: 11, color: V2ETTokens.success, fontWeight: FontWeight.w700)), const SizedBox(width: 10), Text('↓ ${item.down}', style: const TextStyle(fontSize: 11, color: V2ETTokens.primary, fontWeight: FontWeight.w700))]),
      ]),
    );
  }
}
