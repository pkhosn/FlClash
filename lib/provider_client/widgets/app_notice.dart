import 'package:flutter/material.dart';

enum V2ETNoticeType { success, error, info }

class V2ETNotice {
  static void success(BuildContext context, String text) {
    _show(context, text, V2ETNoticeType.success);
  }

  static void error(BuildContext context, String text) {
    _show(context, text, V2ETNoticeType.error);
  }

  static void info(BuildContext context, String text) {
    _show(context, text, V2ETNoticeType.info);
  }

  static void _show(BuildContext context, String text, V2ETNoticeType type) {
    final (bg, fg, icon) = switch (type) {
      V2ETNoticeType.success => (
        const Color(0xFFF3FBF5),
        const Color(0xFF16A34A),
        Icons.check_rounded,
      ),
      V2ETNoticeType.error => (
        const Color(0xFFFEF2F2),
        const Color(0xFFDC2626),
        Icons.close_rounded,
      ),
      V2ETNoticeType.info => (
        const Color(0xFFF3F4F6),
        const Color(0xFF4B5563),
        Icons.info_outline_rounded,
      ),
    };
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        content: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: const Color(0xFFE6EAF0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: fg),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
