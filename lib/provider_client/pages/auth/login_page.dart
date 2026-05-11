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
    required this.versionText,
    required this.languageCode,
    required this.onLanguageTap,
    required this.onThemeToggle,
    required this.isDarkMode,
    required this.serviceOk,
    required this.onServiceTap,
    this.initialEmail = '',
    this.initialPassword = '',
    this.initialRemember = false,
  });
  final Future<void> Function(String email, String password, bool remember)
  onLogin;
  final VoidCallback onRegister;
  final VoidCallback onResetPassword;
  final String brandName;
  final String logoUrl;
  final String authBackgroundUrl;
  final String crispWebsiteId;
  final String versionText;
  final String languageCode;
  final VoidCallback onLanguageTap;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  final bool serviceOk;
  final VoidCallback onServiceTap;
  final String initialEmail;
  final String initialPassword;
  final bool initialRemember;

  @override
  State<V2ETLoginPage> createState() => _V2ETLoginPageState();
}

class _V2ETLoginPageState extends State<V2ETLoginPage> {
  bool remember = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supportButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    remember = widget.initialRemember;
    _emailController.text = widget.initialEmail;
    _passwordController.text = widget.initialPassword;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEn = widget.languageCode.toLowerCase().startsWith('en');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? V2ETTokens.darkTextPrimary : V2ETTokens.textPrimary;
    final textSecondary = isDark ? V2ETTokens.darkTextSecondary : V2ETTokens.textSecondary;
    final dividerColor = isDark ? V2ETTokens.darkBorder : V2ETTokens.border;
    return AuthBackground(
      backgroundImage: widget.authBackgroundUrl.isNotEmpty
          ? NetworkImage(widget.authBackgroundUrl)
          : null,
      onSupport: () => showV2ETCustomerServiceDialog(
        context,
        crispWebsiteId: widget.crispWebsiteId,
        supportUrl: '',
        anchorRect: _anchorRect(),
      ),
      serviceOk: widget.serviceOk,
      onServiceTap: widget.onServiceTap,
      supportButtonKey: _supportButtonKey,
      child: AuthGlassCard(
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
                    color: textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                AuthToolButton(
                  onTap: widget.onLanguageTap,
                  child: Text(
                    _languageLabel(widget.languageCode),
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: textPrimary,
                    ),
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
              hintText: isEn ? 'Enter email' : '请输入邮箱',
              prefixIcon: Icons.mail_outline_rounded,
              height: 40,
            ),
            const SizedBox(height: 12),
            V2ETInput(
              controller: _passwordController,
              hintText: isEn ? 'Enter password' : '请输入密码',
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
                Text(
                  isEn ? 'Remember me' : '记住我',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: widget.onResetPassword,
                  child: Text(
                    isEn ? 'Forgot Password' : '忘记密码',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            V2ETButton(
              label: isEn ? 'Login' : '登录',
              tone: V2ETButtonTone.primary,
              height: 40,
              width: double.infinity,
              radius: 10,
              onPressed: () {
                final email = _emailController.text.trim();
                final password = _passwordController.text;
                if (email.isEmpty || password.isEmpty) return;
                widget.onLogin(email, password, remember);
              },
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(child: Divider(color: dividerColor)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('或', style: V2ETTokens.small),
                ),
                Expanded(child: Divider(color: dividerColor)),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isEn ? 'No account yet?' : '还没有账户?',
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: widget.onRegister,
                  child: Text(
                    isEn ? 'Register Now' : '立即注册',
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
            Text(
              widget.versionText,
              style: const TextStyle(
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
          errorBuilder: (context, error, stackTrace) => _fallbackLogo(),
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

  String _languageLabel(String code) {
    final lower = code.toLowerCase();
    if (lower.startsWith('zh')) return '中';
    if (lower.startsWith('en')) return 'EN';
    return code.length <= 4 ? code.toUpperCase() : code.substring(0, 4);
  }

  Rect? _anchorRect() {
    final currentContext = _supportButtonKey.currentContext;
    if (currentContext == null) return null;
    final box = currentContext.findRenderObject();
    if (box is! RenderBox) return null;
    final offset = box.localToGlobal(Offset.zero);
    return offset & box.size;
  }
}
