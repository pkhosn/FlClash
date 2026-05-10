import 'package:flutter/material.dart';
import '../mock/mock_provider_data.dart';
import '../theme/provider_tokens.dart';
import 'app_button.dart';
import 'app_card.dart';

class V2ETPlanCard extends StatelessWidget {
  const V2ETPlanCard({super.key, required this.plan, this.onSubscribe});
  final V2ETPlanMock plan;
  final VoidCallback? onSubscribe;

  @override
  Widget build(BuildContext context) {
    return V2ETCard(
      width: 350,
      padding: EdgeInsets.zero,
      shadow: true,
      radius: 15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Column(
              children: [
                Text('${plan.name}${plan.badge}', style: V2ETTokens.h3),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: plan.price,
                        style: const TextStyle(
                          fontSize: 31,
                          fontWeight: FontWeight.w900,
                          color: V2ETTokens.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: plan.period,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: V2ETTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 9),
                V2ETButton(
                  label: '立即订阅',
                  icon: Icons.shopping_cart_outlined,
                  height: 34,
                  width: double.infinity,
                  onPressed: onSubscribe,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: V2ETTokens.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Column(
              children: [
                Row(
                  children: [
                    _Metric(
                      icon: Icons.water_drop_outlined,
                      iconColor: Colors.black87,
                      value: plan.traffic,
                      label: '流量',
                    ),
                    const SizedBox(width: 6),
                    _Metric(
                      icon: Icons.speed_outlined,
                      iconColor: V2ETTokens.primary,
                      value: plan.speed,
                      label: '速率',
                    ),
                    const SizedBox(width: 6),
                    _Metric(
                      icon: Icons.phone_android_outlined,
                      iconColor: V2ETTokens.success,
                      value: plan.devices,
                      label: '设备',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: V2ETTokens.border),
                const SizedBox(height: 8),
                for (final note in plan.notes)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        note,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: V2ETTokens.textSecondary,
                        ),
                      ),
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

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 82,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: V2ETTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: V2ETTokens.small),
          ],
        ),
      ),
    );
  }
}
