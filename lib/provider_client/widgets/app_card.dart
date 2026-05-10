import 'package:flutter/material.dart';
import '../theme/provider_tokens.dart';

class V2ETCard extends StatelessWidget {
  const V2ETCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.radius = V2ETTokens.radiusL,
    this.color = V2ETTokens.card,
    this.borderColor = V2ETTokens.border,
    this.shadow = false,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color color;
  final Color borderColor;
  final bool shadow;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: shadow ? const [V2ETTokens.softShadow] : null,
      ),
      child: child,
    );
  }
}
