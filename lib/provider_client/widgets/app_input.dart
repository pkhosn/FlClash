import 'package:flutter/material.dart';
import '../theme/provider_tokens.dart';

class V2ETInput extends StatelessWidget {
  const V2ETInput({
    super.key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.width,
    this.height = 40,
  });

  final TextEditingController? controller;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputBg = isDark ? V2ETTokens.darkInput : V2ETTokens.input;
    final borderColor = isDark ? V2ETTokens.darkBorder : V2ETTokens.border;
    final textColor = isDark ? V2ETTokens.darkTextPrimary : V2ETTokens.textPrimary;
    final hintColor = isDark ? V2ETTokens.darkTextMuted : V2ETTokens.textMuted;
    return SizedBox(
      width: width,
      height: height,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: hintColor),
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 18, color: hintColor),
          suffixIcon: suffix,
          isDense: true,
          filled: true,
          fillColor: inputBg,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(V2ETTokens.radiusM),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(V2ETTokens.radiusM),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(V2ETTokens.radiusM),
            borderSide: const BorderSide(color: V2ETTokens.primary, width: 1.2),
          ),
        ),
      ),
    );
  }
}
