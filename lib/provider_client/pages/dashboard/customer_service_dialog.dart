import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';
import '../../theme/provider_tokens.dart';
import '../../widgets/app_input.dart';

Future<void> showV2ETCustomerServiceDialog(
  BuildContext context, {
  String crispWebsiteId = '',
  Rect? anchorRect,
}) {
  final media = MediaQuery.of(context).size;
  const popupWidth = 380.0;
  const popupHeight = 518.0;
  const gap = 12.0;
  const margin = 16.0;
  final defaultLeft = media.width - popupWidth - 24;
  final defaultTop =
      ((media.height - popupHeight) / 2).clamp(12, media.height - popupHeight - 12).toDouble();
  double left = defaultLeft;
  double top = defaultTop;

  if (anchorRect != null) {
    left =
        (anchorRect.right - popupWidth).clamp(margin, media.width - popupWidth - margin).toDouble();
    top = (anchorRect.top - popupHeight - gap)
        .clamp(margin, media.height - popupHeight - margin)
        .toDouble();
    final canShowAbove = anchorRect.top - popupHeight - gap >= margin;
    if (!canShowAbove) {
      top = (anchorRect.bottom + gap).clamp(margin, media.height - popupHeight - margin).toDouble();
    }
  }

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'customer-service',
    barrierColor: Colors.black.withValues(alpha: 0.38),
    transitionDuration: const Duration(milliseconds: 140),
    pageBuilder: (context, animation, secondaryAnimation) => Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned(
            left: left,
            top: top,
            width: popupWidth,
            height: popupHeight,
            child: V2ETCustomerServiceDialog(crispWebsiteId: crispWebsiteId),
          ),
        ],
      ),
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );
}

class V2ETCustomerServiceDialog extends StatefulWidget {
  const V2ETCustomerServiceDialog({super.key, this.crispWebsiteId = ''});

  final String crispWebsiteId;

  @override
  State<V2ETCustomerServiceDialog> createState() =>
      _V2ETCustomerServiceDialogState();
}

class _V2ETCustomerServiceDialogState extends State<V2ETCustomerServiceDialog> {
  WebViewController? _controller;
  bool _loading = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final crispId = widget.crispWebsiteId.trim();
    if (crispId.isEmpty) return;
    try {
      // WebView on some desktop environments may fail at runtime.
      // Keep dialog stable by falling back to external open when needed.
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) setState(() => _loading = false);
            },
            onWebResourceError: (error) {
              if (mounted) {
                setState(() {
                  _loading = false;
                  _errorText = error.description;
                });
              }
            },
          ),
        )
        ..loadRequest(
          Uri.parse('https://go.crisp.chat/chat/embed/?website_id=$crispId'),
        );
    } catch (e) {
      _errorText = '$e';
      _controller = null;
      _loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final crispId = widget.crispWebsiteId.trim();
    final hasCrisp = crispId.isNotEmpty && _controller != null;
    final isDesktop =
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [V2ETTokens.softShadow],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              color: V2ETTokens.primary,
              child: Row(
                children: [
                  const Icon(Icons.support_agent_rounded, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text(
                    '在线客服',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  _TopAction(
                    icon: Icons.refresh_rounded,
                    onTap: () async {
                      if (hasCrisp) {
                        setState(() => _loading = true);
                        _controller!.reload();
                        return;
                      }
                      if (crispId.isEmpty) return;
                      final uri = Uri.parse(
                        'https://go.crisp.chat/chat/embed/?website_id=$crispId',
                      );
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                  ),
                  const SizedBox(width: 8),
                  _TopAction(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            if (!hasCrisp || isDesktop)
              Container(
                height: 168,
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE92724), Color(0xFFF53227)],
                  ),
                ),
                child: Center(
                  child: Text(
                    crispId.isEmpty ? '未配置 Crisp website_id' : '客服加载受限，已切换安全模式',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: hasCrisp && !isDesktop
                  ? Stack(
                      children: [
                        Positioned.fill(child: WebViewWidget(controller: _controller!)),
                        if (_loading)
                          const Positioned.fill(
                            child: ColoredBox(
                              color: Colors.white,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: V2ETTokens.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.pets_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: V2ETTokens.cardSoft,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text(
                                  '可点击右上角刷新按钮，外部打开客服窗口',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if ((_errorText ?? '').isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              _errorText!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: V2ETTokens.textMuted,
                              ),
                            ),
                          ],
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: V2ETTokens.border),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                const V2ETInput(hintText: '输入你的信息...', height: 38),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.emoji_emotions_outlined,
                                      color: V2ETTokens.textSecondary,
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(
                                      Icons.attach_file_rounded,
                                      color: V2ETTokens.textSecondary,
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.send_rounded,
                                      color: V2ETTokens.textMuted.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                hasCrisp
                    ? '我们运行于  💬 crisp · $crispId'
                    : '我们运行于  💬 crisp',
                style: V2ETTokens.small.copyWith(
                  color: V2ETTokens.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
  }
}

class _TopAction extends StatelessWidget {
  const _TopAction({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.20),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(icon, color: Colors.white, size: 17),
        ),
      ),
    );
  }
}
