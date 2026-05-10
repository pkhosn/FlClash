import 'package:flutter/material.dart';

import '../../theme/provider_tokens.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';

class V2ETProviderSettingsPage extends StatelessWidget {
  const V2ETProviderSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: const [
              _OfflineCard(),
              SizedBox(height: 16),
              _ProxySettingsCard(),
              SizedBox(height: 16),
              _Ipv6Card(),
              SizedBox(height: 16),
              _DnsCard(),
              SizedBox(height: 16),
              _GeoDataCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineCard extends StatelessWidget {
  const _OfflineCard();

  @override
  Widget build(BuildContext context) {
    return V2ETCard(
      radius: 16,
      child: Column(
        children: [
          Row(
            children: [
              const _IconBox(icon: Icons.bolt_rounded, color: V2ETTokens.teal),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('离线模式', style: V2ETTokens.h3),
                  SizedBox(height: 4),
                  Text('开启后下次无需登录', style: V2ETTokens.small),
                ],
              ),
              const Spacer(),
              Switch(value: false, onChanged: (_) {}),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: V2ETTokens.cardSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: V2ETTokens.border),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.info_outline_rounded,
                  color: V2ETTokens.textSecondary,
                  size: 18,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '开启后会在下次使用时跳过在线登录校验，适合本地节点场景。',
                    style: V2ETTokens.small,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProxySettingsCard extends StatelessWidget {
  const _ProxySettingsCard();

  @override
  Widget build(BuildContext context) {
    return V2ETCard(
      radius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            icon: Icons.code_rounded,
            title: '代理设置',
            subtitle: '管理本地代理服务',
          ),
          const SizedBox(height: 14),
          const _SettingRow(
            icon: Icons.tag_rounded,
            title: '混合端口',
            subtitle: 'HTTP & SOCKS5 共用端口',
            trailing: _ValuePill('7890'),
          ),
          const _SettingRow(
            icon: Icons.devices_other_rounded,
            title: '允许局域网',
            subtitle: '允许其他设备连接',
            trailing: Switch(value: false, onChanged: null),
          ),
          const SizedBox(height: 8),
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: V2ETTokens.cardSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: V2ETTokens.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.link_rounded,
                  color: V2ETTokens.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 12),
                const Text(
                  '127.0.0.1:7890',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
                const Spacer(),
                V2ETButton(
                  label: '复制',
                  icon: Icons.copy_rounded,
                  tone: V2ETButtonTone.soft,
                  height: 32,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Ipv6Card extends StatelessWidget {
  const _Ipv6Card();

  @override
  Widget build(BuildContext context) {
    return const V2ETCard(
      radius: 16,
      child: Column(
        children: [
          _SectionHeader(
            icon: Icons.water_drop_rounded,
            title: 'IPv6 设置',
            subtitle: '用一个开关统一管理 IPv6 相关能力',
          ),
          SizedBox(height: 14),
          _SettingRow(
            icon: Icons.toggle_on_rounded,
            title: 'IPv6 总开关',
            subtitle: '统一控制核心和 DNS IPv6 功能',
            trailing: Switch(value: false, onChanged: null),
          ),
        ],
      ),
    );
  }
}

class _DnsCard extends StatelessWidget {
  const _DnsCard();

  @override
  Widget build(BuildContext context) {
    return const V2ETCard(
      radius: 16,
      child: Column(
        children: [
          _SectionHeader(
            icon: Icons.dns_rounded,
            title: 'DNS 设置',
            subtitle: '管理 DNS 解析配置',
          ),
          SizedBox(height: 14),
          _SettingRow(
            icon: Icons.dns_rounded,
            title: 'DNS覆写',
            subtitle: '开启后将覆盖配置中的 DNS 选项',
            trailing: Switch(value: false, onChanged: null),
          ),
          _SettingRow(
            icon: Icons.tune_rounded,
            title: 'DNS模式',
            subtitle: 'fake-ip',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: V2ETTokens.textMuted,
            ),
          ),
          _SettingRow(
            icon: Icons.edit_rounded,
            title: '自定义DNS服务器',
            subtitle: '已配置 3 个DNS服务器',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: V2ETTokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _GeoDataCard extends StatelessWidget {
  const _GeoDataCard();

  @override
  Widget build(BuildContext context) {
    return V2ETCard(
      radius: 16,
      child: Column(
        children: [
          Row(
            children: [
              const _SectionHeader(
                icon: Icons.public_rounded,
                title: '地理数据',
                subtitle: '更新 GeoIP / GeoSite 数据库',
              ),
              const Spacer(),
              V2ETButton(
                label: '全部更新',
                icon: Icons.sync_rounded,
                tone: V2ETButtonTone.soft,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final item in const ['GeoIp', 'GeoSite', 'MMDB', 'ASN'])
            _SettingRow(
              icon: Icons.circle,
              title: item,
              subtitle: '',
              trailing: const Icon(
                Icons.refresh_rounded,
                color: V2ETTokens.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _IconBox(icon: icon, color: V2ETTokens.teal),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: V2ETTokens.h3),
            const SizedBox(height: 4),
            Text(subtitle, style: V2ETTokens.small),
          ],
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _IconBox(icon: icon, color: const Color(0xFFA8D4FF), size: 40),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: V2ETTokens.small),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color, this.size = 44});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD2D2D2)),
      ),
      child: Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}
