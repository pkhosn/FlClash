import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../theme/provider_tokens.dart';

bool isSupportedSupportUri(Uri? uri) {
  if (uri == null || !uri.hasScheme) return false;
  final scheme = uri.scheme.toLowerCase();
  return scheme == 'http' || scheme == 'https';
}

Future<void> showV2ETCustomerServiceDialog(
  BuildContext context, {
  String crispWebsiteId = '',
  String supportUrl = '',
  Rect? anchorRect,
}) {
  final media = MediaQuery.of(context).size;
  const popupWidth = 380.0;
  const popupHeight = 518.0;
  const gap = 12.0;
  const margin = 16.0;
  final defaultLeft = media.width - popupWidth - 24;
  final defaultTop = ((media.height - popupHeight) / 2)
      .clamp(12, media.height - popupHeight - 12)
      .toDouble();
  double left = defaultLeft;
  double top = defaultTop;

  if (anchorRect != null) {
    left = (anchorRect.right - popupWidth)
        .clamp(margin, media.width - popupWidth - margin)
        .toDouble();
    top = (anchorRect.top - popupHeight - gap)
        .clamp(margin, media.height - popupHeight - margin)
        .toDouble();
    final canShowAbove = anchorRect.top - popupHeight - gap >= margin;
    if (!canShowAbove) {
      top = (anchorRect.bottom + gap)
          .clamp(margin, media.height - popupHeight - margin)
          .toDouble();
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
            child: V2ETCustomerServiceDialog(
              crispWebsiteId: crispWebsiteId,
              supportUrl: supportUrl,
            ),
          ),
        ],
      ),
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) =>
        FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
  );
}

class V2ETCustomerServiceDialog extends StatefulWidget {
  const V2ETCustomerServiceDialog({
    super.key,
    this.crispWebsiteId = '',
    this.supportUrl = '',
  });

  final String crispWebsiteId;
  final String supportUrl;

  @override
  State<V2ETCustomerServiceDialog> createState() =>
      _V2ETCustomerServiceDialogState();
}

class _V2ETCustomerServiceDialogState extends State<V2ETCustomerServiceDialog> {
  WebViewController? _controller;
  List<Uri> _candidateUris = const [];
  int _candidateIndex = 0;
  bool _loading = true;
  String? _errorText;
  bool _webviewUnavailable = false;

  @override
  void initState() {
    super.initState();
    _candidateUris = _buildCandidates();
    if (_candidateUris.isEmpty) {
      _loading = false;
      _errorText = '暂无客服信息';
      return;
    }
    _createControllerAndLoad();
  }

  List<Uri> _buildCandidates() {
    final out = <Uri>[];
    final support = widget.supportUrl.trim();
    final crispId = widget.crispWebsiteId.trim();
    if (support.isNotEmpty) {
      final u = Uri.tryParse(support);
      if (u != null && isSupportedSupportUri(u)) out.add(u);
    }
    if (crispId.isNotEmpty) {
      final embed =
          Uri.tryParse('https://go.crisp.chat/chat/embed/?website_id=$crispId');
      final chatBox = Uri.tryParse('https://go.crisp.chat/chatbox/$crispId/');
      if (embed != null && isSupportedSupportUri(embed)) out.add(embed);
      if (chatBox != null && isSupportedSupportUri(chatBox)) out.add(chatBox);
    }
    return out;
  }

  void _createControllerAndLoad() {
    if (_candidateUris.isEmpty || _candidateIndex >= _candidateUris.length) {
      setState(() {
        _loading = false;
        _controller = null;
        _webviewUnavailable = false;
        _errorText = '暂无客服信息';
      });
      return;
    }
    final target = _candidateUris[_candidateIndex];
    if (!isSupportedSupportUri(target)) {
      _tryNextCandidateOrFail('客服地址无效');
      return;
    }
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) setState(() => _loading = false);
            },
            onWebResourceError: (error) {
              _tryNextCandidateOrFail(error.description);
            },
            onNavigationRequest: (request) {
              final uri = Uri.tryParse(request.url);
              if (!isSupportedSupportUri(uri)) {
                _tryNextCandidateOrFail('客服地址无效');
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(target);
      _webviewUnavailable = false;
    } catch (e) {
      _webviewUnavailable = true;
      _tryNextCandidateOrFail('$e');
    }
  }

  void _tryNextCandidateOrFail(String message) {
    if (!mounted) return;
    if (_candidateIndex + 1 < _candidateUris.length) {
      setState(() {
        _candidateIndex++;
        _loading = true;
        _errorText = null;
      });
      _createControllerAndLoad();
      return;
    }
    setState(() {
      _loading = false;
      _errorText = message;
      _controller = null;
    });
  }

  Future<void> _openWeb() async {
    final uri = _candidateUris.isNotEmpty ? _candidateUris.first : null;
    if (!isSupportedSupportUri(uri)) {
      if (!mounted) return;
      setState(() {
        _errorText = '暂无客服信息';
        _loading = false;
      });
      return;
    }
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final hasConfig = _candidateUris.isNotEmpty;
    final controller = _controller;
    final hasCrisp = controller != null && !_webviewUnavailable;
    final errorText = (_errorText ?? '').trim();
    final showInlineError = hasCrisp && errorText.isNotEmpty;
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
                      final c = _controller;
                      if (c != null) {
                        setState(() {
                          _loading = true;
                          _errorText = null;
                        });
                        c.reload();
                      }
                      return;
                    }
                    setState(() {
                      _candidateIndex = 0;
                      _loading = true;
                      _errorText = null;
                    });
                    _createControllerAndLoad();
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
                      Positioned.fill(
                        child: Builder(
                          builder: (_) {
                            final c = _controller;
                            if (c == null) {
                              return const SizedBox.shrink();
                            }
                            try {
                              return WebViewWidget(controller: c);
                            } catch (e) {
                              _webviewUnavailable = true;
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                setState(() {
                                  _loading = false;
                                  _errorText = '客服组件加载失败: $e';
                                  _controller = null;
                                });
                              });
                              return const SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                      if (_loading)
                        const Positioned.fill(
                          child: ColoredBox(
                            color: Colors.white,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      if (showInlineError)
                        Positioned.fill(
                          child: _ErrorView(text: errorText, onOpenWeb: _openWeb),
                        ),
                    ],
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            hasConfig
                                ? (errorText.isNotEmpty
                                      ? errorText
                                      : '客服页面加载失败，请点击网页打开')
                                : '暂无客服信息',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: V2ETTokens.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (hasConfig)
                            OutlinedButton(
                              onPressed: _openWeb,
                              child: const Text('网页打开'),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.text, required this.onOpenWeb});
  final String text;
  final VoidCallback onOpenWeb;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
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
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: V2ETTokens.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onOpenWeb, child: const Text('网页打开')),
          ],
        ),
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
