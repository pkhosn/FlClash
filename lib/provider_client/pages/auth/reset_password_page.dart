import 'package:flutter/material.dart';
import '../../theme/provider_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input.dart';
import '../../widgets/auth_background.dart';
import '../dashboard/customer_service_dialog.dart';

class V2ETResetPasswordPage extends StatefulWidget {
  const V2ETResetPasswordPage({
    super.key,
    required this.onLogin,
    required this.authBackgroundUrl,
    required this.crispWebsiteId,
    required this.languageCode,
    required this.onLanguageTap,
    required this.onThemeToggle,
    required this.isDarkMode,
    required this.serviceOk,
    required this.onServiceTap,
    required this.onSendVerifyCode,
  });
  final VoidCallback onLogin;
  final String authBackgroundUrl;
  final String crispWebsiteId;
  final String languageCode;
  final VoidCallback onLanguageTap;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  final bool serviceOk;
  final VoidCallback onServiceTap;
  final Future<void> Function(String email, bool isForgetPassword) onSendVerifyCode;

  @override
  State<V2ETResetPasswordPage> createState() => _V2ETResetPasswordPageState();
}

class _V2ETResetPasswordPageState extends State<V2ETResetPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      backgroundImage: widget.authBackgroundUrl.isNotEmpty
          ? NetworkImage(widget.authBackgroundUrl)
          : null,
      onBack: widget.onLogin,
      onSupport: () => showV2ETCustomerServiceDialog(
        context,
        crispWebsiteId: widget.crispWebsiteId,
      ),
      serviceOk: widget.serviceOk,
      onServiceTap: widget.onServiceTap,
      showServicePill: true,
      child: AuthGlassCard(
        width: 445,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AuthToolButton(
                  onTap: widget.onThemeToggle,
                  child: Icon(
                    widget.isDarkMode
                        ? Icons.nightlight_round
                        : Icons.wb_sunny_outlined,
                    color: V2ETTokens.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                AuthToolButton(
                  onTap: widget.onLanguageTap,
                  child: Text(
                    _languageLabel(widget.languageCode),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: V2ETTokens.textPrimary,
                    ),
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
            V2ETInput(
              controller: _emailController,
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
              onPressed: () async {
                final email = _emailController.text.trim();
                if (email.isEmpty) return;
                await widget.onSendVerifyCode(email, true);
              },
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
                  onPressed: widget.onLogin,
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

  String _languageLabel(String code) {
    final lower = code.toLowerCase();
    if (lower.startsWith('zh')) return '中';
    if (lower.startsWith('en')) return 'EN';
    return code.length <= 4 ? code.toUpperCase() : code.substring(0, 4);
  }
}
