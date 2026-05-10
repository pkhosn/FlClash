import 'package:flutter/material.dart';
import '../theme/provider_tokens.dart';

enum V2ETButtonTone { primary, dark, soft, ghost, danger }

class V2ETButton extends StatelessWidget {
  const V2ETButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.tone = V2ETButtonTone.primary,
    this.height = 40,
    this.width,
    this.radius = 10,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final V2ETButtonTone tone;
  final double height;
  final double? width;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final style = _style(tone);
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: style.$1,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onPressed,
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: style.$2),
                  const SizedBox(width: 8),
                ],
                Text(label, style: TextStyle(color: style.$2, fontSize: 14, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color) _style(V2ETButtonTone tone) {
    switch (tone) {
      case V2ETButtonTone.primary:
        return (V2ETTokens.primary, Colors.white);
      case V2ETButtonTone.dark:
        return (V2ETTokens.darkButton, Colors.white);
      case V2ETButtonTone.soft:
        return (V2ETTokens.primarySoft, V2ETTokens.primary);
      case V2ETButtonTone.ghost:
        return (Colors.transparent, V2ETTokens.textSecondary);
      case V2ETButtonTone.danger:
        return (V2ETTokens.danger, Colors.white);
    }
  }
}

class V2ETSegmentButton extends StatelessWidget {
  const V2ETSegmentButton({super.key, required this.label, required this.selected, required this.onTap, this.icon});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? V2ETTokens.primarySoft : const Color(0xFFEDEFF3),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: selected ? Border.all(color: V2ETTokens.primary) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 15, color: selected ? V2ETTokens.primary : V2ETTokens.textSecondary), const SizedBox(width: 6)],
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: selected ? V2ETTokens.primary : V2ETTokens.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
