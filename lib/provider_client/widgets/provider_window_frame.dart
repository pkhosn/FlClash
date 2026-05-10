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
      body: child,
    );
  }
}
