import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_clash/v2et_bridge/v2et_bridge_provider.dart';
import '../../data/v2et_runtime_providers.dart';
import '../../theme/provider_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_notice.dart';

class V2ETProfileCenterPage extends ConsumerWidget {
  const V2ETProfileCenterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subAsync = ref.watch(v2etSubscriptionProvider);
    final userAsync = ref.watch(v2etUserInfoProvider);
    final sub = subAsync.when(
      data: (data) => data,
      loading: () => null,
      error: (_, _) => null,
    );
    final user = userAsync.when(
      data: (data) => data,
      loading: () => null,
      error: (_, _) => null,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              _AccountHeroCard(
                email: user?.email ?? '--',
                planName: sub?.planName ?? user?.planName ?? '--',
                balance: user?.balance ?? 0,
                commission: user?.commissionBalance ?? 0,
              ),
              const SizedBox(height: 18),
              _SecurityCard(
                onChangePassword: (oldPassword, newPassword) async {
                  await ref
                      .read(v2etBridgeProvider)
                      .changePassword(
                        oldPassword: oldPassword,
                        newPassword: newPassword,
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountHeroCard extends StatelessWidget {
  const _AccountHeroCard({
    required this.email,
    required this.planName,
    required this.balance,
    required this.commission,
  });
  final String email;
  final String planName;
  final double balance;
  final double commission;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4D8DF7),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [V2ETTokens.softShadow],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -6,
            top: -10,
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -10,
            bottom: 8,
            child: Icon(
              Icons.person_rounded,
              size: 138,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFBFD8FF), width: 4),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: V2ETTokens.primary,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
              children: [
                Expanded(
                  child: _HeroMetric(
                    icon: Icons.verified_rounded,
                    label: '套餐',
                    value: planName,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _HeroMetric(
                    icon: Icons.account_balance_wallet_rounded,
                    label: '余额',
                    value: '¥${balance.toStringAsFixed(2)}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _HeroMetric(
                    icon: Icons.savings_rounded,
                    label: '佣金',
                    value: '¥${commission.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
            ],
          )
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: Colors.white70),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard({required this.onChangePassword});
  final Future<void> Function(String oldPassword, String newPassword)
  onChangePassword;
  @override
  Widget build(BuildContext context) {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    return V2ETCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: V2ETTokens.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: V2ETTokens.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('账户与安全', style: V2ETTokens.h3),
                    SizedBox(height: 4),
                    Text('管理密码与安全设置', style: V2ETTokens.small),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: V2ETTokens.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.history_rounded,
                      color: V2ETTokens.textSecondary,
                    ),
                    SizedBox(width: 14),
                    Text(
                      '修改登录密码',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: V2ETTokens.textSecondary,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                V2ETInput(
                  controller: oldController,
                  hintText: '当前密码',
                  prefixIcon: Icons.lock_outline_rounded,
                  suffix: Icon(
                    Icons.visibility_off_outlined,
                    color: V2ETTokens.textMuted,
                  ),
                  height: 46,
                ),
                const SizedBox(height: 12),
                V2ETInput(
                  controller: newController,
                  hintText: '新密码',
                  prefixIcon: Icons.lock_outline_rounded,
                  suffix: Icon(
                    Icons.visibility_off_outlined,
                    color: V2ETTokens.textMuted,
                  ),
                  height: 46,
                ),
                const SizedBox(height: 12),
                V2ETInput(
                  controller: confirmController,
                  hintText: '确认密码',
                  prefixIcon: Icons.lock_outline_rounded,
                  suffix: Icon(
                    Icons.visibility_off_outlined,
                    color: V2ETTokens.textMuted,
                  ),
                  height: 46,
                ),
                const SizedBox(height: 24),
                V2ETButton(
                  label: '确认修改',
                  height: 54,
                  width: double.infinity,
                  radius: 14,
                  onPressed: () async {
                    final oldPassword = oldController.text;
                    final newPassword = newController.text;
                    final confirmPassword = confirmController.text;
                    if (oldPassword.isEmpty || newPassword.isEmpty) {
                      V2ETNotice.error(context, '请完整填写密码');
                      return;
                    }
                    if (newPassword != confirmPassword) {
                      V2ETNotice.error(context, '两次新密码不一致');
                      return;
                    }
                    try {
                      await onChangePassword(oldPassword, newPassword);
                      if (!context.mounted) return;
                      V2ETNotice.success(context, '密码修改成功');
                    } catch (e) {
                      if (!context.mounted) return;
                      V2ETNotice.error(context, '修改失败: $e');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
