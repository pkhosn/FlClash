import 'package:flutter/material.dart';
import '../../theme/provider_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input.dart';
import '../../widgets/auth_background.dart';
import '../dashboard/customer_service_dialog.dart';

class V2ETResetPasswordPage extends StatelessWidget {
  const V2ETResetPasswordPage({
    super.key,
    required this.onLogin,
    required this.authBackgroundUrl,
    required this.crispWebsiteId,
  });
  final VoidCallback onLogin;
  final String authBackgroundUrl;
  final String crispWebsiteId;

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      backgroundImage: authBackgroundUrl.isNotEmpty
          ? NetworkImage(authBackgroundUrl)
          : null,
      onBack: onLogin,
      onSupport: () => showV2ETCustomerServiceDialog(
        context,
        crispWebsiteId: crispWebsiteId,
      ),
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
            const SizedBox(height: 24),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: V2ETTokens.textPrimary,
                size: 34,
              ),
            ),
            const SizedBox(height: 24),
            const Text('重置密码', style: V2ETTokens.h1),
            const SizedBox(height: 26),
            const Text(
              '请输入您的邮箱地址，我们会发送验证码到您的邮箱',
              textAlign: TextAlign.center,
              style: V2ETTokens.small,
            ),
            const SizedBox(height: 26),
            const V2ETInput(
              hintText: '请输入邮箱地址',
              prefixIcon: Icons.mail_outline_rounded,
              height: 40,
            ),
            const SizedBox(height: 20),
            V2ETButton(
              label: '发送验证码',
              tone: V2ETButtonTone.dark,
              height: 42,
              width: double.infinity,
              onPressed: () {},
            ),
            const SizedBox(height: 26),
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
                  '记起密码了?',
                  style: TextStyle(
                    fontSize: 13,
                    color: V2ETTokens.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: onLogin,
                  child: const Text(
                    '返回登录',
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
