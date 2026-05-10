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
    return SizedBox(
      width: width,
      height: height,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: V2ETTokens.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: V2ETTokens.textMuted),
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 18, color: V2ETTokens.textMuted),
          suffixIcon: suffix,
          isDense: true,
          filled: true,
          fillColor: V2ETTokens.input,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(V2ETTokens.radiusM),
            borderSide: const BorderSide(color: V2ETTokens.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(V2ETTokens.radiusM),
            borderSide: const BorderSide(color: V2ETTokens.border),
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
