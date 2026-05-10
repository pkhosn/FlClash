import 'package:flutter/material.dart';
import '../../theme/provider_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input.dart';
import '../../widgets/auth_background.dart';
import '../dashboard/customer_service_dialog.dart';

class V2ETLoginPage extends StatefulWidget {
  const V2ETLoginPage({
    super.key,
    required this.onLogin,
    required this.onRegister,
    required this.onResetPassword,
    required this.brandName,
    required this.logoUrl,
    required this.authBackgroundUrl,
    required this.crispWebsiteId,
  });
  final Future<void> Function(String email, String password) onLogin;
  final VoidCallback onRegister;
  final VoidCallback onResetPassword;
  final String brandName;
  final String logoUrl;
  final String authBackgroundUrl;
  final String crispWebsiteId;

  @override
  State<V2ETLoginPage> createState() => _V2ETLoginPageState();
}

class _V2ETLoginPageState extends State<V2ETLoginPage> {
  bool remember = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      backgroundImage: widget.authBackgroundUrl.isNotEmpty
          ? NetworkImage(widget.authBackgroundUrl)
          : null,
      onSupport: () => showV2ETCustomerServiceDialog(
        context,
        crispWebsiteId: widget.crispWebsiteId,
      ),
      child: AuthGlassCard(
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
            const SizedBox(height: 26),
            _buildLogo(),
            const SizedBox(height: 20),
            Text(widget.brandName, style: V2ETTokens.h1),
            const SizedBox(height: 26),
            V2ETInput(
              controller: _emailController,
              hintText: '请输入邮箱',
              prefixIcon: Icons.mail_outline_rounded,
              height: 40,
            ),
            const SizedBox(height: 12),
            V2ETInput(
              controller: _passwordController,
              hintText: '请输入密码',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: true,
              height: 40,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: Checkbox(
                    value: remember,
                    activeColor: V2ETTokens.primary,
                    side: const BorderSide(color: V2ETTokens.primary),
                    onChanged: (v) => setState(() => remember = v ?? true),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '记住我',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: V2ETTokens.textSecondary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: widget.onResetPassword,
                  child: const Text(
                    '忘记密码',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: V2ETTokens.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            V2ETButton(
              label: '登录',
              tone: V2ETButtonTone.primary,
              height: 40,
              width: double.infinity,
              radius: 10,
              onPressed: () {
                final email = _emailController.text.trim();
                final password = _passwordController.text;
                if (email.isEmpty || password.isEmpty) return;
                widget.onLogin(email, password);
              },
            ),
            const SizedBox(height: 28),
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
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '还没有账户?',
                  style: TextStyle(
                    fontSize: 13,
                    color: V2ETTokens.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: widget.onRegister,
                  child: const Text(
                    '立即注册',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: V2ETTokens.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'v1.0.2',
              style: TextStyle(
                fontSize: 12,
                color: V2ETTokens.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    if (widget.logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Image.network(
          widget.logoUrl,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackLogo(),
        ),
      );
    }
    return _fallbackLogo();
  }

  Widget _fallbackLogo() {
    return Container(
      width: 72,
      height: 72,
      decoration: const BoxDecoration(
        color: V2ETTokens.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.pets_rounded, color: Colors.white, size: 42),
    );
  }
}
