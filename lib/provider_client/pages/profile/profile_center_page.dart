import 'package:flutter/material.dart';
import '../../mock/mock_provider_data.dart';
import '../../theme/provider_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_input.dart';

class V2ETProfileCenterPage extends StatelessWidget {
  const V2ETProfileCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: const [
              _AccountHeroCard(),
              SizedBox(height: 18),
              _SecurityCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountHeroCard extends StatelessWidget {
  const _AccountHeroCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 156,
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
              const Text(
                mockEmail,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Positioned(
            left: 68,
            right: 0,
            bottom: 2,
            child: Row(
              children: const [
                Expanded(
                  child: _HeroMetric(
                    icon: Icons.verified_rounded,
                    label: '套餐',
                    value: mockPlanName,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _HeroMetric(
                    icon: Icons.account_balance_wallet_rounded,
                    label: '余额',
                    value: '¥0.00',
                    chip: '充值',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _HeroMetric(
                    icon: Icons.savings_rounded,
                    label: '佣金',
                    value: '¥0.00',
                  ),
                ),
              ],
            ),
          ),
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
    this.chip,
  });
  final IconData icon;
  final String label;
  final String value;
  final String? chip;
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
            if (chip != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  chip!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard();
  @override
  Widget build(BuildContext context) {
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
                const V2ETInput(
                  hintText: '当前密码',
                  prefixIcon: Icons.lock_outline_rounded,
                  suffix: Icon(
                    Icons.visibility_off_outlined,
                    color: V2ETTokens.textMuted,
                  ),
                  height: 46,
                ),
                const SizedBox(height: 12),
                const V2ETInput(
                  hintText: '新密码',
                  prefixIcon: Icons.lock_outline_rounded,
                  suffix: Icon(
                    Icons.visibility_off_outlined,
                    color: V2ETTokens.textMuted,
                  ),
                  height: 46,
                ),
                const SizedBox(height: 12),
                const V2ETInput(
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
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
