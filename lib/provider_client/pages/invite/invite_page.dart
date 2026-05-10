import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../mock/mock_provider_data.dart';
import '../../theme/provider_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';

class V2ETInvitePage extends StatelessWidget {
  const V2ETInvitePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(V2ETTokens.pagePadding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 710),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              V2ETCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [const Text('邀请链接', style: V2ETTokens.h3), const Spacer(), V2ETButton(label: '创建邀请码', icon: Icons.add_rounded, tone: V2ETButtonTone.ghost, onPressed: () {})]),
                  const SizedBox(height: 12),
                  Container(
                    height: 100,
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    decoration: BoxDecoration(color: const Color(0xFFE8F1FF), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFA6C8FF))),
                    child: Row(children: [
                      Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('邀请码 1', style: V2ETTokens.mini), SizedBox(height: 10), Text(mockInviteCode, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: V2ETTokens.primary))]),
                      const Spacer(),
                      Material(color: const Color(0xFFBFD9FA), borderRadius: BorderRadius.circular(12), child: InkWell(onTap: () => Clipboard.setData(const ClipboardData(text: mockInviteCode)), borderRadius: BorderRadius.circular(12), child: const SizedBox(width: 46, height: 46, child: Icon(Icons.copy_rounded, color: V2ETTokens.primary)))),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              V2ETCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                  Text('邀请统计', style: V2ETTokens.h3),
                  SizedBox(height: 24),
                  Row(children: [Expanded(child: _InviteMetric(icon: Icons.people_alt_rounded, value: '0', label: '总邀请数')), Expanded(child: _InviteMetric(icon: Icons.percent_rounded, value: '10.0%', label: '佣金比例')), Expanded(child: _InviteMetric(icon: Icons.monetization_on_rounded, value: '¥0.00', label: '累计佣金'))]),
                ]),
              ),
              const SizedBox(height: 14),
              V2ETCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('佣金余额', style: V2ETTokens.h3),
                  const SizedBox(height: 16),
                  Container(
                    height: 134,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: V2ETTokens.primaryDark, borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: const [Text('可用佣金', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)), SizedBox(height: 14), Text('¥0.00', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900)), SizedBox(height: 8), Text('可划转到余额', style: TextStyle(color: Colors.white, fontSize: 13))]),
                      const Spacer(),
                      V2ETButton(label: '划转到余额', icon: Icons.account_balance_wallet_rounded, tone: V2ETButtonTone.soft, onPressed: () {}),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 14),
              V2ETCard(height: 150, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('佣金历史', style: V2ETTokens.h3), const Spacer(), Center(child: Icon(Icons.history_rounded, size: 46, color: Colors.grey.shade300)), const Spacer()])),
            ],
          ),
        ),
      ),
    );
  }
}

class _InviteMetric extends StatelessWidget {
  const _InviteMetric({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(children: [Icon(icon, color: V2ETTokens.primary, size: 30), const SizedBox(height: 12), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: V2ETTokens.textPrimary)), const SizedBox(height: 8), Text(label, style: V2ETTokens.small)]);
}
