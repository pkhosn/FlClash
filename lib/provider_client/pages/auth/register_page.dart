import 'package:flutter/material.dart';
import '../../theme/provider_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_input.dart';
import '../../widgets/auth_background.dart';
import '../dashboard/customer_service_dialog.dart';

class V2ETRegisterPage extends StatefulWidget {
  const V2ETRegisterPage({
    super.key,
    required this.onLogin,
    required this.brandName,
    required this.logoUrl,
    required this.crispWebsiteId,
    required this.authBackgroundUrl,
    required this.emailSuffixes,
    required this.whitelistEnabled,
    required this.requireEmailVerify,
    required this.requireInviteCode,
    required this.languageCode,
    required this.onLanguageTap,
    required this.onThemeToggle,
    required this.isDarkMode,
    required this.serviceOk,
    required this.onServiceTap,
    required this.onSendVerifyCode,
    required this.onSubmitRegister,
  });
  final VoidCallback onLogin;
  final String brandName;
  final String logoUrl;
  final String crispWebsiteId;
  final String authBackgroundUrl;
  final List<String> emailSuffixes;
  final bool whitelistEnabled;
  final bool requireEmailVerify;
  final bool requireInviteCode;
  final String languageCode;
  final VoidCallback onLanguageTap;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;
  final bool serviceOk;
  final VoidCallback onServiceTap;
  final Future<void> Function(String email, bool isForgetPassword) onSendVerifyCode;
  final Future<void> Function({
    required String email,
    required String password,
    required String confirmPassword,
    required String emailCode,
    required String inviteCode,
  })
  onSubmitRegister;

  @override
  State<V2ETRegisterPage> createState() => _V2ETRegisterPageState();
}

