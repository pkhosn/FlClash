import 'package:flutter/material.dart';
import '../theme/provider_tokens.dart';

/// Auth page background for login/register/reset-password.
///
/// Current default is a clean white/light background. A custom branded image can
/// be injected at packaging time later by passing [backgroundImage] or by wiring
/// this widget to the remote/build config.
class AuthBackground extends StatelessWidget {
  const AuthBackground({
    super.key,
    required this.child,
    this.onBack,
    this.onSupport,
    this.showServicePill = true,
    this.backgroundImage,
    this.showMockDecoration = false,
  });

  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onSupport;
  final bool showServicePill;
  final ImageProvider? backgroundImage;

  /// Keep false by default. The previous blue gradient/Sisyphus mock background
  /// was only for visual exploration and should not be the default client skin.
  final bool showMockDecoration;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: _BackgroundLayer(image: backgroundImage, showMockDecoration: showMockDecoration)),
        if (onBack != null)
          Positioned(
            top: 28,
            left: 28,
            child: IconButton(icon: const Icon(Icons.arrow_back_rounded, size: 24), onPressed: onBack),
          ),
        if (showServicePill)
          Positioned(
            right: 46,
            top: 20,
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: V2ETTokens.primarySoft, borderRadius: BorderRadius.circular(18)),
              child: Row(
                children: const [
                  Icon(Icons.check_circle, color: V2ETTokens.success, size: 15),
                  SizedBox(width: 6),
                  Text('服务可用', style: TextStyle(color: V2ETTokens.success, fontSize: 12, fontWeight: FontWeight.w900)),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded, color: V2ETTokens.success, size: 16),
                ],
              ),
            ),
          ),
        Center(child: child),
        Positioned(
          right: 24,
          bottom: 28,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: V2ETTokens.primary,
            onPressed: onSupport,
            child: const Icon(Icons.support_agent_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _BackgroundLayer extends StatelessWidget {
  const _BackgroundLayer({required this.image, required this.showMockDecoration});

  final ImageProvider? image;
  final bool showMockDecoration;

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: V2ETTokens.authBackground,
          image: DecorationImage(image: image!, fit: BoxFit.cover),
        ),
      );
    }

    if (showMockDecoration) {
      return Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [V2ETTokens.authTop, V2ETTokens.authBottom],
                ),
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: _SisyphusPainter())),
        ],
      );
    }

    return const DecoratedBox(
      decoration: BoxDecoration(
        color: V2ETTokens.authBackground,
      ),
    );
  }
}

class AuthGlassCard extends StatelessWidget {
  const AuthGlassCard({super.key, required this.child, this.width = 445, this.padding = const EdgeInsets.fromLTRB(34, 34, 34, 28)});
  final Widget child;
  final double width;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0xF2F7FBFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.75)),
        boxShadow: const [V2ETTokens.softShadow],
      ),
      child: child,
    );
  }
}

class AuthToolButton extends StatelessWidget {
  const AuthToolButton({super.key, required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE9F1FA),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(width: 40, height: 40, child: Center(child: child)),
      ),
    );
  }
}

class _SisyphusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final path = Path()
      ..moveTo(0, size.height * 0.50)
      ..quadraticBezierTo(size.width * 0.20, size.height * 0.86, size.width, size.height * 0.96)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);

    final rockCenter = Offset(size.width * 0.15, size.height * 0.62);
    canvas.drawCircle(rockCenter, 48, paint);
    final personPaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(size.width * 0.15 + 56, size.height * 0.69), 12, personPaint);
    canvas.drawLine(Offset(size.width * 0.15 + 52, size.height * 0.70), Offset(size.width * 0.15 + 34, size.height * 0.76), personPaint..strokeWidth = 8);
    canvas.drawLine(Offset(size.width * 0.15 + 43, size.height * 0.73), Offset(size.width * 0.15 + 4, size.height * 0.65), personPaint..strokeWidth = 5);
    canvas.drawLine(Offset(size.width * 0.15 + 34, size.height * 0.76), Offset(size.width * 0.15 + 20, size.height * 0.83), personPaint..strokeWidth = 7);
    canvas.drawLine(Offset(size.width * 0.15 + 34, size.height * 0.76), Offset(size.width * 0.15 + 66, size.height * 0.82), personPaint..strokeWidth = 7);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
