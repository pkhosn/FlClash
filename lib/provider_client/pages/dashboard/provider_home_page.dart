import 'package:flutter/material.dart';
import '../../theme/provider_tokens.dart';
import '../../widgets/app_card.dart';
import 'notice_dialog.dart';
import 'proxy_group_dialog.dart';

class V2ETProviderHomePage extends StatelessWidget {
  const V2ETProviderHomePage({super.key, this.showNoticePopup = true});

  final bool showNoticePopup;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 34, 24, 26),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              _UsageCard(
                onNotice: () => showV2ETNoticeDialog(context),
                showNoticePopup: showNoticePopup,
              ),
              const SizedBox(height: 58),
              const _PowerButton(),
              const SizedBox(height: 30),
              const _ModeCard(),
              const SizedBox(height: 18),
              _CurrentNodeCard(onOpen: () => showV2ETProxyGroupDialog(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsageCard extends StatelessWidget {
  const _UsageCard({required this.onNotice, required this.showNoticePopup});
  final VoidCallback onNotice;
  final bool showNoticePopup;

  @override
  Widget build(BuildContext context) {
    return V2ETCard(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      radius: 16,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _UsageStat(
                  label: '剩余流量',
                  value: '87.4 GB',
                  align: CrossAxisAlignment.start,
                ),
              ),
              Expanded(
                child: _UsageStat(
                  label: '有效期',
                  value: '21 天',
                  align: CrossAxisAlignment.end,
                ),
              ),
              if (showNoticePopup)
                Row(
                  children: [
                    _ActionIcon(icon: Icons.refresh_rounded, onTap: () {}),
                    const SizedBox(width: 8),
                    _ActionIcon(icon: Icons.public_rounded, onTap: () {}),
                    const SizedBox(width: 8),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _ActionIcon(
                          icon: Icons.campaign_rounded,
                          onTap: onNotice,
                        ),
                        Positioned(
                          right: -4,
                          top: -6,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: V2ETTokens.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                '5',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E4E9),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.12,
                child: Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: V2ETTokens.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const Positioned.fill(
                child: Center(
                  child: Text(
                    '12%',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: V2ETTokens.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: const [
              Text('已用 12.6 GB', style: V2ETTokens.mini),
              Spacer(),
              Text('共 100 GB', style: V2ETTokens.mini),
              Spacer(),
              Text('预计重置日期 2026-06-01', style: V2ETTokens.mini),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsageStat extends StatelessWidget {
  const _UsageStat({
    required this.label,
    required this.value,
    required this.align,
  });
  final String label;
  final String value;
  final CrossAxisAlignment align;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(label, style: V2ETTokens.mini),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: V2ETTokens.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: V2ETTokens.primarySoft,
    borderRadius: BorderRadius.circular(11),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(icon, size: 20, color: V2ETTokens.primary),
      ),
    ),
  );
}

class _PowerButton extends StatelessWidget {
  const _PowerButton();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 176,
          height: 176,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF2F5F8), Color(0xFFE7ECF1)],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              const BoxShadow(
                color: Colors.white,
                blurRadius: 20,
                offset: Offset(-8, -8),
              ),
            ],
          ),
          child: Icon(
            Icons.power_settings_new_rounded,
            size: 72,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 22),
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFC8CDD4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.circle_outlined,
                size: 16,
                color: V2ETTokens.textSecondary,
              ),
              SizedBox(width: 6),
              Text(
                '未连接',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: V2ETTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard();
  @override
  Widget build(BuildContext context) {
    return V2ETCard(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.tune_rounded, color: V2ETTokens.textSecondary),
              SizedBox(width: 8),
              Text(
                '代理模式',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              Spacer(),
              Text('根据规则自动选择直连或代理', style: V2ETTokens.small),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(child: _ModeButton(label: '规则', selected: true)),
              SizedBox(width: 8),
              Expanded(child: _ModeButton(label: '全局')),
              SizedBox(width: 8),
              Expanded(child: _ModeButton(label: 'TUN')),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({required this.label, this.selected = false});
  final String label;
  final bool selected;
  @override
  Widget build(BuildContext context) => Container(
    height: 46,
    decoration: BoxDecoration(
      color: selected ? const Color(0xFFD9EFEA) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: selected ? const Color(0xFF8FD0C5) : V2ETTokens.border,
      ),
      boxShadow: selected ? const [V2ETTokens.tinyShadow] : null,
    ),
    child: Center(
      child: Text(
        selected ? '✓ $label' : label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
          color: selected ? const Color(0xFF0B8B7D) : V2ETTokens.textPrimary,
        ),
      ),
    ),
  );
}

class _CurrentNodeCard extends StatelessWidget {
  const _CurrentNodeCard({required this.onOpen});
  final VoidCallback onOpen;
  @override
  Widget build(BuildContext context) {
    return V2ETCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 36,
            decoration: BoxDecoration(
              color: V2ETTokens.cardSoft,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE3E8F0)),
            ),
            child: const Center(child: Text('🇭🇰')),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '自动选择',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4),
                Text('香港3-Gemini', style: V2ETTokens.small),
              ],
            ),
          ),
          const Text(
            '83ms',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: V2ETTokens.success,
            ),
          ),
          const SizedBox(width: 14),
          Material(
            color: const Color(0xFFECE7FF),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onOpen,
              borderRadius: BorderRadius.circular(8),
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Icon(
                  Icons.live_tv_rounded,
                  color: Color(0xFF7357C8),
                  size: 18,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onOpen,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: V2ETTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
