import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/provider_tokens.dart';

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
    final showInlineError = hasCrisp && (_errorText ?? '').isNotEmpty;
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
                    onTap: () {
                      if (hasCrisp) {
                        final controller = _controller;
                        if (controller != null) {
                          setState(() {
                            _loading = true;
                            _errorText = null;
                          });
                          controller.reload();
                        }
                        return;
                      }
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
            Expanded(
              child: hasCrisp
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
                        if (showInlineError)
                          Positioned.fill(
                            child: ColoredBox(
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '客服页面加载失败',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: V2ETTokens.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _errorText!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: V2ETTokens.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    OutlinedButton(
                                      onPressed: () async {
                                        final uri = Uri.parse(
                                          'https://go.crisp.chat/chat/embed/?website_id=$crispId',
                                        );
                                        await launchUrl(
                                          uri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      },
                                      child: const Text('网页打开'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          crispId.isEmpty
                              ? '未配置 Crisp website_id'
                              : (_errorText ?? '客服页面加载失败，请点击刷新重试'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: V2ETTokens.textSecondary,
                          ),
                        ),
                      ),
                    ),
            ),
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
