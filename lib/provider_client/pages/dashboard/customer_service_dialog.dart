import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../theme/provider_tokens.dart';
import '../../widgets/app_input.dart';

Future<void> showV2ETCustomerServiceDialog(
  BuildContext context, {
  String crispWebsiteId = '',
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.38),
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: V2ETCustomerServiceDialog(crispWebsiteId: crispWebsiteId),
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

  @override
  void initState() {
    super.initState();
    final crispId = widget.crispWebsiteId.trim();
    if (crispId.isEmpty) return;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(
        Uri.parse('https://go.crisp.chat/chat/embed/?website_id=$crispId'),
      );
  }

  @override
  Widget build(BuildContext context) {
    final crispId = widget.crispWebsiteId.trim();
    final hasCrisp = crispId.isNotEmpty && _controller != null;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 380,
        height: 518,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [V2ETTokens.softShadow],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  IconButton(
                    onPressed: hasCrisp
                        ? () {
                            setState(() => _loading = true);
                            _controller!.reload();
                          }
                        : null,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
            if (!hasCrisp)
              Container(
                height: 168,
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE92724), Color(0xFFF53227)],
                  ),
                ),
                child: const Center(
                  child: Text(
                    '未配置 Crisp website_id',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
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
                                  '请在对象存储配置 crisp.website_id',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
      ),
    );
  }
}
