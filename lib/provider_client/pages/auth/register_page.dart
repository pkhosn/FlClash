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
    required this.authBackgroundUrl,
    required this.emailSuffixes,
    required this.languageCode,
    required this.onLanguageTap,
    required this.onThemeToggle,
    required this.isDarkMode,
  });
  final VoidCallback onLogin;
  final String brandName;
  final String logoUrl;
  final String authBackgroundUrl;
  final List<String> emailSuffixes;
  final String languageCode;
  final VoidCallback onLanguageTap;
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  @override
  State<V2ETRegisterPage> createState() => _V2ETRegisterPageState();
}

class _V2ETRegisterPageState extends State<V2ETRegisterPage> {
  late String selectedSuffix;

  @override
  void initState() {
    super.initState();
    selectedSuffix = widget.emailSuffixes.isEmpty
        ? 'qq.com'
        : widget.emailSuffixes.first;
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      backgroundImage: widget.authBackgroundUrl.isNotEmpty
          ? NetworkImage(widget.authBackgroundUrl)
          : null,
      onBack: widget.onLogin,
      onSupport: () => showV2ETCustomerServiceDialog(context),
      showServicePill: false,
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
            Text('创建账户 - ${widget.brandName}', style: V2ETTokens.h1),
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
                PopupMenuButton<String>(
                  initialValue: selectedSuffix,
                  onSelected: (v) => setState(() => selectedSuffix = v),
                  itemBuilder: (context) {
                    final items = widget.emailSuffixes.isEmpty
                        ? const ['qq.com']
                        : widget.emailSuffixes;
                    return items
                        .map(
                          (e) => PopupMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList();
                  },
                  child: Container(
                  height: 40,
                  width: 138,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: V2ETTokens.input,
                    borderRadius: BorderRadius.circular(V2ETTokens.radiusM),
                    border: Border.all(color: V2ETTokens.border),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '@',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedSuffix,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded),
                    ],
                  ),
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
                  onPressed: widget.onLogin,
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

  String _languageLabel(String code) {
    final lower = code.toLowerCase();
    if (lower.startsWith('zh')) return '中';
    if (lower.startsWith('en')) return 'EN';
    return code.length <= 4 ? code.toUpperCase() : code.substring(0, 4);
  }
}
