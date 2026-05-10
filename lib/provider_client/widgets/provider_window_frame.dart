import 'package:flutter/material.dart';
import '../theme/provider_tokens.dart';

class ProviderWindowFrame extends StatelessWidget {
  const ProviderWindowFrame({
    super.key,
    required this.child,
    this.title = V2ETTokens.brandName,
    this.backgroundColor = V2ETTokens.background,
  });

  final Widget child;
  final String title;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          _MacTitleBar(title: title),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _MacTitleBar extends StatelessWidget {
  const _MacTitleBar({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: V2ETTokens.titleBarHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E5EA))),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 14,
            child: Row(
              children: const [
                _Dot(color: Color(0xFFFF5F57)),
                SizedBox(width: 8),
                _Dot(color: Color(0xFFFFBD2E)),
                SizedBox(width: 8),
                _Dot(color: Color(0xFF28C840)),
              ],
            ),
          ),
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.black87)),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}