class _V2ETRegisterPageState extends State<V2ETRegisterPage> {
  late String selectedSuffix;
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _codeController = TextEditingController();
  final _inviteController = TextEditingController();
  bool _submitting = false;
  bool _sendingCode = false;
  final _supportButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    selectedSuffix = widget.emailSuffixes.isEmpty
        ? 'qq.com'
        : widget.emailSuffixes.first;
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _codeController.dispose();
    _inviteController.dispose();
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
      onBack: widget.onLogin,
      onSupport: () => showV2ETCustomerServiceDialog(
        context,
        crispWebsiteId: widget.crispWebsiteId,
        anchorRect: _anchorRect(),
      ),
      serviceOk: widget.serviceOk,
      onServiceTap: widget.onServiceTap,
      showServicePill: true,
      supportButtonKey: _supportButtonKey,
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
                color: Colors.black87,
                size: 34,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              isEn ? 'Create Account - ${widget.brandName}' : '创建账户 - ${widget.brandName}',
              style: V2ETTokens.h1,
            ),
            const SizedBox(height: 8),
            Text(
              isEn ? 'Fill in details to continue' : '填写以下信息完成注册',
              style: V2ETTokens.small,
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: widget.whitelistEnabled
                      ? V2ETInput(
                          controller: _userController,
                          hintText: isEn ? 'Email username' : '邮箱用户名',
                          prefixIcon: Icons.mail_outline_rounded,
                          height: 40,
                        )
                      : V2ETInput(
                          controller: _userController,
                          hintText: isEn ? 'Email address' : '请输入完整邮箱',
                          prefixIcon: Icons.mail_outline_rounded,
                          height: 40,
                        ),
                ),
                if (widget.whitelistEnabled) ...[
                  const SizedBox(width: 8),
                  _EmailSuffixMenu(
                    selected: selectedSuffix,
                    items: widget.emailSuffixes,
                    isDark: isDark,
                    onSelected: (v) => setState(() => selectedSuffix = v),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            V2ETInput(
              controller: _passwordController,
              hintText: isEn ? 'Enter password' : '请输入密码',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: true,
              height: 40,
            ),
            const SizedBox(height: 12),
            V2ETInput(
              controller: _confirmController,
              hintText: isEn ? 'Confirm password' : '请再次输入密码',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: true,
              height: 40,
            ),
            const SizedBox(height: 12),
            if (widget.requireEmailVerify) ...[
              Row(
                children: [
                  Expanded(
                    child: V2ETInput(
                      controller: _codeController,
                      hintText: isEn ? '6-digit email code' : '请输入6位验证码',
                      prefixIcon: Icons.verified_outlined,
                      height: 40,
                    ),
                  ),
                  const SizedBox(width: 10),
                  V2ETButton(
                    label: _sendingCode ? (isEn ? 'Sending' : '发送中') : (isEn ? 'Send' : '发送'),
                    tone: V2ETButtonTone.dark,
                    width: 62,
                    height: 40,
                    onPressed: _sendingCode
                        ? null
                        : () async {
                            final email = _buildEmail();
                            if (email == null) return;
                            setState(() => _sendingCode = true);
                            try {
                              await widget.onSendVerifyCode(email, false);
                            } finally {
                              if (mounted) {
                                setState(() => _sendingCode = false);
                              }
                            }
                          },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            V2ETInput(
              controller: _inviteController,
              hintText: widget.requireInviteCode
                  ? (isEn ? 'Invite code (required)' : '邀请码（必填）')
                  : (isEn ? 'Invite code (optional)' : '请输入邀请码'),
              prefixIcon: Icons.card_giftcard_rounded,
              height: 40,
            ),
            const SizedBox(height: 20),
            V2ETButton(
              label: _submitting ? (isEn ? 'Submitting' : '提交中') : (isEn ? 'Register' : '注册'),
              tone: V2ETButtonTone.dark,
              height: 40,
              width: double.infinity,
              onPressed: _submitting
                  ? null
                  : () async {
                      final email = _buildEmail();
                      if (email == null) return;
                      setState(() => _submitting = true);
                      try {
                        await widget.onSubmitRegister(
                          email: email,
                          password: _passwordController.text,
                          confirmPassword: _confirmController.text,
                          emailCode: _codeController.text.trim(),
                          inviteCode: _inviteController.text.trim(),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => _submitting = false);
                        }
                      }
                    },
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isEn ? 'Already have an account?' : '已有账户?',
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: widget.onLogin,
                  child: Text(
                    isEn ? 'Login Now' : '立即登录',
                    style: const TextStyle(
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

  String? _buildEmail() {
    final user = _userController.text.trim();
    if (user.isEmpty) return null;
    if (!widget.whitelistEnabled) return user;
    return '$user@$selectedSuffix';
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

class _EmailSuffixMenu extends StatelessWidget {
  const _EmailSuffixMenu({
    required this.selected,
    required this.items,
    required this.onSelected,
    required this.isDark,
  });

  final String selected;
  final List<String> items;
  final ValueChanged<String> onSelected;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: selected,
      color: isDark ? const Color(0xFF1F2B3C) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      constraints: const BoxConstraints(minWidth: 168, maxWidth: 220),
      elevation: 10,
      onSelected: onSelected,
      itemBuilder: (context) {
        return items
            .map(
              (e) => PopupMenuItem<String>(
                value: e,
                child: Container(
                  height: 36,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '@$e',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isDark ? V2ETTokens.darkTextPrimary : V2ETTokens.textPrimary,
                    ),
                  ),
                ),
              ),
            )
            .toList();
      },
      child: Container(
                  height: 40,
                  width: 138,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? V2ETTokens.darkInput : V2ETTokens.input,
                    borderRadius: BorderRadius.circular(V2ETTokens.radiusM),
                    border: Border.all(
                      color: isDark ? V2ETTokens.darkBorder : V2ETTokens.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '@',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: isDark ? V2ETTokens.darkTextSecondary : V2ETTokens.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selected,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: isDark ? V2ETTokens.darkTextPrimary : V2ETTokens.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark ? V2ETTokens.darkTextSecondary : V2ETTokens.textSecondary,
                      ),
                    ],
                  ),
                ),
    );
  }
}
