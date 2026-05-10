import 'package:flutter/material.dart';
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

class V2ETCustomerServiceDialog extends StatelessWidget {
  const V2ETCustomerServiceDialog({super.key, this.crispWebsiteId = ''});

  final String crispWebsiteId;

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () {},
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
            Container(
              height: 168,
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE92724), Color(0xFFF53227)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD51F1B),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [V2ETTokens.tinyShadow],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          '聊天',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _CircleIcon(icon: Icons.chat_bubble_outline),
                      SizedBox(width: 8),
                      _CircleIcon(
                        icon: Icons.contact_support_outlined,
                        label: '客服',
                      ),
                      SizedBox(width: 8),
                      _CircleIcon(icon: Icons.pets_rounded),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '有疑问吗？联系我们！',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '◷ 上次活动 2026/4/29',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
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
                            '请问有什么可以帮您 即时消息?',
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
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        crispWebsiteId.isEmpty
                            ? '我们运行于  💬 crisp'
                            : '我们运行于  💬 crisp · $crispWebsiteId',
                        style: V2ETTokens.small.copyWith(
                          color: V2ETTokens.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, this.label});
  final IconData icon;
  final String? label;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: V2ETTokens.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: label == null
            ? Icon(icon, color: Colors.white)
            : Text(
                label!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }
}
