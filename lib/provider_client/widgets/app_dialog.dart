import 'package:flutter/material.dart';

class V2ETDialogShell extends StatelessWidget {
  const V2ETDialogShell({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    required this.body,
    this.actions,
    this.width = 460,
  });

  final String title;
  final IconData? icon;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null)
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: const Color(0xFF3779F6)),
                  ),
                if (icon != null) const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 34 / 2,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(18),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close_rounded, color: Color(0xFF9CA3AF)),
                  ),
                ),
              ],
            ),
            if ((subtitle ?? '').isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
              ),
            ],
            const SizedBox(height: 14),
            body,
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: 18),
              Row(children: actions!),
            ],
          ],
        ),
      ),
    );
  }
}
