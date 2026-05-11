import 'package:flutter/material.dart';
import '../app_shell/provider_client_page.dart';
import '../theme/provider_tokens.dart';

class ProviderSidebar extends StatelessWidget {
  const ProviderSidebar({
    super.key,
    required this.current,
    required this.onChanged,
    required this.onSupport,
    this.onSupportWithRect,
    required this.onLogout,
  });

  final ProviderClientPage current;
  final ValueChanged<ProviderClientPage> onChanged;
  final VoidCallback onSupport;
  final ValueChanged<Rect>? onSupportWithRect;
  final VoidCallback onLogout;
  static final GlobalKey _supportIconKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: V2ETTokens.sidebarWidth,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _item(ProviderClientPage.dashboard, Icons.grid_view_rounded, '首页面板'),
          _item(ProviderClientPage.store, Icons.shopping_cart_rounded, '购买套餐'),
          _item(ProviderClientPage.invite, Icons.card_giftcard_rounded, '邀请推广'),
          _item(
            ProviderClientPage.connections,
            Icons.settings_input_component_rounded,
            '连接状态',
          ),
          const Spacer(),
          _SmallIcon(icon: Icons.card_giftcard_outlined, onTap: () {}),
          _SmallIcon(
            icon: Icons.headset_mic_outlined,
            iconKey: _supportIconKey,
            onTap: () {
              final box = _supportIconKey.currentContext?.findRenderObject();
              if (box is RenderBox && onSupportWithRect != null) {
                final offset = box.localToGlobal(Offset.zero);
                onSupportWithRect!(offset & box.size);
                return;
              }
              onSupport();
            },
          ),
          _SmallIcon(icon: Icons.wb_sunny_outlined, onTap: () {}),
          const SizedBox(height: 16),
          Container(width: 78, height: 1, color: V2ETTokens.border),
          const SizedBox(height: 16),
          _SmallIcon(
            icon: Icons.person_rounded,
            selected: current == ProviderClientPage.profile,
            onTap: () => onChanged(ProviderClientPage.profile),
          ),
          _SmallIcon(
            icon: Icons.settings_rounded,
            selected: current == ProviderClientPage.settings,
            onTap: () => onChanged(ProviderClientPage.settings),
          ),
          _SmallIcon(icon: Icons.logout_rounded, onTap: onLogout),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _item(ProviderClientPage page, IconData icon, String label) {
    final selected = current == page;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Material(
        color: selected ? V2ETTokens.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(page),
          child: SizedBox(
            height: 64,
            child: Stack(
              children: [
                if (selected)
                  const Positioned(
                    left: 0,
                    top: 20,
                    bottom: 20,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: V2ETTokens.primary,
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      child: SizedBox(width: 3),
                    ),
                  ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 22,
                        color: selected
                            ? V2ETTokens.primary
                            : V2ETTokens.sidebarIcon,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.w900
                              : FontWeight.w700,
                          color: selected
                              ? V2ETTokens.textPrimary
                              : V2ETTokens.sidebarIcon,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallIcon extends StatelessWidget {
  const _SmallIcon({
    required this.icon,
    required this.onTap,
    this.selected = false,
    this.iconKey,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;
  final GlobalKey? iconKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          key: iconKey,
          width: 44,
          height: 38,
          decoration: BoxDecoration(
            color: selected ? V2ETTokens.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 21,
            color: selected ? V2ETTokens.primary : V2ETTokens.sidebarIcon,
          ),
        ),
      ),
    );
  }
}
