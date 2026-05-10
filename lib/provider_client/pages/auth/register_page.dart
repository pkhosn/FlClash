import 'package:flutter/material.dart';
import '../../theme/provider_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input.dart';
import '../../widgets/auth_background.dart';
import '../dashboard/customer_service_dialog.dart';

class V2ETRegisterPage extends StatelessWidget {
  const V2ETRegisterPage({
    super.key,
    required this.onLogin,
    required this.brandName,
    required this.logoUrl,
    required this.authBackgroundUrl,
  });
  final VoidCallback onLogin;
  final String brandName;
  final String logoUrl;
  final String authBackgroundUrl;

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      backgroundImage: authBackgroundUrl.isNotEmpty
          ? NetworkImage(authBackgroundUrl)
          : null,
      onBack: onLogin,
      onSupport: () => showV2ETCustomerServiceDialog(context),
      showServicePill: false,
      child: AuthGlassCard(
        width: 445,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                AuthToolButton(
                  child: Icon(
                    Icons.wb_sunny_outlined,
                    color: V2ETTokens.textPrimary,
                  ),
                ),
                SizedBox(width: 8),
                AuthToolButton(
                  child: Text(
                    '中',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person_add_alt_1_rounded,
                color: V2ETTokens.textPrimary,
                size: 34,
              ),
            ),
            const SizedBox(height: 22),
            Text('创建账户 - $brandName', style: V2ETTokens.h1),
            const SizedBox(height: 8),
            const Text('填写以下信息完成注册', style: V2ETTokens.small),
            const SizedBox(height: 26),
            Row(
              children: [
                const Expanded(
                  child: V2ETInput(
                    hintText: '邮箱用户名',
                    prefixIcon: Icons.mail_outline_rounded,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 40,
                  width: 138,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: V2ETTokens.input,
                    borderRadius: BorderRadius.circular(V2ETTokens.radiusM),
                    border: Border.all(color: V2ETTokens.border),
                  ),
                  child: const Row(
                    children: [
                      Text('@', style: TextStyle(fontWeight: FontWeight.w800)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'qq.com',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const V2ETInput(
              hintText: '请输入密码',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: true,
              height: 40,
            ),
            const SizedBox(height: 12),
            const V2ETInput(
              hintText: '请再次输入密码',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: true,
              height: 40,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: V2ETInput(
                    hintText: '请输入6位验证码',
                    prefixIcon: Icons.verified_outlined,
                    height: 40,
                  ),
                ),
                const SizedBox(width: 10),
                V2ETButton(
                  label: '发送',
                  tone: V2ETButtonTone.dark,
                  width: 62,
                  height: 40,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 12),
            const V2ETInput(
              hintText: '请输入邀请码',
              prefixIcon: Icons.card_giftcard_rounded,
              height: 40,
            ),
            const SizedBox(height: 20),
            V2ETButton(
              label: '注册',
              tone: V2ETButtonTone.dark,
              height: 40,
              width: double.infinity,
              onPressed: () {},
            ),
            const SizedBox(height: 24),
            Row(
              children: const [
                Expanded(child: Divider(color: V2ETTokens.border)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('或', style: V2ETTokens.small),
                ),
                Expanded(child: Divider(color: V2ETTokens.border)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '已有账户?',
                  style: TextStyle(
                    fontSize: 13,
                    color: V2ETTokens.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: onLogin,
                  child: const Text(
                    '立即登录',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: V2ETTokens.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
